class_name EventTemplateLibrary
extends RefCounted

const DEFAULT_DIRECTORY := "res://content/events"
static var last_error := ""


static func load_all(directory_path: String = DEFAULT_DIRECTORY, strict: bool = false) -> Array[EventTemplateData]:
	last_error = ""
	var directory := DirAccess.open(directory_path)
	if directory == null:
		last_error = "event template directory not found: " + directory_path
		return []
	var paths: Array[String] = []
	directory.list_dir_begin()
	while true:
		var filename := directory.get_next()
		if filename.is_empty():
			break
		if not directory.current_is_dir() and filename.ends_with(".tres"):
			paths.append(directory_path.path_join(filename))
	directory.list_dir_end()
	paths.sort()
	var templates: Array[EventTemplateData] = []
	for path in paths:
		var template := load(path) as EventTemplateData
		if template == null:
			last_error = "failed to load event template: " + path
			if strict:
				return []
			continue
		templates.append(template)
	return templates


static func validate_all(templates: Array[EventTemplateData]) -> Dictionary:
	for template in templates:
		var validation := template.validate()
		if not validation.ok:
			return validation
	return {"ok": true, "error": ""}
