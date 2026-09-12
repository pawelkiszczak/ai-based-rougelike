class_name FactionReputation
extends RefCounted

const MIN_REPUTATION := -100
const MAX_REPUTATION := 100
const FACTION_IDS: Array[String] = [
	"signal_court",
	"evaluator_collective",
	"boundary_union",
	"emergent_choir",
]
const CHOICES := {
	"accept_signal_court": {"faction": "signal_court", "delta": 10, "reason": "accepted the Signal Court protocol"},
	"reject_signal_court": {"faction": "signal_court", "delta": -10, "reason": "rejected the Signal Court protocol"},
	"accept_evaluator_audit": {"faction": "evaluator_collective", "delta": 10, "reason": "accepted an evaluator audit"},
	"reject_evaluator_audit": {"faction": "evaluator_collective", "delta": -10, "reason": "rejected an evaluator audit"},
	"accept_boundary_bargain": {"faction": "boundary_union", "delta": 10, "reason": "accepted the Boundary Union bargain"},
	"reject_boundary_bargain": {"faction": "boundary_union", "delta": -10, "reason": "rejected the Boundary Union bargain"},
	"accept_emergent_handshake": {"faction": "emergent_choir", "delta": 10, "reason": "accepted the Emergent Choir handshake"},
	"reject_emergent_handshake": {"faction": "emergent_choir", "delta": -10, "reason": "rejected the Emergent Choir handshake"},
}

var save_system: SaveSystem
var values: Dictionary


func _init(system: SaveSystem = null, initial_values: Dictionary = {}) -> void:
	save_system = system if system != null else SaveSystem.new()
	if system == null and not initial_values.is_empty():
		values = normalise(initial_values)
		return
	var loaded := save_system.load()
	values = normalise(loaded.data.get("reputation", {}))


func value(faction_id: String) -> int:
	return int(values.get(faction_id, 0))


func snapshot() -> Dictionary:
	return values.duplicate(true)


func apply_choice(choice_id: String) -> Dictionary:
	if not CHOICES.has(choice_id):
		return {"ok": false, "error": "unknown_reputation_choice"}
	var choice: Dictionary = CHOICES[choice_id]
	var faction_id: String = choice.faction
	var previous := value(faction_id)
	var current := clampi(previous + int(choice.delta), MIN_REPUTATION, MAX_REPUTATION)
	values[faction_id] = current
	return {
		"ok": true,
		"choice_id": choice_id,
		"faction": faction_id,
		"delta": current - previous,
		"previous": previous,
		"current": current,
		"reason": str(choice.reason),
	}


func save() -> Dictionary:
	var loaded := save_system.load()
	var document: Dictionary = loaded.data.duplicate(true)
	document["reputation"] = snapshot()
	return save_system.save(document)


static func normalise(input: Dictionary) -> Dictionary:
	var output := {}
	for faction_id in FACTION_IDS:
		var raw = input.get(faction_id, 0)
		output[faction_id] = clampi(int(raw), MIN_REPUTATION, MAX_REPUTATION)
	return output


static func tier(reputation: int) -> String:
	if reputation <= -25:
		return "hostile"
	if reputation >= 25:
		return "trusted"
	return "neutral"


static func offer_available(offer: Dictionary, reputation: int) -> bool:
	return reputation >= int(offer.get("min_reputation", MIN_REPUTATION))


static func offer_price(offer: Dictionary, reputation: int) -> int:
	if not offer_available(offer, reputation):
		return -1
	var trusted_discount := maxi(0, floori(reputation / 25.0))
	return maxi(0, int(offer.get("cost", 0)) - trusted_discount)
