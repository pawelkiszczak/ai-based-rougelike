class_name TelemetryStore
extends RefCounted

const SCHEMA_VERSION := 1
const DEFAULT_PATH := "user://telemetry.jsonl"

var path: String
var enabled := false


func _init(log_path: String = DEFAULT_PATH, opt_in: bool = false) -> void:
	path = log_path
	enabled = opt_in


func record_run(recap: Dictionary, duration_ms: int = 0) -> Dictionary:
	if not enabled:
		return {"ok": true, "recorded": false, "error": ""}
	var validation := RunRecap.validate(recap)
	if not validation.ok:
		return {"ok": false, "recorded": false, "error": validation.error}
	var event := {
		"schema_version": SCHEMA_VERSION,
		"run_seed": recap.run_seed,
		"choices": recap.choices.duplicate(),
		"death_cycle": -1 if recap.won else (recap.cycles.back().cycle if not recap.cycles.is_empty() else 0),
		"cause": recap.cause,
		"duration_ms": maxi(0, duration_ms),
		"outcome": "win" if recap.won else "loss",
	}
	var file := FileAccess.open(path, FileAccess.READ_WRITE)
	if file == null:
		file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "recorded": false, "error": "could_not_open_telemetry"}
	file.seek_end()
	file.store_string(JSON.stringify(event) + "\n")
	file.flush()
	file.close()
	return {"ok": true, "recorded": true, "error": ""}


func validate_line(line: String) -> Dictionary:
	var event = JSON.parse_string(line)
	if not event is Dictionary:
		return {"ok": false, "error": "telemetry event is not an object"}
	for key in ["schema_version", "run_seed", "choices", "death_cycle", "cause", "duration_ms", "outcome"]:
		if not event.has(key):
			return {"ok": false, "error": "missing telemetry field: " + key}
	if event.schema_version != SCHEMA_VERSION or not event.choices is Array:
		return {"ok": false, "error": "invalid telemetry schema"}
	if event.outcome not in ["win", "loss"]:
		return {"ok": false, "error": "invalid telemetry outcome"}
	return {"ok": true, "error": ""}
