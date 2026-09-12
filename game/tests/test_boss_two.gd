extends SceneTree

var failures: Array[String] = []
var tells: Array[Dictionary] = []


func _init() -> void:
	var boss := load("res://content/bosses/entropy_leviathan.tres") as BossData
	_expect(boss != null, "environment two boss resource loads")
	if boss == null:
		quit(1)
		return
	var gate := BossGate.new(boss)
	gate.tell_visible.connect(_on_tell)
	var pre_transition := GameState.new(18, 5, 5, 0, 3, 301)
	_expect(gate.preview(pre_transition).tell, "boss tell appears before cycle transition")
	var transition := gate.resolve(GameState.new(18, 5, 5, 0, 4, 301))
	_expect(transition.transitioned and transition.phase == BossGate.Phase.TWO, "boss reaches phase two at cycle boundary")
	_expect(tells.size() == 1, "boss tell emits exactly once before transition")
	_expect(boss.phase_two_pressure > boss.phase_one_pressure, "phase two pressure is distinct")
	_expect(gate.preview(GameState.new(18, 5, 5, 0, 4, 301)).pressure == boss.phase_two_pressure, "phase two preview exposes escalation")
	var win_gate := BossGate.new(boss)
	win_gate.resolve(GameState.new(18, 5, 5, 0, 4, 302))
	var win := win_gate.resolve(GameState.new(18, 5, 12, 14, 6, 302))
	_expect(win.ended and win.won, "high-adaptation route wins phase two")
	var lose_gate := BossGate.new(boss)
	lose_gate.resolve(GameState.new(18, 5, 5, 0, 4, 303))
	var lose := lose_gate.resolve(GameState.new(0, 5, 5, 0, 6, 303))
	_expect(lose.ended and not lose.won, "integrity depletion route loses phase two")
	_expect(FileAccess.file_exists("res://art/bosses/entropy_leviathan.svg"), "boss art resolves")
	if failures.is_empty():
		print("Boss two tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _on_tell(tell: Dictionary) -> void:
	tells.append(tell)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
