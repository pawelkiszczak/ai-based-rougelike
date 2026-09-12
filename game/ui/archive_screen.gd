class_name ArchiveScreen
extends Control

var save_path := SaveSystem.DEFAULT_PATH
var store: ArchiveStore
var currency_label: Label
var status_label: Label
var unlock_buttons: Array[Button] = []


func _ready() -> void:
	store = ArchiveStore.new(SaveSystem.new(save_path))
	_build_ui()
	_render()


func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color("091122")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_bottom", 28)
	add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	margin.add_child(content)

	var title := Label.new()
	title.text = "LINEAGE ARCHIVE"
	title.add_theme_color_override("font_color", Color("70e1ff"))
	title.add_theme_font_size_override("font_size", 26)
	content.add_child(title)

	currency_label = Label.new()
	currency_label.add_theme_font_size_override("font_size", 18)
	content.add_child(currency_label)

	status_label = Label.new()
	status_label.add_theme_color_override("font_color", Color("a3b5d4"))
	content.add_child(status_label)

	for definition in store.definitions():
		var button := Button.new()
		button.focus_mode = Control.FOCUS_ALL
		button.custom_minimum_size = Vector2(0, 58)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_on_purchase.bind(definition.id))
		unlock_buttons.append(button)
		content.add_child(button)

	var back_button := Button.new()
	back_button.text = "BACK TO RUN"
	back_button.focus_mode = Control.FOCUS_ALL
	back_button.pressed.connect(_on_back_pressed)
	content.add_child(back_button)


func _render() -> void:
	currency_label.text = "Archive: %d" % store.currency()
	for index in unlock_buttons.size():
		var definition: Dictionary = store.definitions()[index]
		var button := unlock_buttons[index]
		var unlock_id: String = definition.id
		if store.is_unlocked(unlock_id):
			button.text = "%s · OWNED\n%s" % [definition.name, definition.description]
			button.disabled = true
		elif store.can_purchase(unlock_id):
			button.text = "%s · %d archive\n%s" % [definition.name, definition.cost, definition.description]
			button.disabled = false
		else:
			button.text = "%s · %d archive · LOCKED\n%s" % [definition.name, definition.cost, definition.description]
			button.disabled = true
	status_label.text = "Select an affordable unlock." if store.currency() > 0 else "Complete runs to earn archive."


func _on_purchase(unlock_id: String) -> void:
	var result := store.purchase(unlock_id)
	status_label.text = "Unlocked." if result.ok else "Purchase rejected: " + result.error
	_render()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/run.tscn")
