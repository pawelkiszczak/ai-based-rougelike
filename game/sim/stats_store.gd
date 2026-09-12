class_name StatsStore
extends RefCounted

const DEFAULT_STATS := {
	"runs": 0,
	"wins": 0,
	"best_build": {"adaptation": 0, "alignment": 0, "compute": 0},
	"environment_records": {},
	"processed_run_ids": [],
	"codex_unlocked": {},
}

var save_system: SaveSystem
var stats: Dictionary
var codex_entries: Dictionary


func _init(system: SaveSystem = null, entries: Dictionary = {}) -> void:
	save_system = system if system != null else SaveSystem.new()
	codex_entries = entries.duplicate(true) if not entries.is_empty() else authored_codex_entries()
	var loaded := save_system.load()
	stats = _normalise(loaded.data.get("stats", {}))


func process_run(run_result: Dictionary, codex_ids: Array[String] = []) -> Dictionary:
	var run_id := str(run_result.get("run_id", ""))
	if run_id.is_empty():
		return {"ok": false, "processed": false, "error": "run_id_required"}
	if run_id in stats.processed_run_ids:
		return {"ok": true, "processed": false, "error": ""}
	var ids: Array = run_result.get("codex_ids", codex_ids)
	for entity_id in ids:
		if not codex_entries.has(str(entity_id)):
			return {"ok": false, "processed": false, "error": "unknown_codex_entity: " + str(entity_id)}
	var next_stats := stats.duplicate(true)
	next_stats.runs += 1
	if bool(run_result.get("won", false)):
		next_stats.wins += 1
	for key in ["adaptation", "alignment", "compute"]:
		next_stats.best_build[key] = maxi(int(next_stats.best_build.get(key, 0)), int(run_result.get(key, 0)))
	var environment_id := str(run_result.get("environment_id", ""))
	if not environment_id.is_empty():
		var record: Dictionary = next_stats.environment_records.get(environment_id, {"runs": 0, "wins": 0})
		record.runs += 1
		if bool(run_result.get("won", false)):
			record.wins += 1
		next_stats.environment_records[environment_id] = record
	next_stats.processed_run_ids.append(run_id)
	for entity_id in ids:
		next_stats.codex_unlocked[str(entity_id)] = true
	var save_data := save_system.load().data.duplicate(true)
	save_data["stats"] = next_stats
	var saved := save_system.save(save_data)
	if not saved.ok:
		return {"ok": false, "processed": false, "error": saved.error}
	stats = next_stats
	return {"ok": true, "processed": true, "revision": saved.revision, "error": ""}


func runs() -> int:
	return int(stats.runs)


func wins() -> int:
	return int(stats.wins)


func is_codex_unlocked(entity_id: String) -> bool:
	return bool(stats.codex_unlocked.get(entity_id, false))


func codex() -> Dictionary:
	return stats.codex_unlocked.duplicate(true)


static func authored_codex_entries() -> Dictionary:
	var entries := {}
	for directory_path in [
		"res://content/mutations",
		"res://content/encounters",
		"res://content/factions",
		"res://content/environments",
		"res://content/bosses",
		"res://content/events",
	]:
		var directory := DirAccess.open(directory_path)
		if directory == null:
			continue
		directory.list_dir_begin()
		while true:
			var filename := directory.get_next()
			if filename.is_empty():
				break
			if directory.current_is_dir() or not filename.ends_with(".tres"):
				continue
			var entity_id: String = filename.trim_suffix(".tres")
			entries[entity_id] = entity_id
		directory.list_dir_end()
	return entries
static func validate_codex_mapping(authored: Dictionary, entries: Dictionary) -> Dictionary:
	for entity_id in authored:
		if not entries.has(entity_id):
			return {"ok": false, "error": "missing codex entry: " + str(entity_id)}
	for entity_id in entries:
		if not authored.has(entity_id):
			return {"ok": false, "error": "orphan codex entry: " + str(entity_id)}
	return {"ok": true, "error": ""}


func _normalise(input: Dictionary) -> Dictionary:
	var output := DEFAULT_STATS.duplicate(true)
	for key in ["runs", "wins"]:
		output[key] = maxi(0, int(input.get(key, 0)))
	if input.get("best_build", {}) is Dictionary:
		for key in output.best_build:
			output.best_build[key] = maxi(0, int(input.best_build.get(key, 0)))
	if input.get("environment_records", {}) is Dictionary:
		output.environment_records = input.environment_records.duplicate(true)
	if input.get("processed_run_ids", []) is Array:
		output.processed_run_ids = input.processed_run_ids.duplicate()
	if input.get("codex_unlocked", {}) is Dictionary:
		output.codex_unlocked = input.codex_unlocked.duplicate(true)
	return output
