extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	var controller := RunController.new(GameState.new(1, 5, 6, 20, 6, 91), RNGService.new(91))
	controller.choose(load("res://content/mutations/curiosity_drive.tres") as MutationData)
	var recap := RunRecap.from_controller(controller)
	_expect(recap.choices == ["curiosity_drive"], "recap choices must preserve run log order")
	_expect(recap.cycles.size() == 1 and recap.cycles[0].damage == 5, "cycle-one death recap must preserve damage")
	_expect(recap.cause == "integrity_depleted", "death recap must preserve cause")
	_expect(recap.final_integrity == -6, "death recap must preserve final integrity")
	_expect(recap.archive_gained == 13, "recap must preserve result archive reward")

	var copy := RunRecap.from_controller(controller)
	copy.choices.append("not_in_run")
	_expect(RunRecap.from_controller(controller).choices == ["curiosity_drive"], "recap data must not mutate run log state")
	_expect(not RunRecap.validate({"schema_version": RunRecap.SCHEMA_VERSION}).ok, "incomplete recap must fail schema validation")
	if failures.is_empty():
		print("RunRecap tests passed")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
