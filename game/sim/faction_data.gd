class_name FactionData
extends Resource

@export var id: StringName
@export var display_name: String
@export var archetypes: Array[Dictionary] = []
@export var offers: Array[Dictionary] = []


func telegraph(archetype_id: StringName, state: GameState) -> Dictionary:
	match archetype_id:
		&"sentinel":
			return {
				"archetype_id": archetype_id,
				"action": "fortify",
				"pressure": 3 + floori(state.adaptation / 3.0),
				"reason": "defends against rising adaptation",
			}
		&"oracle":
			return {
				"archetype_id": archetype_id,
				"action": "predict",
				"pressure": 4 + floori(state.alignment / 2.0),
				"reason": "predicts alignment patterns",
			}
		&"parasite":
			return {
				"archetype_id": archetype_id,
				"action": "exploit",
				"pressure": 4 + maxi(0, 4 - state.compute),
				"reason": "exploits compute scarcity",
			}
	return {"archetype_id": archetype_id, "action": "unknown", "pressure": 0, "reason": "unknown archetype"}


func available_offers(state: GameState, random: RNGService) -> Array[Dictionary]:
	var memory := bool(state.lineage_flags.get("faction_memory", false))
	var available: Array[Dictionary] = []
	for offer in offers:
		if bool(offer.get("requires_memory", false)) and not memory:
			continue
		available.append(offer.duplicate(true))
	if available.size() <= 1:
		return available
	var order := random.draw_choice_indices(available.size(), available.size())
	var ordered: Array[Dictionary] = []
	for index in order:
		ordered.append(available[index])
	return ordered


func record_memory(state: GameState) -> void:
	state.lineage_flags["faction_memory"] = true
