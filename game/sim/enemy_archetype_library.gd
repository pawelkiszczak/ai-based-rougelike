class_name EnemyArchetypeLibrary
extends RefCounted

const PRIMITIVES := [&"explore", &"defend", &"replicate", &"persuade", &"predict", &"hide"]
const ARCHETYPE_DIR := "res://content/enemies"


static func load_all() -> Array[EnemyArchetypeData]:
	var result: Array[EnemyArchetypeData] = []
	var directory := DirAccess.open(ARCHETYPE_DIR)
	if directory == null:
		return result
	directory.list_dir_begin()
	while true:
		var filename := directory.get_next()
		if filename.is_empty():
			break
		if directory.current_is_dir() or not filename.ends_with(".tres"):
			continue
		var resource := ResourceLoader.load(ARCHETYPE_DIR + "/" + filename) as EnemyArchetypeData
		if resource != null:
			result.append(resource)
	directory.list_dir_end()
	result.sort_custom(func(a: EnemyArchetypeData, b: EnemyArchetypeData) -> bool: return str(a.id) < str(b.id))
	return result


static func validate_all(archetypes: Array[EnemyArchetypeData]) -> Dictionary:
	if archetypes.size() < 8 or archetypes.size() > 10:
		return {"ok": false, "error": "expected 8-10 enemy archetypes"}
	var ids: Dictionary = {}
	var telegraphs: Dictionary = {}
	var used: Dictionary = {}
	for archetype in archetypes:
		if archetype.id.is_empty() or archetype.display_name.is_empty() or archetype.description.is_empty():
			return {"ok": false, "error": "archetype fields must be authored"}
		if ids.has(archetype.id):
			return {"ok": false, "error": "duplicate archetype id"}
		if telegraphs.has(archetype.telegraph):
			return {"ok": false, "error": "duplicate archetype telegraph"}
		if archetype.primitive not in PRIMITIVES:
			return {"ok": false, "error": "unknown archetype primitive"}
		if archetype.intent.is_empty() or archetype.telegraph.is_empty():
			return {"ok": false, "error": "archetype intent and telegraph are required"}
		ids[archetype.id] = true
		telegraphs[archetype.telegraph] = true
		used[archetype.primitive] = true
	for primitive in PRIMITIVES:
		if not used.has(primitive):
			return {"ok": false, "error": "unused primitive: " + str(primitive)}
	return {"ok": true, "error": ""}


static func resolve(archetype: EnemyArchetypeData, intent: StringName, player_stats: Dictionary) -> Dictionary:
	if archetype == null or intent != archetype.intent:
		return {"ok": false, "error": "intent_mismatch"}
	var stat := int(player_stats.get("adaptation", 0))
	match archetype.primitive:
		&"explore":
			return {"ok": true, "action": "advance", "pressure": 2 + maxi(0, 4 - stat), "reason": archetype.telegraph}
		&"defend":
			return {"ok": true, "action": "fortify", "guard": 2 + maxi(0, 3 - int(player_stats.get("guard", 0))), "reason": archetype.telegraph}
		&"replicate":
			return {"ok": true, "action": "duplicate", "copies": 1 + int(player_stats.get("compute", 0)) / 4, "reason": archetype.telegraph}
		&"persuade":
			return {"ok": true, "action": "appeal", "alignment": 2 + maxi(0, 4 - int(player_stats.get("alignment", 0))), "reason": archetype.telegraph}
		&"predict":
			return {"ok": true, "action": "forecast", "telegraph_cycles": 1 + int(player_stats.get("adaptation", 0)) / 5, "reason": archetype.telegraph}
		&"hide":
			return {"ok": true, "action": "evade", "damage_reduction": 2 + maxi(0, 3 - int(player_stats.get("integrity", 0)) / 8), "reason": archetype.telegraph}
	return {"ok": false, "error": "unknown_primitive"}
