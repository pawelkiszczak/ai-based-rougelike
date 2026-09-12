class_name MutationLibrary
extends RefCounted

const RESOURCE_DIR := "res://content/mutations"


static func load_all() -> Array[MutationData]:
	var directory := DirAccess.open(RESOURCE_DIR)
	if directory == null:
		push_error("Mutation resource directory is missing: " + RESOURCE_DIR)
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
		var mutation: MutationData = load(RESOURCE_DIR + "/" + filename) as MutationData
		if mutation == null:
			push_error("Mutation resource is not MutationData: " + filename)
			continue
		mutations.append(mutation)
	return mutations
