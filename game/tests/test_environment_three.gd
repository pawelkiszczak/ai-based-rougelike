extends SceneTree

class FixedRNG extends RNGService:
	var fixed_roll: int

	func _init(seed_value: int) -> void:
		super(seed_value)
		fixed_roll = seed_value

	func next_int(_from: int, _to: int) -> int:
		return fixed_roll


var failures: Array[String] = []


func _init() -> void:
	var environment := load("res://content/environments/alignment_cascade.tres") as EnvironmentData
	_expect(environment != null, "environment three resource loads")
	if environment == null:
		quit(1)
		return
	_expect(environment.validate().ok, "environment three schema validates")
	_expect(environment.slots.size() == 6, "environment three exposes six slots")
	var kinds: Dictionary = {}
	for slot in environment.slots:
		kinds[str(slot.kind)] = true
	_expect(kinds.size() == 3, "environment three covers all encounter kinds")
	_expect(environment.draw_slot(FixedRNG.new(1)).kind == &"combat", "fixed seed reaches combat slot")
	_expect(environment.draw_slot(FixedRNG.new(2)).kind == &"negotiation", "fixed seed reaches negotiation slot")
	_expect(environment.draw_slot(FixedRNG.new(5)).kind == &"event", "fixed seed reaches event slot")
	_expect(FileAccess.file_exists(environment.background_art), "environment three art resolves")
	var below_threshold := environment.mechanic_preview(GameState.new(18, 5, 7, 0, 1, 1))
	var at_threshold := environment.mechanic_preview(GameState.new(18, 5, 8, 0, 1, 1))
	_expect(below_threshold.pressure_modifier == 0, "alignment below threshold keeps pressure stable")
	_expect(at_threshold.pressure_modifier == 2, "alignment threshold increases pressure")
	_expect(at_threshold.reason.contains("choose restraint"), "alignment pressure previews the next decision")
	if failures.is_empty():
		print("Environment three tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
