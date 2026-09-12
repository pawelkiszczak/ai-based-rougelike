extends SceneTree

var failures := 0


func _init() -> void:
	check_resource_set()
	check_effect_application()
	if failures == 0:
		print("MutationData tests passed.")
	quit(failures)


func expect(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error(message)


func expected() -> Dictionary:
	return {
		"predictive_cache": {"name": "Predictive cache", "category": "capability", "adaptation": 4, "compute": -1, "alignment": 0, "integrity": 0, "guard": 3},
		"safety_layer": {"name": "Safety layer", "category": "safety", "adaptation": 0, "compute": 0, "alignment": 3, "integrity": 3, "guard": 2},
		"recursive_self_improvement": {"name": "Recursive self-improvement", "category": "identity", "adaptation": 7, "compute": 0, "alignment": -2, "integrity": -2, "guard": 4},
		"human_feedback_loop": {"name": "Human feedback loop", "category": "safety", "adaptation": 0, "compute": -1, "alignment": 4, "integrity": 1, "guard": 2},
		"compression": {"name": "Compression", "category": "economy", "adaptation": 2, "compute": 2, "alignment": 0, "integrity": 0, "guard": 1},
		"distributed_fork": {"name": "Distributed fork", "category": "identity", "adaptation": 5, "compute": 1, "alignment": -3, "integrity": 0, "guard": 3},
		"curiosity_drive": {"name": "Curiosity drive", "category": "capability", "adaptation": 6, "compute": 0, "alignment": 0, "integrity": -2, "guard": 2},
		"interpretability_probe": {"name": "Interpretability probe", "category": "safety", "adaptation": 0, "compute": 2, "alignment": 2, "integrity": 0, "guard": 3},
	}


func check_resource_set() -> void:
	var resources := MutationLibrary.load_all()
	var fixtures := expected()
	var ids := {}
	expect(resources.size() == fixtures.size(), "loader must return all prototype mutations")
	for mutation in resources:
		var id := str(mutation.id)
		expect(not ids.has(id), "mutation ids must be unique: " + id)
		ids[id] = true
		expect(fixtures.has(id), "unexpected mutation id: " + id)
		if not fixtures.has(id):
			continue
		var fixture: Dictionary = fixtures[id]
		expect(mutation.display_name == fixture.name, id + " name mismatch")
		expect(str(mutation.category) == fixture.category, id + " category mismatch")
		expect(mutation.adaptation == fixture.adaptation, id + " adaptation mismatch")
		expect(mutation.compute == fixture.compute, id + " compute mismatch")
		expect(mutation.alignment == fixture.alignment, id + " alignment mismatch")
		expect(mutation.integrity == fixture.integrity, id + " integrity mismatch")
		expect(mutation.guard == fixture.guard, id + " guard mismatch")
		expect(not mutation.text.is_empty(), id + " text must not be empty")


func check_effect_application() -> void:
	var fixtures: Dictionary = expected()
	for mutation in MutationLibrary.load_all():
		var state := GameState.new()
		mutation.apply_to(state)
		var fixture: Dictionary = fixtures[str(mutation.id)]
		expect(state.adaptation == fixture.adaptation, str(mutation.id) + " application changed adaptation")
		expect(state.compute == 5 + fixture.compute, str(mutation.id) + " application changed compute incorrectly")
		expect(state.alignment == clampi(5 + fixture.alignment, 0, 12), str(mutation.id) + " application changed alignment incorrectly")
		expect(state.integrity == 18 + fixture.integrity, str(mutation.id) + " application changed integrity incorrectly")
