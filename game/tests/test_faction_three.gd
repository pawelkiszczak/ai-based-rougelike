extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	var faction := load("res://content/factions/boundary_union.tres") as FactionData
	_expect(faction != null, "faction three resource loads")
	if faction == null:
		quit(1)
		return
	_expect(faction.archetypes.size() == 3, "faction three defines three archetypes")
	_expect(faction.offers.size() == 3, "faction three defines three offer families")
	var low_adaptation := GameState.new(18, 5, 5, 0, 1, 301)
	var high_adaptation := GameState.new(18, 5, 5, 8, 1, 302)
	var harmonizer := faction.telegraph(&"harmonizer", low_adaptation)
	var limiter := faction.telegraph(&"adaptation_limiter", high_adaptation)
	_expect(harmonizer.action == "align" and harmonizer.pressure == 2, "harmonizer rewards alignment")
	_expect(harmonizer.reason.contains("alignment") and harmonizer.reason.contains("adaptation"), "alignment strategy is player-visible")
	_expect(limiter.action == "limit" and limiter.pressure == 7, "adaptation limiter constrains growth")
	_expect(faction.telegraph(&"resonance_keeper", high_adaptation).action == "resonate", "resonance keeper telegraph resolves")
	var no_memory := faction.available_offers(low_adaptation, RNGService.new(5), -1)
	_expect(_ids(no_memory) == ["alignment_accord"], "memory and reputation gates hide advanced alignment offers")
	faction.record_memory(low_adaptation, &"accepted_bargain")
	var at_neutral := faction.available_offers(low_adaptation, RNGService.new(5), 0)
	var below_trusted := faction.available_offers(low_adaptation, RNGService.new(5), 24)
	var at_trusted := faction.available_offers(low_adaptation, RNGService.new(5), 25)
	_expect(_ids(at_neutral) == ["adaptive_brake", "alignment_accord"], "neutral alignment offer opens at exact reputation boundary")
	_expect(_ids(below_trusted) == ["adaptive_brake", "alignment_accord"], "trusted alignment offer stays gated below boundary")
	_expect(_ids(at_trusted) == ["adaptive_brake", "alignment_accord", "convergence_charter"], "trusted alignment offer opens at exact boundary")
	for offer in faction.offers:
		_expect(int(offer.alignment_gain) > 0 and int(offer.adaptation_cost) > 0 and offer.has("constraint"), "offer balances alignment against adaptation")
	_expect(low_adaptation.lineage_flags.accepted_bargain, "faction memory trigger is recorded")
	if failures.is_empty():
		print("Faction three tests passed")
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
