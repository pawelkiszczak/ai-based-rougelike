class_name ControllerNavigation
extends RefCounted


static func configure_row(controls: Array[Control]) -> void:
	var usable: Array[Control] = []
	for candidate in controls:
		var disabled := candidate is BaseButton and (candidate as BaseButton).disabled
		if is_instance_valid(candidate) and candidate.visible and not disabled:
			usable.append(candidate)
	for index in usable.size():
		var control := usable[index]
		var left := usable[(index - 1 + usable.size()) % usable.size()]
		var right := usable[(index + 1) % usable.size()]
		control.focus_neighbor_left = control.get_path_to(left)
		control.focus_neighbor_right = control.get_path_to(right)


static func configure_column(controls: Array[Control]) -> void:
	var usable: Array[Control] = []
	for candidate in controls:
		var disabled := candidate is BaseButton and (candidate as BaseButton).disabled
		if is_instance_valid(candidate) and candidate.visible and not disabled:
			usable.append(candidate)
	for index in usable.size():
		var control := usable[index]
		var top := usable[(index - 1 + usable.size()) % usable.size()]
		var bottom := usable[(index + 1) % usable.size()]
		control.focus_neighbor_top = control.get_path_to(top)
		control.focus_neighbor_bottom = control.get_path_to(bottom)


static func prompt(action: String, joypad_active: bool) -> String:
	return "%s %s" % [("A" if joypad_active else "Enter"), action]
