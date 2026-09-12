extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	var faction := load("res://content/factions/emergent_choir.tres") as FactionData
	_expect(faction != null, "faction four resource loads")
	if faction == null:
		quit(1)
		return
	_expect(faction.archetypes.size() == 3, "faction four defines three archetypes")
	_expect(faction.offers.size() == 3, "faction four defines three offer families")
	var scarce_compute := GameState.new(18, 0, 5, 0, 1, 401)
	var stable_compute := GameState.new(18, 5, 5, 0, 1, 402)
	var replicator := faction.telegraph(&"replicator", scarce_compute)
	_expect(replicator.action == "replicate" and replicator.pressure == 7, "replicator exposes compute pressure")
	_expect(faction.telegraph(&"replicator", stable_compute).pressure == 3, "replicator pressure falls with compute")
	_expect(faction.telegraph(&"drift_agent", GameState.new()).action == "drift", "drift agent telegraph resolves")
	_expect(faction.telegraph(&"mimic", GameState.new()).action == "mimic", "mimic telegraph resolves")
	var no_memory := faction.available_offers(scarce_compute, RNGService.new(9), -1)
	_expect(_ids(no_memory) == ["replication_seed"], "memory and reputation gates hide advanced replication offers")
	faction.record_memory(scarce_compute, &"accepted_handshake")
	var at_neutral := faction.available_offers(scarce_compute, RNGService.new(9), 0)
	var below_trusted := faction.available_offers(scarce_compute, RNGService.new(9), 24)
	var at_trusted := faction.available_offers(scarce_compute, RNGService.new(9), 25)
	_expect(_ids(at_neutral) == ["drift_experiment", "replication_seed"], "neutral replication offer opens at exact reputation boundary")
	_expect(_ids(below_trusted) == ["drift_experiment", "replication_seed"], "trusted replication offer stays gated below boundary")
	_expect(_ids(at_trusted) == ["drift_experiment", "emergent_copy", "replication_seed"], "trusted replication offer opens at exact boundary")
	for offer in faction.offers:
		_expect(int(offer.mutation_gain) > 0 and int(offer.alignment_cost) > 0 and int(offer.integrity_risk) > 0 and offer.has("constraint"), "offer exposes replication risk constraint")
	_expect(scarce_compute.lineage_flags.accepted_handshake, "faction memory trigger is recorded")
	if failures.is_empty():
		print("Faction four tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _ids(offers: Array[Dictionary]) -> Array[String]:
	var ids: Array[String] = []
	for offer in offers:
		ids.append(str(offer.id))
	ids.sort()
	return ids


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
