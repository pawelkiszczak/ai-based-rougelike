class_name ArchiveStore
extends RefCounted

const UNLOCK_DEFINITIONS: Array[Dictionary] = [
	{"id": "deep_reserves", "name": "Deep reserves", "cost": 10, "description": "+2 starting compute."},
	{"id": "hardened_shell", "name": "Hardened shell", "cost": 15, "description": "+3 starting integrity."},
	{"id": "audit_memory", "name": "Audit memory", "cost": 20, "description": "Preserve one lineage flag."},
]

var save_system: SaveSystem
var data: Dictionary


func _init(system: SaveSystem = null) -> void:
	save_system = system if system != null else SaveSystem.new()
	var loaded := save_system.load()
	data = loaded.data.duplicate(true)


func definitions() -> Array[Dictionary]:
	return UNLOCK_DEFINITIONS.duplicate(true)


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
	next_data.lineage.archive = currency() - cost
	next_data.unlocks.append(unlock_id)
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
