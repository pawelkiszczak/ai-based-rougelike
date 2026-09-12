extends SceneTree

const TEST_PATH := "user://save-system-test.json"
var failures := 0


func _init() -> void:
	clear_test_files()
	check_round_trip_and_revision()
	check_older_version_migration()
	check_newer_version_protection()
	check_corrupt_save_recovery()
	check_invalid_field_recovery()
	check_size_limit_and_atomic_replace()
	clear_test_files()
	if failures == 0:
		print("SaveSystem tests passed.")
	quit(failures)


func expect(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error(message)


func fixture() -> Dictionary:
	return {
		"last_run_id": "run-001",
		"lineage": {"archive": 42, "runs": 3, "wins": 1},
		"unlocks": ["safety_layer"],
		"stats": {"best_adaptation": 18},
		"settings": {"text_scale": 1},
		"narrative": "generated prose must not be persisted",
	}


func write_raw(raw: String) -> void:
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string(raw)
	file.close()


func read_raw() -> String:
	var file := FileAccess.open(TEST_PATH, FileAccess.READ)
	if file == null:
		return ""
	var raw := file.get_as_text()
	file.close()
	return raw


func clear_test_files() -> void:
	var directory := DirAccess.open(ProjectSettings.globalize_path("user://"))
	if directory == null:
		return
	directory.list_dir_begin()
	while true:
		var filename := directory.get_next()
		if filename.is_empty():
			break
		if filename.begins_with("save-system-test.json"):
			DirAccess.remove_absolute(ProjectSettings.globalize_path("user://" + filename))
	directory.list_dir_end()


func check_round_trip_and_revision() -> void:
	var system := SaveSystem.new(TEST_PATH)
	var first := system.save(fixture())
	expect(first.ok, "initial save must succeed")
	expect(first.revision == 1, "initial save must receive revision one")
	var loaded := system.load()
	expect(loaded.status == "loaded", "current save must load")
	expect(loaded.data.lineage.archive == 42, "lineage archive must survive round trip")
	expect(loaded.data.unlocks == ["safety_layer"], "unlock ids must survive round trip")
	expect(loaded.data.narrative.flags.is_empty() and loaded.data.narrative.history.is_empty(), "structured narrative state defaults without prose")
	var second := system.save(loaded.data)
	expect(second.revision == 2, "saving loaded data must increment revision")


func check_older_version_migration() -> void:
	clear_test_files()
	write_raw(JSON.stringify({"version": 0, "lineage": {"archive": 9, "runs": 2, "wins": 0}, "unlocks": [], "stats": {}, "settings": {}}))
	var loaded := SaveSystem.new(TEST_PATH).load()
	expect(loaded.status == "migrated", "older version must migrate")
	expect(loaded.data.version == SaveSystem.CURRENT_VERSION, "migration must produce current version")
	expect(loaded.data.lineage.archive == 9, "migration must preserve archive")


func check_newer_version_protection() -> void:
	clear_test_files()
	var newer := {"version": SaveSystem.CURRENT_VERSION + 1, "revision": 8, "last_run_id": "future", "lineage": {"archive": 90, "runs": 8, "wins": 4}, "unlocks": ["future_unlock"], "stats": {}, "settings": {}}
	var raw := JSON.stringify(newer)
	write_raw(raw)
	var system := SaveSystem.new(TEST_PATH)
	var loaded := system.load()
	expect(loaded.status == "unsupported_newer", "newer version must be refused")
	var refused := system.save(fixture())
	expect(not refused.ok, "locked newer save must reject overwrite")
	expect(read_raw() == raw, "newer save bytes must remain unchanged")


func check_corrupt_save_recovery() -> void:
	clear_test_files()
	write_raw("{\"version\":")
	var loaded := SaveSystem.new(TEST_PATH).load()
	expect(loaded.status == "recovered", "corrupt save must enter recovery")
	expect(not loaded.backup_path.is_empty(), "corrupt save must report its backup")
	expect(FileAccess.file_exists(loaded.backup_path), "corrupt save backup must exist")
	expect(not FileAccess.file_exists(TEST_PATH), "recovery must remove the active corrupt path")


func check_invalid_field_recovery() -> void:
	clear_test_files()
	write_raw(JSON.stringify({"version": 1, "revision": 1, "last_run_id": "run", "lineage": {"archive": "bad", "runs": 1, "wins": 0}, "unlocks": [], "stats": {}, "settings": {}}))
	var loaded := SaveSystem.new(TEST_PATH).load()
	expect(loaded.status == "recovered", "invalid field types must enter recovery")
	expect(not loaded.backup_path.is_empty(), "invalid save must be backed up")


func check_size_limit_and_atomic_replace() -> void:
	clear_test_files()
	var system := SaveSystem.new(TEST_PATH)
	expect(system.save(fixture()).ok, "baseline save must succeed")
	var before := read_raw()
	var oversized := fixture()
	oversized.stats = {"large": "x".repeat(SaveSystem.MAX_SAVE_BYTES)}
	var rejected := system.save(oversized)
	expect(not rejected.ok, "oversized save must be rejected")
	expect(read_raw() == before, "rejected oversized save must preserve active save")
	expect(system.save({"last_run_id": "run-002", "lineage": {"archive": 1, "runs": 1, "wins": 0}, "unlocks": [], "stats": {}, "settings": {}}).ok, "replacement save must succeed")
	expect(not FileAccess.file_exists(TEST_PATH + ".tmp"), "successful atomic replacement must remove temporary file")
