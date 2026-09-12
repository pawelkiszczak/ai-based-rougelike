extends SceneTree

const SAVE_PATH := "user://archive-screen-test.json"

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_cleanup()
	var seed_save := SaveSystem.new(SAVE_PATH)
	var seed_data := seed_save.defaults()
	seed_data.lineage.archive = 20
	_expect(seed_save.save(seed_data).ok, "archive fixture save succeeds")

	var screen := preload("res://scenes/archive.tscn").instantiate() as ArchiveScreen
	screen.save_path = SAVE_PATH
	get_root().add_child(screen)
	await process_frame
	_expect(screen.currency_label.text == "Archive: 20", "archive screen renders currency")
	_expect(screen.unlock_buttons[0].focus_mode == Control.FOCUS_ALL, "unlock is keyboard/controller focusable")
	_expect(not screen.unlock_buttons[0].disabled, "affordable unlock is enabled")

	(screen.unlock_buttons[0] as Button).emit_signal("pressed")
	await process_frame
	_expect(screen.store.is_unlocked("deep_reserves"), "purchase marks unlock owned")
	_expect(screen.store.currency() == 10, "purchase deducts exact cost")
	_expect(screen.unlock_buttons[0].disabled, "owned unlock cannot be purchased twice")

	var reloaded := ArchiveStore.new(SaveSystem.new(SAVE_PATH))
	_expect(reloaded.is_unlocked("deep_reserves"), "unlock survives save/load")
	_expect(reloaded.currency() == 10, "currency survives save/load")
	_expect(reloaded.purchase("deep_reserves").error == "already_owned", "duplicate purchase is rejected")

	var poor_path := "user://archive-screen-poor.json"
	var poor_save := SaveSystem.new(poor_path)
	var poor_data := poor_save.defaults()
	poor_data.lineage.archive = 0
	poor_save.save(poor_data)
	var poor_store := ArchiveStore.new(poor_save)
	_expect(poor_store.purchase("deep_reserves").error == "insufficient_funds", "insufficient funds are rejected")
	_expect(poor_store.currency() == 0, "currency never falls below zero")

	screen.queue_free()
	_cleanup()
	if failures.is_empty():
		print("ArchiveScreen tests passed")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)




func _cleanup() -> void:
	for path in [SAVE_PATH, SAVE_PATH + ".tmp", "user://archive-screen-poor.json", "user://archive-screen-poor.json.tmp"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
