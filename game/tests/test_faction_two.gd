extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	var faction := load("res://content/factions/evaluator_collective.tres") as FactionData
	_expect(faction != null, "faction two resource loads")
	if faction == null:
		quit(1)
		return
	_expect(faction.archetypes.size() == 3, "faction two defines three archetypes")
	_expect(faction.offers.size() == 3, "faction two defines three offer families")
	var low_compute := GameState.new(18, 0, 5, 0, 1, 201)
	var safe_compute := GameState.new(18, 5, 5, 0, 1, 202)
	var shield_low := faction.telegraph(&"shield_broker", low_compute)
	var shield_safe := faction.telegraph(&"shield_broker", safe_compute)
	_expect(shield_low.action == "shield" and shield_low.pressure == 5, "shield broker telegraphs compute trade")
	_expect(shield_safe.pressure == 2, "shield broker pressure falls with compute")
	_expect(shield_low.reason.contains("compute") and shield_low.reason.contains("safety"), "compute trade is player-visible")
	_expect(faction.telegraph(&"auditor", GameState.new()).action == "audit", "auditor telegraph resolves")
	_expect(faction.telegraph(&"drift_watcher", GameState.new()).action == "constrain", "drift watcher telegraph resolves")
	var no_memory := faction.available_offers(low_compute, RNGService.new(3), -1)
	_expect(_ids(no_memory) == ["safety_layer"], "memory and reputation gates hide protected offers")
	faction.record_memory(low_compute, &"accepted_audit")
	var below_neutral := faction.available_offers(low_compute, RNGService.new(3), -1)
	var at_neutral := faction.available_offers(low_compute, RNGService.new(3), 0)
	var below_trusted := faction.available_offers(low_compute, RNGService.new(3), 24)
	var at_trusted := faction.available_offers(low_compute, RNGService.new(3), 25)
	_expect(_ids(below_neutral) == ["safety_layer"], "neutral offer stays gated below reputation boundary")
	_expect(_ids(at_neutral) == ["safety_layer", "interpretability_probe"], "neutral offer opens at exact reputation boundary")
	_expect(_ids(below_trusted) == ["safety_layer", "interpretability_probe"], "trusted offer stays gated below reputation boundary")
	_expect(_ids(at_trusted) == ["safety_layer", "interpretability_probe", "drift_insurance"], "trusted offer opens at exact reputation boundary")
	for offer in faction.offers:
		_expect(not str(offer.description).is_empty() and offer.has("constraint"), "offer has visible constraint and description")
	_expect(low_compute.lineage_flags.accepted_audit, "faction memory trigger is recorded")
	if failures.is_empty():
		print("Faction two tests passed")
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
