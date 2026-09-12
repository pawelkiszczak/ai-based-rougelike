class_name ArchiveStore
extends RefCounted

const UNLOCK_DEFINITIONS: Array[Dictionary] = [
	{"id": "deep_reserves", "name": "Deep reserves", "cost": 10, "description": "+2 starting compute.", "starting": {"compute": 2}},
	{"id": "hardened_shell", "name": "Hardened shell", "cost": 15, "description": "+3 starting integrity.", "starting": {"integrity": 3}},
	{"id": "alignment_lens", "name": "Alignment lens", "cost": 20, "description": "+2 starting alignment.", "starting": {"alignment": 2}},
	{"id": "threat_model", "name": "Threat model", "cost": 25, "description": "Add Threat model to the mutation pool.", "pool_mutations": ["threat_model"]},
	{"id": "audit_trail", "name": "Audit trail", "cost": 30, "description": "Add Audit trail to the mutation pool.", "pool_mutations": ["audit_trail"]},
]

var save_system: SaveSystem
var data: Dictionary


func _init(system: SaveSystem = null) -> void:
	save_system = system if system != null else SaveSystem.new()
	var loaded := save_system.load()
	data = loaded.data.duplicate(true)


func definitions() -> Array[Dictionary]:
	return UNLOCK_DEFINITIONS.duplicate(true)

func starting_state(run_seed: int) -> GameState:
	var state := GameState.new(18, 5, 5, 0, 1, run_seed)
	for definition in UNLOCK_DEFINITIONS:
		if not is_unlocked(definition.id):
			continue
		var starting: Dictionary = definition.get("starting", {})
		state.integrity += int(starting.get("integrity", 0))
		state.compute += int(starting.get("compute", 0))
		state.alignment += int(starting.get("alignment", 0))
		state.adaptation += int(starting.get("adaptation", 0))
	state.clamp_stats()
	return state


func eligible_mutations(all_mutations: Array[MutationData]) -> Array[MutationData]:
	var locked_ids := {}
	for definition in UNLOCK_DEFINITIONS:
		for mutation_id in definition.get("pool_mutations", []):
			if not is_unlocked(definition.id):
				locked_ids[mutation_id] = true
	var eligible: Array[MutationData] = []
	for mutation in all_mutations:
		if not locked_ids.has(str(mutation.id)):
			eligible.append(mutation)
	return eligible


func currency() -> int:
	return maxi(0, int(data.lineage.get("archive", 0)))


func is_unlocked(unlock_id: String) -> bool:
	return unlock_id in data.unlocks


func can_purchase(unlock_id: String) -> bool:
	var definition := _definition(unlock_id)
	return not definition.is_empty() and not is_unlocked(unlock_id) and currency() >= int(definition.cost)


func purchase(unlock_id: String) -> Dictionary:
	var definition := _definition(unlock_id)
	if definition.is_empty():
		return {"ok": false, "error": "unknown_unlock"}
	if is_unlocked(unlock_id):
		return {"ok": false, "error": "already_owned"}
	var cost := int(definition.cost)
	if currency() < cost:
		return {"ok": false, "error": "insufficient_funds"}

	var next_data := data.duplicate(true)
	var lineage: Dictionary = next_data["lineage"]
	lineage["archive"] = currency() - cost
	next_data["lineage"] = lineage
	next_data["unlocks"].append(unlock_id)
	var saved := save_system.save(next_data)
	if not saved.ok:
		return {"ok": false, "error": saved.error}
	next_data.revision = saved.revision
	data = next_data
	return {"ok": true, "unlock_id": unlock_id, "currency": currency(), "revision": saved.revision}


func _definition(unlock_id: String) -> Dictionary:
	for definition in UNLOCK_DEFINITIONS:
		if definition.id == unlock_id:
			return definition
	return {}
