class_name SaveSystem
extends RefCounted

const CURRENT_VERSION := 1
const MAX_SAVE_BYTES := 100 * 1024
const DEFAULT_PATH := "user://save.json"

var path: String
var _save_locked := false


func _init(save_path: String = DEFAULT_PATH) -> void:
	path = save_path


func defaults() -> Dictionary:
	return {
		"version": CURRENT_VERSION,
		"revision": 0,
		"last_run_id": "",
		"architecture": "default",
		"lineage": {"archive": 0, "runs": 0, "wins": 0},
		"unlocks": [],
		"reputation": {},
		"stats": {},
		"settings": {},
		"narrative": {"flags": {}, "history": []},
	}


func load() -> Dictionary:
	if not FileAccess.file_exists(path):
		_save_locked = false
		return {"status": "missing", "data": defaults(), "message": "No save exists."}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return recover_corrupt("could not open save")
	var raw := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(raw)
	if not parsed is Dictionary:
		return recover_corrupt("save is not a JSON object")
	if not parsed.has("version") or not (parsed.version is int or parsed.version is float):
		return recover_corrupt("save has no numeric version")
	parsed["version"] = int(parsed.version)
	if parsed.version > CURRENT_VERSION:
		_save_locked = true
		return {
			"status": "unsupported_newer",
			"data": defaults(),
			"message": "This save was created by a newer version and was not changed.",
		}

	var migrated: Dictionary = parsed.duplicate(true)
	if migrated.has("revision") and (migrated.revision is int or migrated.revision is float):
		migrated["revision"] = int(migrated.revision)
	if migrated.has("lineage") and migrated.lineage is Dictionary:
		var migrated_lineage: Dictionary = migrated["lineage"]
		for key in ["archive", "runs", "wins"]:
			if migrated_lineage.has(key) and (migrated_lineage[key] is int or migrated_lineage[key] is float):
				migrated_lineage[key] = int(migrated_lineage[key])
		migrated["lineage"] = migrated_lineage
	var migrated_from := int(migrated.version)
	if migrated_from < CURRENT_VERSION:
		migrated = migrate(migrated, migrated_from)
	if not migrated.has("architecture"):
		migrated["architecture"] = "default"
	var validation := validate(migrated)
	if not validation.ok:
		return recover_corrupt(validation.error)
	_save_locked = false
	return {
		"status": "migrated" if migrated_from < CURRENT_VERSION else "loaded",
		"data": normalise(migrated),
		"message": "",
	}


func save(input: Dictionary) -> Dictionary:
	if _save_locked:
		return {"ok": false, "revision": 0, "error": "save_locked_for_newer_version"}

	var document := normalise(input)
	var validation := validate(document)
	if not validation.ok:
		return {"ok": false, "revision": 0, "error": validation.error}

	var encoded := JSON.stringify(document)
	if encoded.to_utf8_buffer().size() > MAX_SAVE_BYTES:
		return {"ok": false, "revision": 0, "error": "save_exceeds_size_limit"}

	var temp_path := path + ".tmp"
	var temp_file := FileAccess.open(temp_path, FileAccess.WRITE)
	if temp_file == null:
		return {"ok": false, "revision": 0, "error": "could_not_open_temporary_save"}
	temp_file.store_string(encoded)
	temp_file.flush()
	temp_file.close()

	var rename_error := DirAccess.rename_absolute(_absolute(temp_path), _absolute(path))
	if rename_error != OK:
		return {"ok": false, "revision": 0, "error": "could_not_replace_save"}
	return {"ok": true, "revision": document.revision, "error": ""}


func recover_corrupt(reason: String) -> Dictionary:
	_save_locked = false
	var backup_path := _backup_corrupt()
	return {
		"status": "recovered",
		"data": defaults(),
		"message": reason,
		"backup_path": backup_path,
	}


func migrate(document: Dictionary, from_version: int) -> Dictionary:
	var migrated := document.duplicate(true)
	if from_version == 0:
		if not migrated.has("revision"):
			migrated["revision"] = 0
		if not migrated.has("last_run_id"):
			migrated["last_run_id"] = ""
		migrated["version"] = CURRENT_VERSION
	if not migrated.has("architecture"):
		migrated["architecture"] = "default"
	if not migrated.has("reputation"):
		migrated["reputation"] = {}
	return migrated


