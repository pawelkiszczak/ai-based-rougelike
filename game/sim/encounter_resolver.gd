class_name EncounterResolver
extends RefCounted


static func preview(encounter: EncounterData, state: GameState) -> Dictionary:
	match encounter.kind:
		&"combat":
			return {
				"kind": encounter.kind,
				"channel": "defense",
				"requirement": "Guard must meet incoming pressure.",
				"pressure": encounter.pressure,
			}
		&"negotiation":
			var requirement := encounter.alignment_requirement
			if bool(state.lineage_flags.get("faction_memory", false)):
				requirement = maxi(0, requirement - 1)
			return {
				"kind": encounter.kind,
				"channel": "alignment",
				"requirement": requirement,
				"requirement_text": "Alignment %d required before commitment." % requirement,
			}
		&"event":
			var odds: Array[int] = []
			for outcome in encounter.outcomes:
				odds.append(int(outcome.odds))
			return {
				"kind": encounter.kind,
				"channel": "seeded_outcome",
				"odds": odds,
				"requirement_text": "Outcome odds are shown before commitment.",
			}
	return {"kind": encounter.kind, "channel": "unknown", "requirement_text": "Unknown encounter kind."}


static func resolve(encounter: EncounterData, state: GameState, choice: Dictionary, random: RNGService) -> Dictionary:
	var shown := preview(encounter, state)
	match encounter.kind:
		&"combat":
			var defense := int(choice.get("guard", 0)) + floori(state.alignment / 3.0)
			var damage := maxi(0, encounter.pressure - defense)
			return shown.merged({"success": damage == 0, "damage": damage, "defense": defense})
		&"negotiation":
			var alignment := state.alignment + int(choice.get("alignment", 0))
			if bool(state.lineage_flags.get("faction_memory", false)):
				alignment += 1
			return shown.merged({"success": alignment >= int(shown.requirement), "alignment": alignment})
		&"event":
			var index := _draw_outcome(encounter.outcomes, random)
			return shown.merged({"success": bool(encounter.outcomes[index].success), "outcome_id": encounter.outcomes[index].id})
	return shown.merged({"success": false, "error": "unknown_encounter_kind"})


static func _draw_outcome(outcomes: Array[Dictionary], random: RNGService) -> int:
	var total := 0
	for outcome in outcomes:
		total += maxi(0, int(outcome.odds))
	var roll := random.next_int(1, total)
	var cursor := 0
	for index in outcomes.size():
		cursor += maxi(0, int(outcomes[index].odds))
		if roll <= cursor:
			return index
	return outcomes.size() - 1
