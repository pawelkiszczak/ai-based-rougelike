extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	var faction := load("res://content/factions/signal_court.tres") as FactionData
	_expect(faction != null, "faction resource loads")
	if faction == null:
		quit(1)
		return
	_expect(faction.archetypes.size() == 3, "faction defines three archetypes")
	var low := GameState.new(18, 0, 0, 0, 1, 101)
	var high := GameState.new(18, 12, 12, 9, 1, 102)
	var sentinel_low := faction.telegraph(&"sentinel", low)
	var sentinel_high := faction.telegraph(&"sentinel", high)
	_expect(sentinel_low.action == "fortify" and sentinel_low.pressure == 3, "sentinel low boundary is exact")
	_expect(sentinel_high.pressure == 6, "sentinel scales with adaptation")
	_expect(faction.telegraph(&"oracle", low).action == "predict", "oracle has distinct action")
	_expect(faction.telegraph(&"oracle", high).pressure == 10, "oracle scales with alignment")
	_expect(faction.telegraph(&"parasite", low).pressure == 8, "parasite exploits compute scarcity")
	_expect(faction.telegraph(&"parasite", high).pressure == 4, "parasite pressure falls with compute")

	var no_memory := faction.available_offers(low, RNGService.new(7))
	_expect(no_memory.size() == 1 and no_memory[0].id == &"shared_protocol", "memory-gated offers stay hidden")
	faction.record_memory(low)
	var first := faction.available_offers(low, RNGService.new(7))
	var second := faction.available_offers(low, RNGService.new(7))
	_expect(first == second and first.size() == 3, "offers are deterministic for seed and history")
	_expect(low.lineage_flags.faction_memory, "faction memory flag is recorded")
	if failures.is_empty():
		print("FactionData tests passed")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
