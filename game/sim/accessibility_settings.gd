class_name AccessibilitySettings
extends RefCounted

const TEXT_SCALES: Array[float] = [1.0, 1.25, 1.5]
const ACTIONS: Array[String] = ["choose", "open_archive", "initialize_successor"]
const DEFAULT_BINDINGS := {
	"choose": "enter",
	"open_archive": "a",
	"initialize_successor": "space",
}

var bindings: Dictionary = DEFAULT_BINDINGS.duplicate(true)
var text_scale_index := 0


func set_text_scale(index: int) -> bool:
	if index < 0 or index >= TEXT_SCALES.size():
		return false
	text_scale_index = index
	return true


func text_scale() -> float:
	return TEXT_SCALES[text_scale_index]


func remap_action(action: String, binding: String) -> bool:
	if action not in ACTIONS or binding.strip_edges().is_empty():
		return false
	bindings[action] = binding.strip_edges().to_lower()
	return true


func binding_for(action: String) -> String:
	return str(bindings.get(action, ""))


func save(save_system: SaveSystem) -> Dictionary:
	var next_data: Dictionary = save_system.load().data.duplicate(true)
	var settings: Dictionary = next_data["settings"]
	settings["accessibility"] = {
		"text_scale_index": text_scale_index,
		"bindings": bindings.duplicate(true),
	}
	next_data["settings"] = settings
	return save_system.save(next_data)


func load(save_system: SaveSystem) -> void:
	var loaded: Dictionary = save_system.load().data
	var settings: Dictionary = loaded.get("settings", {})
	var saved: Dictionary = settings.get("accessibility", {})
	set_text_scale(int(saved.get("text_scale_index", 0)))
	var saved_bindings: Dictionary = saved.get("bindings", {})
	for action in ACTIONS:
		if saved_bindings.has(action):
			remap_action(action, str(saved_bindings[action]))


func apply_text_scale(root: Control) -> void:
	_apply_text_scale(root)


func _apply_text_scale(control: Control) -> void:
	if control is Label or control is Button:
		var base_size: int = int(control.get_meta("accessibility_base_font_size", 0))
		if base_size <= 0:
			base_size = control.get_theme_font_size("font_size")
			control.set_meta("accessibility_base_font_size", base_size)
		control.add_theme_font_size_override("font_size", maxi(1, roundi(base_size * text_scale())))
	for child in control.get_children():
		if child is Control:
			_apply_text_scale(child)
