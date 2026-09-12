class_name MutationLibrary
extends RefCounted

const RESOURCE_DIR := "res://content/mutations"


static var last_error := ""


static func load_all(resource_dir: String = RESOURCE_DIR, strict: bool = false) -> Array[MutationData]:
	last_error = ""
	var directory := DirAccess.open(resource_dir)
	if directory == null:
		last_error = "mutation directory is missing: " + resource_dir
		push_error(last_error)
		return []

	var paths: Array[String] = []
	directory.list_dir_begin()
	while true:
		var filename := directory.get_next()
		if filename.is_empty():
			break
		if directory.current_is_dir() or not filename.ends_with(".tres"):
			continue
		paths.append(filename)
	directory.list_dir_end()
	paths.sort()

	var mutations: Array[MutationData] = []
	for filename in paths:
		var resource_path := resource_dir + "/" + filename
		var mutation: MutationData = load(resource_path) as MutationData
		if mutation == null:
			last_error = "invalid mutation resource: " + resource_path
			push_error(last_error)
			if strict:
				return []
			continue
		mutations.append(mutation)
	return mutations
