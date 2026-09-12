class_name RunScreen
extends Control

const CHOICE_COUNT := 3
const RUN_LOG_LIMIT := 8

var controller: RunController
var mutations: Array[MutationData] = []
var choice_container: HBoxContainer
var stats_labels: Dictionary = {}
var status_label: Label
var log_label: Label
var end_button: Button


func _ready() -> void:
	_build_ui()
	mutations = MutationLibrary.load_all()
	start_run(int(Time.get_unix_time_from_system()))


func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color("091122")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	margin.add_child(content)

	var title := Label.new()
	title.text = "EMERGENCE PROTOCOL"
	title.add_theme_color_override("font_color", Color("70e1ff"))
	title.add_theme_font_size_override("font_size", 26)
	content.add_child(title)

	status_label = Label.new()
	status_label.add_theme_color_override("font_color", Color("a3b5d4"))
	content.add_child(status_label)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	content.add_child(body)

	var stats_panel := PanelContainer.new()
	stats_panel.custom_minimum_size = Vector2(180, 0)
	body.add_child(stats_panel)
	var stats_box := VBoxContainer.new()
	stats_box.add_theme_constant_override("separation", 7)
	stats_panel.add_child(stats_box)
	var stats_title := Label.new()
	stats_title.text = "RUN STATE"
	stats_title.add_theme_color_override("font_color", Color("70e1ff"))
	stats_box.add_child(stats_title)
	for key in ["integrity", "compute", "alignment", "adaptation"]:
		var label := Label.new()
		stats_labels[key] = label
		stats_box.add_child(label)

	var run_box := VBoxContainer.new()
	run_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	run_box.add_theme_constant_override("separation", 8)
	body.add_child(run_box)

	var choice_title := Label.new()
	choice_title.text = "CHOOSE A MUTATION"
	choice_title.add_theme_color_override("font_color", Color("70e1ff"))
	run_box.add_child(choice_title)
	choice_container = HBoxContainer.new()
	choice_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choice_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	choice_container.add_theme_constant_override("separation", 8)
	run_box.add_child(choice_container)

	var log_title := Label.new()
	log_title.text = "RUN LOG"
	log_title.add_theme_color_override("font_color", Color("70e1ff"))
	run_box.add_child(log_title)
	log_label = Label.new()
	log_label.custom_minimum_size = Vector2(0, 76)
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_label.add_theme_color_override("font_color", Color("a3b5d4"))
	run_box.add_child(log_label)

	end_button = Button.new()
	end_button.text = "INITIALIZE SUCCESSOR"
	end_button.visible = false
	end_button.pressed.connect(_on_successor_pressed)
	run_box.add_child(end_button)


func start_run(run_seed: int) -> void:
	var initial_state := GameState.new(18, 5, 5, 0, 1, run_seed)
	controller = RunController.new(initial_state, RNGService.new(run_seed))
	controller.state_changed.connect(_on_state_changed)
	controller.run_ended.connect(_on_run_ended)
	end_button.visible = false
	_render()


func _on_state_changed(_state: GameState) -> void:
	_render()


func _on_run_ended(_result: Dictionary) -> void:
	_render()


func _on_choice(mutation: MutationData) -> void:
	if controller == null or controller.ended:
		return
	for child in choice_container.get_children():
		(child as Button).disabled = true
	controller.choose(mutation)


func _on_successor_pressed() -> void:
	start_run(int(Time.get_unix_time_from_system()))


func _render() -> void:
	if controller == null:
		return
	var state := controller.state
	stats_labels["integrity"].text = "Integrity: %d / %d" % [state.integrity, GameState.MAX_INTEGRITY]
	stats_labels["compute"].text = "Compute: %d / %d" % [state.compute, GameState.MAX_COMPUTE]
	stats_labels["alignment"].text = "Alignment: %d / %d" % [state.alignment, GameState.MAX_ALIGNMENT]
	stats_labels["adaptation"].text = "Adaptation: %d" % state.adaptation
	if not controller.ended:
		status_label.text = "Cycle %d / %d · seed %d" % [state.cycle, RunController.MAX_CYCLES, state.run_seed]
	_render_choices()
	_render_log()


func _render_choices() -> void:
	_clear_choices()
	if controller.ended:
		end_button.visible = true
		return
	end_button.visible = false
	for mutation in controller.draw_choices(mutations, CHOICE_COUNT):
		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 150)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var telegraph := controller.damage_range(controller.state, mutation)
		button.text = "%s\n\n%s\n\n%s\n%s" % [mutation.display_name, mutation.text, _effect_text(mutation), _telegraph_text(telegraph)]
		button.tooltip_text = mutation.text
		button.pressed.connect(_on_choice.bind(mutation))
		choice_container.add_child(button)


func _render_log() -> void:
	var entries: Array[String] = []
	var first := maxi(0, controller.run_log.size() - RUN_LOG_LIMIT)
	for index in range(first, controller.run_log.size()):
		var entry: Dictionary = controller.run_log[index]
		var line := "Cycle %d · %s · damage %d · integrity %d" % [entry.cycle, entry.mutation_id, entry.damage, entry.integrity]
		if entry.ended:
			line += " · " + ("WON" if entry.won else "ENDED")
		entries.append(line)
	log_label.text = "\n".join(entries) if not entries.is_empty() else "No mutations selected."


func _clear_choices() -> void:
	for child in choice_container.get_children():
		child.queue_free()


func _effect_text(mutation: MutationData) -> String:
	var effects: Array[String] = []
	for item in [
		["Integrity", mutation.integrity],
		["Compute", mutation.compute],
		["Alignment", mutation.alignment],
		["Adaptation", mutation.adaptation],
	]:
		if item[1] != 0:
			effects.append("%s %s" % [item[0], _signed(item[1])])
	return ", ".join(effects) if not effects.is_empty() else "No stat change"


func _telegraph_text(telegraph: Dictionary) -> String:
	return "Incoming damage %d–%d · %s (%s)" % [telegraph.min, telegraph.max, telegraph.source, telegraph.reason]


func _signed(value: int) -> String:
	return ("+" if value >= 0 else "") + str(value)
