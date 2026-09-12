extends SceneTree

var failures: Array[String] = []
var trace: Array[String] = []


func _init() -> void:
	var boss := load("res://content/bosses/convergence_archon.tres") as BossData
	_expect(boss != null, "environment three boss resource loads")
	if boss == null:
		quit(1)
		return
	var gate := BossGate.new(boss)
	gate.tell_visible.connect(_on_tell)
	gate.phase_changed.connect(_on_phase_changed)
	var pre_transition := GameState.new(18, 5, 7, 0, 4, 401)
	var pre_preview := gate.preview(pre_transition)
	_expect(pre_preview.tell, "boss tell appears one decision before cycle transition")
	_expect(pre_preview.pressure == boss.phase_one_pressure + pre_transition.cycle, "phase one pressure uses the first profile")
	var transition := gate.resolve(GameState.new(18, 5, 7, 0, 5, 401))
	_expect(transition.transitioned and transition.phase == BossGate.Phase.TWO, "boss reaches phase two at cycle boundary")
	_expect(trace == ["tell", "phase"], "tell precedes phase switch exactly once")
	_expect(boss.phase_two_pressure > boss.phase_one_pressure, "phase two pressure is distinct")
	_expect(gate.preview(GameState.new(18, 5, 7, 0, 5, 401)).pressure == boss.phase_two_pressure, "phase two preview exposes escalation")
	var adaptation_gate := BossGate.new(boss)
	var adaptation_preview := adaptation_gate.preview(GameState.new(18, 5, 7, 8, 1, 402))
	_expect(adaptation_preview.tell, "adaptation threshold also previews escalation")
	var win_gate := BossGate.new(boss)
	win_gate.resolve(GameState.new(18, 5, 7, 0, 5, 403))
	var win := win_gate.resolve(GameState.new(18, 5, 12, 14, 6, 403))
	_expect(win.ended and win.won, "alignment route wins phase two")
	var lose_gate := BossGate.new(boss)
	lose_gate.resolve(GameState.new(18, 5, 7, 0, 5, 404))
	var lose := lose_gate.resolve(GameState.new(0, 5, 7, 0, 6, 404))
	_expect(lose.ended and not lose.won, "integrity depletion route loses phase two")
	_expect(FileAccess.file_exists("res://art/bosses/convergence_archon.svg"), "boss art resolves")
	if failures.is_empty():
		print("Boss three tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _on_tell(_tell: Dictionary) -> void:
	trace.append("tell")


func _on_phase_changed(_phase: int) -> void:
	trace.append("phase")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
