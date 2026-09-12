extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	var first := DailyRunConfig.seed_for_date("2026-09-12")
	var second := DailyRunConfig.seed_for_date("2026-09-12")
	var next := DailyRunConfig.seed_for_date("2026-09-13")
	_expect(first.ok and first.seed == second.seed, "same UTC date produces the same daily seed")
	_expect(first.seed != next.seed, "adjacent UTC dates produce different daily seeds")
	_expect(DailyRunConfig.seed_for_utc_timestamp(86399).namespace == "daily:v1:1970-01-01", "UTC day boundary uses the prior date before rollover")
	_expect(DailyRunConfig.seed_for_utc_timestamp(86400).namespace == "daily:v1:1970-01-02", "UTC day boundary rolls at midnight")
	_expect(DailyRunConfig.parse_seed("daily:v1:2026-09-12").seed == first.seed, "canonical daily seed input parses")
	_expect(DailyRunConfig.parse_seed("-42").seed == -42, "manual integer seed input parses")
	_expect(not DailyRunConfig.parse_seed("daily:v1:not-a-date").ok, "invalid daily seed input is rejected")

	var modifiers := DailyRunConfig.normalise_modifiers([&"hardened_pressure", &"single_category", &"low_compute"])
	_expect(modifiers.ok, "authored modifier set validates")
	_expect(not DailyRunConfig.normalise_modifiers([&"unknown"]).ok, "unknown modifier is rejected")
	var controller := RunController.new(GameState.new(), RNGService.new(7), null, modifiers.modifiers)
	_expect(controller.state.compute == 3, "low compute modifier changes opening state")
	var mutation_pool := MutationLibrary.load_all()
	var choices := controller.draw_choices(mutation_pool, 3)
	_expect(not choices.is_empty(), "single-category modifier leaves choices available")
	for mutation in choices:
		_expect(mutation.category == &"safety", "single-category modifier filters to safety mutations")
	var mutation := mutation_pool[0]
	var normal_damage := RunController.new(GameState.new(), RNGService.new(7)).damage_range(GameState.new(), mutation)
	var hardened_damage := controller.damage_range(GameState.new(), mutation)
	_expect(hardened_damage.pressure == normal_damage.pressure + 2, "hardened pressure modifier increases telegraphed pressure")
	if failures.is_empty():
		print("Daily run tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
