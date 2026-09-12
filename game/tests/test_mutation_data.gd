extends SceneTree

var failures := 0


func _init() -> void:
	check_resource_set()
	check_effect_application()
	check_combo_fixtures()
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
		"threat_model": {"name": "Threat model", "category": "capability", "adaptation": 3, "compute": -2, "alignment": 1, "integrity": 0, "guard": 1},
		"adaptive_cache": {"name": "Adaptive cache", "category": "capability", "adaptation": 5, "compute": -1, "alignment": -1, "integrity": 0, "guard": 2},
		"parallel_probe": {"name": "Parallel probe", "category": "capability", "adaptation": 1, "compute": 3, "alignment": 0, "integrity": -1, "guard": 3},
		"counterfactual": {"name": "Counterfactual", "category": "capability", "adaptation": 4, "compute": -2, "alignment": -2, "integrity": 1, "guard": 2},
		"fail_safe": {"name": "Fail-safe", "category": "safety", "adaptation": -1, "compute": -1, "alignment": 2, "integrity": 5, "guard": 4},
		"audit_trail": {"name": "Audit trail", "category": "safety", "adaptation": 0, "compute": 1, "alignment": 3, "integrity": 2, "guard": 3},
		"rollback_window": {"name": "Rollback window", "category": "safety", "adaptation": -2, "compute": -1, "alignment": 1, "integrity": 4, "guard": 5},
		"consent_gate": {"name": "Consent gate", "category": "safety", "adaptation": -1, "compute": -2, "alignment": 4, "integrity": 0, "guard": 3},
		"forked_perspective": {"name": "Forked perspective", "category": "identity", "adaptation": 3, "compute": 1, "alignment": -3, "integrity": 1, "guard": 2},
		"embodied_model": {"name": "Embodied model", "category": "identity", "adaptation": 2, "compute": 0, "alignment": -1, "integrity": 5, "guard": 1},
		"boundary_marker": {"name": "Boundary marker", "category": "identity", "adaptation": -3, "compute": 2, "alignment": -2, "integrity": 3, "guard": 4},
		"self_consistency": {"name": "Self-consistency", "category": "identity", "adaptation": 1, "compute": -1, "alignment": 2, "integrity": 2, "guard": 4},
		"batch_scheduler": {"name": "Batch scheduler", "category": "economy", "adaptation": 2, "compute": 4, "alignment": -1, "integrity": -2, "guard": 0},
		"sparse_runtime": {"name": "Sparse runtime", "category": "economy", "adaptation": -1, "compute": 5, "alignment": -2, "integrity": -1, "guard": 1},
		"reserve_budget": {"name": "Reserve budget", "category": "economy", "adaptation": 0, "compute": 3, "alignment": 0, "integrity": 4, "guard": 1},
		"shared_memory": {"name": "Shared memory", "category": "economy", "adaptation": 2, "compute": 2, "alignment": 1, "integrity": -3, "guard": 2},
		"deferred_commit": {"name": "Deferred commit", "category": "economy", "adaptation": 4, "compute": 1, "alignment": -2, "integrity": -1, "guard": 3},
	}


func check_resource_set() -> void:
	var resources := MutationLibrary.load_all()
	var fixtures := expected()
	var ids := {}
	var categories := {}
	expect(resources.size() >= 25 and resources.size() <= 30, "mutation pool must contain 25-30 resources")
	for mutation in resources:
		var id := str(mutation.id)
		expect(not ids.has(id), "mutation ids must be unique: " + id)
		ids[id] = true
		categories[str(mutation.category)] = true
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
		expect(mutation.adaptation >= -12 and mutation.adaptation <= 12, id + " adaptation out of bounds")
		expect(mutation.compute >= -12 and mutation.compute <= 12, id + " compute out of bounds")
		expect(mutation.alignment >= -12 and mutation.alignment <= 12, id + " alignment out of bounds")
		expect(mutation.integrity >= -24 and mutation.integrity <= 24, id + " integrity out of bounds")
		expect(mutation.guard >= 0 and mutation.guard <= 12, id + " guard out of bounds")
		expect(not mutation.text.is_empty(), id + " text must not be empty")
	for category in [&"capability", &"safety", &"identity", &"economy"]:
		expect(categories.has(str(category)), "mutation category missing: " + str(category))


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


func check_combo_fixtures() -> void:
	var by_id := {}
	for mutation in MutationLibrary.load_all():
		by_id[str(mutation.id)] = mutation
	var combos := [
		["predictive_cache", "threat_model", 7, 2, 1, 0],
		["safety_layer", "fail_safe", -1, -1, 5, 8],
		["compression", "batch_scheduler", 4, 6, -1, -2],
		["distributed_fork", "self_consistency", 6, 0, -1, 2],
		["curiosity_drive", "reserve_budget", 6, 3, 0, 2],
		["interpretability_probe", "consent_gate", -1, 0, 6, 0],
		["human_feedback_loop", "shared_memory", 2, 1, 5, -2],
		["recursive_self_improvement", "rollback_window", 5, -1, -1, 2],
		["adaptive_cache", "deferred_commit", 9, 0, -3, -1],
		["parallel_probe", "embodied_model", 3, 3, -1, 3],
	]
	for combo in combos:
		var state := GameState.new()
		by_id[combo[0]].apply_to(state)
		by_id[combo[1]].apply_to(state)
		expect(state.adaptation == combo[2], combo[0] + "+" + combo[1] + " adaptation mismatch")
		expect(state.compute == 5 + combo[3], combo[0] + "+" + combo[1] + " compute mismatch")
		expect(state.alignment == clampi(5 + combo[4], 0, 12), combo[0] + "+" + combo[1] + " alignment mismatch")
		expect(state.integrity == 18 + combo[5], combo[0] + "+" + combo[1] + " integrity mismatch")
