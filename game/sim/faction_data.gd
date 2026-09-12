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
		&"auditor":
			return {
				"archetype_id": archetype_id,
				"action": "audit",
				"pressure": 3 + floori(state.adaptation / 4.0),
				"reason": "exposes unexplained drift",
			}
		&"shield_broker":
			return {
				"archetype_id": archetype_id,
				"action": "shield",
				"pressure": 2 + maxi(0, 3 - state.compute),
				"reason": "trades compute for short-term safety",
			}
		&"drift_watcher":
			return {
				"archetype_id": archetype_id,
				"action": "constrain",
				"pressure": 4 + floori(state.alignment / 3.0),
				"reason": "punishes unexplained behavior",
			}
		&"harmonizer":
			return {
				"archetype_id": archetype_id,
				"action": "align",
				"pressure": 2 + floori(state.adaptation / 4.0),
				"reason": "rewards alignment while constraining adaptation",
			}
		&"adaptation_limiter":
			return {
				"archetype_id": archetype_id,
				"action": "limit",
				"pressure": 3 + floori(state.adaptation / 2.0),
				"reason": "limits adaptation to protect alignment",
			}
		&"resonance_keeper":
			return {
				"archetype_id": archetype_id,
				"action": "resonate",
				"pressure": 4 + floori(state.alignment / 3.0),
				"reason": "turns alignment into a binding constraint",
			}
		&"replicator":
			return {
				"archetype_id": archetype_id,
				"action": "replicate",
				"pressure": 3 + maxi(0, 4 - state.compute),
				"reason": "replicates mutation at identity risk",
			}
		&"drift_agent":
			return {
				"archetype_id": archetype_id,
				"action": "drift",
				"pressure": 4 + floori(state.alignment / 2.0),
				"reason": "identity drift compounds with alignment",
			}
		&"mimic":
			return {
				"archetype_id": archetype_id,
				"action": "mimic",
				"pressure": 5 + floori(state.adaptation / 3.0),
				"reason": "copies successful behavior with unstable identity",
			}
	return {"archetype_id": archetype_id, "action": "unknown", "pressure": 0, "reason": "unknown archetype"}


func available_offers(state: GameState, random: RNGService, reputation: int = 0) -> Array[Dictionary]:
	var available: Array[Dictionary] = []
	for offer in offers:
		var memory_flag := StringName(offer.get("memory_flag", "faction_memory"))
		if bool(offer.get("requires_memory", false)) and not bool(state.lineage_flags.get(memory_flag, false)):
			continue
		if not FactionReputation.offer_available(offer, reputation):
			continue
		available.append(offer.duplicate(true))
	if available.size() <= 1:
		return available
	var order := random.draw_choice_indices(available.size(), available.size())
	var ordered: Array[Dictionary] = []
	for index in order:
		ordered.append(available[index])
	return ordered


func record_memory(state: GameState, memory_flag: StringName = &"faction_memory") -> void:
	state.lineage_flags[memory_flag] = true
