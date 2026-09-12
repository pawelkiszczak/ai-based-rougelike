extends SceneTree

const DEFAULT_SEED_BASE := 1000
const DEFAULT_COUNT := 10
const DEFAULT_OUTPUT := "user://harness-results.json"
const DEFAULT_MUTATION_DIR := "res://content/mutations"
const CHOICE_COUNT := 3
const SCHEMA_VERSION := 1


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var config := _parse_args(OS.get_cmdline_user_args())
	if not config.ok:
		_fail(config.error)
		return

	var mutations: Array[MutationData] = MutationLibrary.load_all(config.mutation_dir, true)
	if mutations.is_empty():
		_fail(MutationLibrary.last_error if not MutationLibrary.last_error.is_empty() else "mutation library is empty")
		return
	for mutation in mutations:
		if mutation.id == &"" or mutation.display_name.is_empty() or mutation.text.is_empty():
			_fail("invalid mutation content: " + str(mutation.id))
			return

	var runs: Array[Dictionary] = []
	var wins := 0
	var causes: Dictionary = {}
	for offset in config.count:
		var run_result := _simulate(config.seed_base + offset, mutations)
		if not run_result.ok:
			_fail(run_result.error)
			return
		var run: Dictionary = run_result.run
		runs.append(run)
		if run.won:
			wins += 1
		var cause: String = run.cause
		causes[cause] = int(causes.get(cause, 0)) + 1

	var document := {
		"schema_version": SCHEMA_VERSION,
		"seed_base": config.seed_base,
		"count": config.count,
		"policy": "greedy_adaptation",
		"distribution": {
			"wins": wins,
			"losses": config.count - wins,
			"causes": causes,
		},
		"runs": runs,
	}
	var output := JSON.stringify(document, "", false) + "\n"
	var file := FileAccess.open(config.output, FileAccess.WRITE)
	if file == null:
		_fail("cannot write harness output: " + config.output)
		return
	file.store_string(output)
	file.close()
	print("Harness completed %d runs: %s" % [config.count, config.output])
	quit(0)


func _simulate(run_seed: int, mutations: Array[MutationData]) -> Dictionary:
	var state := GameState.new(18, 5, 5, 0, 1, run_seed)
	var controller := RunController.new(state, RNGService.new(run_seed))
	var picks: Array[String] = []
	var encounters: Array[Dictionary] = []
	var safety := 0
	while not controller.ended and safety < RunController.MAX_CYCLES + 1:
		var choices := controller.draw_choices(mutations, CHOICE_COUNT)
		if choices.size() != CHOICE_COUNT:
			return {"ok": false, "error": "choice policy received fewer than three mutations"}
		var selected := _select_greedy(choices)
		picks.append(str(selected.id))
		var encounter_kind: StringName = [&"combat", &"negotiation", &"event"][safety % 3]
		var encounter := EncounterFSM.new(encounter_kind)
		encounter.start({"cycle": state.cycle})
		encounter.open_choice({"choice_count": CHOICE_COUNT})
		encounter.resolve({"mutation_id": str(selected.id)})
		encounter.apply_consequence()
		encounters.append({
			"kind": str(encounter_kind),
			"states": encounter.state_sequence_names(),
		})
		controller.choose(selected)
		safety += 1
	if not controller.ended:
		return {"ok": false, "error": "simulation exceeded terminal cycle bound for seed %d" % run_seed}
	if controller.run_log.is_empty():
		return {"ok": false, "error": "simulation produced no cycle log for seed %d" % run_seed}

	var cycles: Array[Dictionary] = []
	for index in controller.run_log.size():
		var entry: Dictionary = controller.run_log[index]
		cycles.append({
			"cycle": entry.cycle,
			"pressure": entry.pressure,
			"damage": entry.damage,
			"integrity": entry.integrity,
			"compute": entry.compute,
			"alignment": entry.alignment,
			"adaptation": entry.adaptation,
			"encounter": encounters[index],
		})
	var final_state := controller.state
	var final_stats := {
		"integrity": final_state.integrity,
		"compute": final_state.compute,
		"alignment": final_state.alignment,
		"adaptation": final_state.adaptation,
	}
	var terminal: Dictionary = controller.run_log.back()
	return {
		"ok": true,
		"run": {
			"run_seed": run_seed,
			"ended": controller.ended,
			"won": controller.won,
			"cause": terminal.cause,
			"archive_gained": terminal.archive_gained,
			"choices": picks,
			"cycles": cycles,
			"final_stats": final_stats,
		},
	}


func _select_greedy(choices: Array[MutationData]) -> MutationData:
	var selected := choices[0]
	for mutation in choices:
		if mutation.adaptation > selected.adaptation:
			selected = mutation
		elif mutation.adaptation == selected.adaptation and mutation.guard > selected.guard:
			selected = mutation
	return selected


func _parse_args(args: PackedStringArray) -> Dictionary:
	var seed_text := _argument(args, "--seed-base", str(DEFAULT_SEED_BASE))
	var count_text := _argument(args, "--count", str(DEFAULT_COUNT))
	var output := _argument(args, "--output", DEFAULT_OUTPUT)
	var mutation_dir := _argument(args, "--mutation-dir", DEFAULT_MUTATION_DIR)
	if not seed_text.is_valid_int():
		return {"ok": false, "error": "--seed-base must be an integer"}
	if not count_text.is_valid_int():
		return {"ok": false, "error": "--count must be an integer"}
	var seed_base := int(seed_text)
	var count := int(count_text)
	if count <= 0:
		return {"ok": false, "error": "--count must be greater than zero"}
	return {
		"ok": true,
		"seed_base": seed_base,
		"count": count,
		"output": output,
		"mutation_dir": mutation_dir,
	}


func _argument(args: PackedStringArray, name: String, fallback: String) -> String:
	for index in args.size():
		var argument := args[index]
		if argument == name and index + 1 < args.size():
			return args[index + 1]
		if argument.begins_with(name + "="):
			return argument.trim_prefix(name + "=")
	return fallback


func _fail(message: String) -> void:
	push_error("Harness failed: " + message)
	quit(1)
