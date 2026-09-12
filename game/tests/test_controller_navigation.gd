extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	var root := Control.new()
	get_root().add_child(root)
	var row: Array[Control] = []
	var column: Array[Control] = []
	for index in 3:
		var button := Button.new()
		button.name = "Button%d" % index
		root.add_child(button)
		row.append(button)
		column.append(button)
	ControllerNavigation.configure_row(row)
	ControllerNavigation.configure_column(column)
	for button in row:
		_expect(not button.focus_neighbor_left.is_empty(), "row control has left focus neighbor")
		_expect(not button.focus_neighbor_right.is_empty(), "row control has right focus neighbor")
		_expect(not button.focus_neighbor_top.is_empty(), "column control has top focus neighbor")
		_expect(not button.focus_neighbor_bottom.is_empty(), "column control has bottom focus neighbor")
	_expect(ControllerNavigation.prompt("SELECT", true) == "A SELECT", "active pad uses controller glyph")
	_expect(ControllerNavigation.prompt("SELECT", false) == "Enter SELECT", "keyboard keeps keyboard prompt")
	root.queue_free()
	if failures.is_empty():
		print("ControllerNavigation tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
