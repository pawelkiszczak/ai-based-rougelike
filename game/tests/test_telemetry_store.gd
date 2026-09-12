extends SceneTree

const TELEMETRY_PATH := "user://telemetry-test.jsonl"
const SAVE_PATH := "user://telemetry-save-test.json"

var failures: Array[String] = []


func _init() -> void:
	var watchdog := create_timer(15.0)
	watchdog.timeout.connect(_on_watchdog_timeout)
	call_deferred("_run")


func _run() -> void:
	print("telemetry: start")
	_cleanup()
	var telemetry := TelemetryStore.new(TELEMETRY_PATH, true)
	for seed in 3:
		_expect(telemetry.record_run(_recap(seed, seed == 0), seed * 100).recorded, "opt-in run is appended")
	print("telemetry: records written")
	var lines := FileAccess.get_file_as_string(TELEMETRY_PATH).strip_edges().split("\n")
	_expect(lines.size() == 3, "three completed runs produce three JSONL records")
	for line in lines:
		_expect(telemetry.validate_line(line).ok, "every telemetry line satisfies the schema")
	print("telemetry: records validated")

	var disabled_path := "user://telemetry-disabled.jsonl"
	var disabled := TelemetryStore.new(disabled_path)
	_expect(not disabled.record_run(_recap(10, false)).recorded, "opt-out does not record")
	_expect(not FileAccess.file_exists(disabled_path), "opt-out creates no telemetry file")

	var before_invalid := FileAccess.get_file_as_string(TELEMETRY_PATH)
	_expect(not telemetry.record_run({"schema_version": 999}).ok, "malformed event is rejected")
	_expect(FileAccess.get_file_as_string(TELEMETRY_PATH) == before_invalid, "malformed event cannot corrupt existing log")

	var save := SaveSystem.new(SAVE_PATH)
	var data := save.defaults()
	data.lineage.archive = 12
	data.unlocks = ["deep_reserves"]
	_expect(save.save(data).ok, "progression fixture saves")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TELEMETRY_PATH))
	var loaded := SaveSystem.new(SAVE_PATH).load()
	_expect(loaded.data.lineage.archive == 12 and loaded.data.unlocks == ["deep_reserves"], "deleting telemetry leaves progression unchanged")
	print("telemetry: before quit")

	_cleanup()
	if failures.is_empty():
		print("TelemetryStore tests passed")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _on_watchdog_timeout() -> void:
	push_error("TelemetryStore test watchdog expired")
	quit(2)


func _recap(seed: int, won: bool) -> Dictionary:
	return {
		"schema_version": RunRecap.SCHEMA_VERSION,
		"run_seed": seed,
		"choices": ["predictive_cache"],
		"cycles": [{"cycle": 1, "mutation_id": "predictive_cache", "pressure": 5, "damage": 0, "integrity": 18}],
		"won": won,
		"cause": "final_gate_passed" if won else "integrity_depleted",
		"archive_gained": 20 if won else 5,
		"final_integrity": 18,
	}


func _cleanup() -> void:
	for path in [TELEMETRY_PATH, "user://telemetry-disabled.jsonl", SAVE_PATH, SAVE_PATH + ".tmp"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
