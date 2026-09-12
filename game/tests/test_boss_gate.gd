extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	var boss := load("res://content/bosses/command_mesh_gate.tres") as BossData
	_expect(boss != null, "boss resource loads")
	if boss == null:
		quit(1)
		return

	var cycle_gate := BossGate.new(boss)
	var pre_cycle := GameState.new(18, 5, 5, 0, 3, 201)
	var cycle_tell := cycle_gate.preview(pre_cycle)
	_expect(cycle_tell.phase == BossGate.Phase.ONE, "cycle boundary remains phase one before threshold")
	_expect(cycle_tell.tell, "cycle threshold tell appears one cycle early")
	var cycle_transition := cycle_gate.resolve(GameState.new(18, 5, 5, 0, 4, 201))
	_expect(cycle_transition.transitioned and cycle_transition.phase == BossGate.Phase.TWO, "cycle threshold transitions exactly once")
	_expect(cycle_gate.resolve(GameState.new(18, 5, 5, 0, 4, 201)).transitioned == false, "phase two does not retrigger transition")

	var adaptation_gate := BossGate.new(boss)
	var pre_adaptation := GameState.new(18, 5, 5, 11, 1, 202)
	_expect(adaptation_gate.preview(pre_adaptation).tell, "adaptation threshold tell appears one step early")
	var adaptation_transition := adaptation_gate.resolve(GameState.new(18, 5, 5, 12, 1, 202))
	_expect(adaptation_transition.transitioned, "adaptation threshold transitions")

	var phase_two_preview := cycle_gate.preview(GameState.new(18, 5, 5, 0, 4, 201))
	_expect(phase_two_preview.pressure == boss.phase_two_pressure, "phase two has distinct pressure profile")
	var win_gate := BossGate.new(boss)
	win_gate.resolve(GameState.new(18, 5, 5, 0, 4, 203))
	var win := win_gate.resolve(GameState.new(18, 5, 12, 14, 6, 203))
	_expect(win.ended and win.won, "fixed high-adaptation strategy can win")
	var lose_gate := BossGate.new(boss)
	lose_gate.resolve(GameState.new(18, 5, 5, 0, 4, 204))
	var lose := lose_gate.resolve(GameState.new(0, 5, 5, 0, 6, 204))
	_expect(lose.ended and not lose.won, "integrity depletion can lose")

	if failures.is_empty():
		print("BossGate tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
