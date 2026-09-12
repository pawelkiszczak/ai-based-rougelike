extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://build_metadata.json"))
	_expect(parsed is Dictionary, "build metadata is a JSON object")
	if parsed is Dictionary:
		for key in ["version", "source_commit", "build_timestamp", "channel"]:
			_expect(parsed.has(key) and not str(parsed[key]).is_empty(), "build metadata has " + key)
	if failures.is_empty():
		print("Build metadata tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
