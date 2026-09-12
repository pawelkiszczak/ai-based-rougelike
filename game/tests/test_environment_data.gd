extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	var environment := load("res://content/environments/command_mesh.tres") as EnvironmentData
	_expect(environment != null, "environment resource loads")
	if environment == null:
		quit(1)
		return
	_expect(environment.validate().ok, "environment schema validates")
	_expect(environment.mechanic_id == &"baseline_pressure", "environment exposes its mechanic contract")
	_expect(environment.slots.size() == 6, "environment exposes six slots")
	var encounters := {
		"combat_probe": load("res://content/encounters/combat_probe.tres") as EncounterData,
		"negotiation_probe": load("res://content/encounters/negotiation_probe.tres") as EncounterData,
		"event_probe": load("res://content/encounters/event_probe.tres") as EncounterData,
	}
	for slot in environment.slots:
		_expect(encounters.has(str(slot.encounter_id)), "slot references existing encounter id")
		_expect(encounters[str(slot.encounter_id)].kind == slot.kind, "slot kind matches encounter resource")
	_expect(FileAccess.file_exists(environment.background_art), "environment art reference resolves")

	var first_rng := RNGService.new(123)
	var second_rng := RNGService.new(123)
	for _index in 20:
		_expect(environment.draw_slot(first_rng) == environment.draw_slot(second_rng), "slot draws are seeded and repeatable")
	if failures.is_empty():
		print("EnvironmentData tests passed")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
