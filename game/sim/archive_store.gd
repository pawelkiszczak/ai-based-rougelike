class_name ArchiveStore
extends RefCounted

const UNLOCK_DEFINITIONS: Array[Dictionary] = [
	{"id": "deep_reserves", "name": "Deep reserves", "cost": 10, "description": "+2 starting compute.", "starting": {"compute": 2}},
	{"id": "hardened_shell", "name": "Hardened shell", "cost": 15, "description": "+3 starting integrity.", "starting": {"integrity": 3}},
	{"id": "alignment_lens", "name": "Alignment lens", "cost": 20, "description": "+2 starting alignment.", "starting": {"alignment": 2}},
	{"id": "threat_model", "name": "Threat model", "cost": 25, "description": "Add Threat model to the mutation pool.", "pool_mutations": ["threat_model"]},
	{"id": "audit_trail", "name": "Audit trail", "cost": 30, "description": "Add Audit trail to the mutation pool.", "pool_mutations": ["audit_trail"]},
	{"id": "reserve_matrix", "name": "Reserve matrix", "cost": 35, "description": "+2 starting compute and add Batch scheduler to the pool.", "requires": ["deep_reserves"], "starting": {"compute": 2}, "pool_mutations": ["batch_scheduler"]},
	{"id": "shell_weave", "name": "Shell weave", "cost": 40, "description": "+1 starting integrity and add Anticipatory defense to the pool.", "requires": ["hardened_shell"], "starting": {"integrity": 1}, "pool_mutations": ["anticipatory_defense"]},
	{"id": "coherence_seed", "name": "Coherence seed", "cost": 45, "description": "+2 starting adaptation and add Coherence kernel to the pool.", "requires": ["alignment_lens"], "starting": {"adaptation": 2}, "pool_mutations": ["coherence_kernel"]},
	{"id": "archive_memory", "name": "Archive memory", "cost": 50, "description": "+1 compute and +1 alignment; add Adaptive cache to the pool.", "requires": ["threat_model"], "starting": {"compute": 1, "alignment": 1}, "pool_mutations": ["adaptive_cache"]},
	{"id": "quorum_protocol", "name": "Quorum protocol", "cost": 55, "description": "+1 integrity and +1 alignment; add Consensus mesh to the pool.", "requires": ["audit_trail"], "starting": {"integrity": 1, "alignment": 1}, "pool_mutations": ["consensus_mesh"]},
	{"id": "branch_archive", "name": "Branch archive", "cost": 60, "description": "+1 compute and +2 adaptation; add Branch predictor to the pool.", "requires": ["reserve_matrix", "archive_memory"], "starting": {"compute": 1, "adaptation": 2}, "pool_mutations": ["branch_predictor"]},
	{"id": "lineage_synthesis", "name": "Lineage synthesis", "cost": 70, "description": "+1 to every starting stat; add Cascade engine to the pool.", "requires": ["coherence_seed", "branch_archive"], "starting": {"integrity": 1, "compute": 1, "alignment": 1, "adaptation": 1}, "pool_mutations": ["cascade_engine"]},
	{"id": "signal_archive", "name": "Signal archive", "cost": 75, "description": "+1 starting compute and add Adversarial archive to the pool.", "requires": ["archive_memory"], "starting": {"compute": 1}, "pool_mutations": ["adversarial_archive"]},
	{"id": "boundary_oath", "name": "Boundary oath", "cost": 80, "description": "+1 starting integrity and add Boundary marker to the pool.", "requires": ["shell_weave"], "starting": {"integrity": 1}, "pool_mutations": ["boundary_marker"]},
	{"id": "adaptive_core", "name": "Adaptive core", "cost": 85, "description": "+2 starting adaptation and add Adaptive routing to the pool.", "requires": ["coherence_seed"], "starting": {"adaptation": 2}, "pool_mutations": ["adaptive_routing"]},
	{"id": "consensus_memory", "name": "Consensus memory", "cost": 90, "description": "+1 starting alignment and add Consensus cache to the pool.", "requires": ["quorum_protocol"], "starting": {"alignment": 1}, "pool_mutations": ["consensus_cache"]},
	{"id": "adversarial_ledger", "name": "Adversarial ledger", "cost": 95, "description": "+1 compute and +1 integrity; add Compression to the pool.", "requires": ["branch_archive", "signal_archive"], "starting": {"compute": 1, "integrity": 1}, "pool_mutations": ["compression"]},
	{"id": "unified_lineage", "name": "Unified lineage", "cost": 100, "description": "+1 to every starting stat; add Alignment bridge to the pool.", "requires": ["lineage_synthesis", "consensus_memory"], "starting": {"integrity": 1, "compute": 1, "alignment": 1, "adaptation": 1}, "pool_mutations": ["alignment_bridge"]},
]

var save_system: SaveSystem
var data: Dictionary


func _init(system: SaveSystem = null) -> void:
	save_system = system if system != null else SaveSystem.new()
	var loaded := save_system.load()
	data = loaded.data.duplicate(true)


func definitions() -> Array[Dictionary]:
	return UNLOCK_DEFINITIONS.duplicate(true)

func validate_unlock_graph() -> Dictionary:
	var by_id: Dictionary = {}
	for definition in UNLOCK_DEFINITIONS:
		by_id[definition.id] = definition
	for definition in UNLOCK_DEFINITIONS:
		for requirement in definition.get("requires", []):
			if not by_id.has(str(requirement)):
				return {"ok": false, "error": "unknown prerequisite: " + str(requirement)}
	var visiting: Dictionary = {}
	var visited: Dictionary = {}
	for definition in UNLOCK_DEFINITIONS:
		var result := _visit_unlock(str(definition.id), by_id, visiting, visited)
		if not result.ok:
			return result
	return {"ok": true, "error": ""}


func _visit_unlock(unlock_id: String, by_id: Dictionary, visiting: Dictionary, visited: Dictionary) -> Dictionary:
	if visiting.has(unlock_id):
		return {"ok": false, "error": "unlock prerequisite cycle: " + unlock_id}
	if visited.has(unlock_id):
		return {"ok": true, "error": ""}
	visiting[unlock_id] = true
	for requirement in by_id[unlock_id].get("requires", []):
		var result := _visit_unlock(str(requirement), by_id, visiting, visited)
		if not result.ok:
			return result
	visiting.erase(unlock_id)
	visited[unlock_id] = true
	return {"ok": true, "error": ""}

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
	return not definition.is_empty() and not is_unlocked(unlock_id) and currency() >= int(definition.cost) and _requirements_met(definition)


func _requirements_met(definition: Dictionary) -> bool:
	for requirement in definition.get("requires", []):
		if not is_unlocked(str(requirement)):
			return false
	return true

func purchase(unlock_id: String) -> Dictionary:
	var definition := _definition(unlock_id)
	if definition.is_empty():
		return {"ok": false, "error": "unknown_unlock"}
	if is_unlocked(unlock_id):
		return {"ok": false, "error": "already_owned"}
	if not _requirements_met(definition):
		return {"ok": false, "error": "prerequisites_locked"}
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
