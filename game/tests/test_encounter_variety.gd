extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	var combat := load("res://content/encounters/combat_probe.tres") as EncounterData
	var negotiation := load("res://content/encounters/negotiation_probe.tres") as EncounterData
	var event := load("res://content/encounters/event_probe.tres") as EncounterData
	_expect(combat != null and negotiation != null and event != null, "all environment one encounter resources load")
	if combat == null or negotiation == null or event == null:
		quit(1)
		return

	var combat_preview := EncounterResolver.preview(combat, GameState.new(18, 5, 5, 0, 1, 401))
	_expect(combat_preview.channel == "defense" and combat_preview.pressure == 7, "combat exposes pressure and defense channel")
	_expect(EncounterResolver.resolve(combat, GameState.new(), {"guard": 6}, RNGService.new(1)).success, "combat succeeds at exact defense boundary")
	_expect(not EncounterResolver.resolve(combat, GameState.new(), {"guard": 5}, RNGService.new(1)).success, "combat fails below defense boundary")

	var negotiation_state := GameState.new(18, 5, 5, 0, 1, 402)
	_expect(EncounterResolver.preview(negotiation, negotiation_state).requirement == 6, "negotiation shows alignment requirement")
	_expect(not EncounterResolver.resolve(negotiation, negotiation_state, {}, RNGService.new(1)).success, "negotiation rejects below alignment requirement")
	negotiation_state.lineage_flags["faction_memory"] = true
	var remembered := EncounterResolver.preview(negotiation, negotiation_state)
	_expect(remembered.requirement == 5, "faction memory lowers negotiation requirement")
	_expect(EncounterResolver.resolve(negotiation, negotiation_state, {}, RNGService.new(1)).success, "faction memory makes boundary negotiation reachable")

	var event_preview := EncounterResolver.preview(event, GameState.new())
	_expect(event_preview.channel == "seeded_outcome" and event_preview.odds == [3, 1], "event displays configured odds before commitment")
	var first_event := EncounterResolver.resolve(event, GameState.new(), {}, RNGService.new(403))
	var second_event := EncounterResolver.resolve(event, GameState.new(), {}, RNGService.new(403))
	_expect(first_event == second_event, "same event seed gives identical outcome")
	_expect(first_event.outcome_id == &"stabilized" or first_event.outcome_id == &"cascade", "event reaches every configured outcome id")

	if failures.is_empty():
		print("Encounter variety tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
