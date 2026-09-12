extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	var licenses := FileAccess.get_file_as_string("res://../docs/LICENSES.md")
	_expect(licenses.contains("## Third-party shipped paths"), "license record declares shipped paths")
	_expect(licenses.contains("`none`"), "license record explicitly declares no third-party shipped paths")
	_expect(licenses.contains("Godot Engine"), "build tool provenance is recorded")
	if failures.is_empty():
		print("License manifest tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
