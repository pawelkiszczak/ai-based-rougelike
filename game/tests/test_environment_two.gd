extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	var environment := load("res://content/environments/entropy_basin.tres") as EnvironmentData
	_expect(environment != null, "environment two resource loads")
	if environment == null:
		quit(1)
		return
	_expect(environment.validate().ok, "environment two schema validates")
	_expect(environment.slots.size() == 6, "environment two exposes six slots")
	var kinds: Dictionary = {}
	for slot in environment.slots:
		kinds[str(slot.kind)] = true
	_expect(kinds.size() == 3, "environment two covers all encounter kinds")
	_expect(FileAccess.file_exists(environment.background_art), "environment two art resolves")
	var low := environment.mechanic_preview(GameState.new(18, 2, 5, 0, 1, 1))
	var safe := environment.mechanic_preview(GameState.new(18, 5, 5, 0, 1, 1))
	_expect(low.pressure_modifier == 2, "compute scarcity increases low-reserve pressure")
	_expect(safe.pressure_modifier == 0, "compute reserve avoids scarcity pressure")
	_expect(low.reason.contains("low compute") and safe.reason.contains("stable"), "twist explains both boundary outcomes")
	var first_rng := RNGService.new(88)
	var second_rng := RNGService.new(88)
	for _index in 20:
		_expect(environment.draw_slot(first_rng) == environment.draw_slot(second_rng), "environment two slot draws are deterministic")
	if failures.is_empty():
		print("Environment two tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
