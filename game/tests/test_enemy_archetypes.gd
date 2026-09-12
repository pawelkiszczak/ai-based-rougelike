extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	var archetypes := EnemyArchetypeLibrary.load_all()
	var validation := EnemyArchetypeLibrary.validate_all(archetypes)
	_expect(validation.ok, "all authored archetypes validate")
	var by_primitive: Dictionary = {}
	for archetype in archetypes:
		by_primitive[archetype.primitive] = archetype
	for primitive in EnemyArchetypeLibrary.PRIMITIVES:
		_expect(by_primitive.has(primitive), "primitive is exercised: " + str(primitive))
		if not by_primitive.has(primitive):
			continue
		var archetype: EnemyArchetypeData = by_primitive[primitive]
		var stats := {"adaptation": 0, "compute": 0, "alignment": 0, "guard": 0, "integrity": 18}
		var first := EnemyArchetypeLibrary.resolve(archetype, archetype.intent, stats)
		var second := EnemyArchetypeLibrary.resolve(archetype, archetype.intent, stats)
		_expect(first.ok and first == second, "primitive is deterministic: " + str(primitive))
		_expect(not EnemyArchetypeLibrary.resolve(archetype, &"wrong_intent", stats).ok, "intent mismatch is rejected")
	_expect(archetypes.size() == 8, "eight archetypes are authored")
	if failures.is_empty():
		print("EnemyArchetype tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
