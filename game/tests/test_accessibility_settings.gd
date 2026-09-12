extends SceneTree

const SAVE_PATH := "user://accessibility-settings-test.json"
var failures: Array[String] = []


func _init() -> void:
	_cleanup()
	var settings := AccessibilitySettings.new()
	_expect(settings.set_text_scale(2) and settings.text_scale() == 1.5, "largest text scale is available")
	_expect(not settings.set_text_scale(3), "unsupported text scale is rejected")
	_expect(settings.remap_action("choose", "ButtonSouth"), "known action accepts a remap")
	_expect(not settings.remap_action("unknown", "x"), "unknown action remap is rejected")
	_expect(not settings.remap_action("choose", "   "), "empty remap is rejected")
	_expect(settings.save(SaveSystem.new(SAVE_PATH)).ok, "accessibility settings save succeeds")
	var loaded := AccessibilitySettings.new()
	loaded.load(SaveSystem.new(SAVE_PATH))
	_expect(loaded.text_scale() == 1.5, "text scale survives save/load")
	_expect(loaded.binding_for("choose") == "buttonsouth", "custom binding survives save/load")
	_expect(loaded.binding_for("open_archive") == "a", "default bindings remain intact")
	_cleanup()
	if failures.is_empty():
		print("AccessibilitySettings tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _cleanup() -> void:
	for path in [SAVE_PATH, SAVE_PATH + ".tmp"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