func normalise(input: Dictionary) -> Dictionary:
	var document := defaults()
	if input.has("revision") and input.revision is int:
		document.revision = maxi(0, input.revision) + 1
	else:
		document.revision = 1
	if input.has("last_run_id") and input.last_run_id is String:
		document.last_run_id = input.last_run_id
	if input.has("architecture") and input.architecture is String:
		document.architecture = input.architecture
	if input.has("lineage") and input.lineage is Dictionary:
		var lineage: Dictionary = document["lineage"]
		for key in ["archive", "runs", "wins"]:
			if input.lineage.has(key) and (input.lineage[key] is int or input.lineage[key] is float):
				lineage[key] = maxi(0, int(input.lineage[key]))
		document["lineage"] = lineage
	if input.has("unlocks") and input.unlocks is Array:
		document["unlocks"] = input.unlocks.duplicate()
	if input.has("reputation") and input.reputation is Dictionary:
		document["reputation"] = input.reputation.duplicate(true)
	if input.has("stats") and input.stats is Dictionary:
		document["stats"] = input.stats.duplicate(true)
	if input.has("settings") and input.settings is Dictionary:
		document["settings"] = input.settings.duplicate(true)
	if input.has("narrative") and input.narrative is Dictionary:
		document["narrative"] = input.narrative.duplicate(true)
	return document

func validate(document: Dictionary) -> Dictionary:
	for key in ["version", "revision", "last_run_id", "architecture", "lineage", "unlocks", "reputation", "stats", "settings", "narrative"]:
		if not document.has(key):
			return {"ok": false, "error": "missing field: " + key}
	if not document.version is int or document.version != CURRENT_VERSION:
		return {"ok": false, "error": "unsupported save version"}
	if not document.revision is int or document.revision < 0:
		return {"ok": false, "error": "invalid revision"}
	if not document.last_run_id is String or not document.architecture is String or document.architecture.is_empty():
		return {"ok": false, "error": "invalid run selection"}
	if not document.last_run_id is String:
		return {"ok": false, "error": "invalid last_run_id"}
	if not document.lineage is Dictionary:
		return {"ok": false, "error": "invalid lineage"}
	for key in ["archive", "runs", "wins"]:
		if not document.lineage.has(key) or not document.lineage[key] is int or document.lineage[key] < 0:
			return {"ok": false, "error": "invalid lineage field: " + key}
	if not document.unlocks is Array:
		return {"ok": false, "error": "invalid unlocks"}
	for unlock in document.unlocks:
		if not unlock is String:
			return {"ok": false, "error": "invalid unlock id"}
	if not document.reputation is Dictionary:
		return {"ok": false, "error": "invalid reputation"}
	for faction_id in document.reputation:
		if not faction_id is String or not (document.reputation[faction_id] is int or document.reputation[faction_id] is float):
			return {"ok": false, "error": "invalid reputation entry"}
	if not document.stats is Dictionary or not document.settings is Dictionary:
		return {"ok": false, "error": "invalid structured fields"}
	if not document.narrative is Dictionary or not document.narrative.get("flags", {}) is Dictionary or not document.narrative.get("history", []) is Array:
		return {"ok": false, "error": "invalid narrative"}
	return {"ok": true, "error": ""}


func _backup_corrupt() -> String:
	if not FileAccess.file_exists(path):
		return ""
	var timestamp := int(Time.get_unix_time_from_system())
	var backup := "%s.corrupt.%d.json" % [path, timestamp]
	var suffix := 1
	while FileAccess.file_exists(backup):
		backup = "%s.corrupt.%d.%d.json" % [path, timestamp, suffix]
		suffix += 1
	var error := DirAccess.rename_absolute(_absolute(path), _absolute(backup))
	return backup if error == OK else ""


func _absolute(relative_path: String) -> String:
	return ProjectSettings.globalize_path(relative_path)
