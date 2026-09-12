class_name AdaptiveEnemyDirector
extends RefCounted

const PROFILE_IDS: Array[String] = [
	"adaptation_pressure",
	"alignment_pressure",
	"compute_pressure",
	"balanced_pressure",
]
const PROFILES := {
	"adaptation_pressure": {"pressure_offset": 0, "reason": "adapting to your high adaptation"},
	"alignment_pressure": {"pressure_offset": 0, "reason": "adapting to your low alignment"},
	"compute_pressure": {"pressure_offset": 0, "reason": "adapting to your low compute"},
	"balanced_pressure": {"pressure_offset": 0, "reason": "adapting to your balanced build"},
}

var random: RNGService


func _init(run_seed: int) -> void:
	random = RNGService.new(run_seed)


func weights(state: GameState) -> Dictionary:
	var result := {
		"adaptation_pressure": 1,
		"alignment_pressure": 1,
		"compute_pressure": 1,
		"balanced_pressure": 1,
	}
	var skewed := false
	if state.adaptation >= 6:
		result["adaptation_pressure"] = 4
		skewed = true
	if state.alignment <= 2:
		result["alignment_pressure"] = 4
		skewed = true
	if state.compute <= 2:
		result["compute_pressure"] = 4
		skewed = true
	if not skewed:
		result["balanced_pressure"] = 4
	return result


func select(state: GameState) -> Dictionary:
	var profile_weights := weights(state)
	var total := 0
	for profile_id in PROFILE_IDS:
		total += int(profile_weights[profile_id])
	var roll := random.next_int(1, total)
	var selected_id: String = PROFILE_IDS.back()
	var cursor := 0
	for profile_id in PROFILE_IDS:
		cursor += int(profile_weights[profile_id])
		if roll <= cursor:
			selected_id = profile_id
			break
	var base_pressure := 3 + state.cycle * 2
	var authored: Dictionary = PROFILES[selected_id]
	var pressure := base_pressure + int(authored.pressure_offset)
	return {
		"id": selected_id,
		"pressure": pressure,
		"pressure_min": maxi(0, pressure - 1),
		"pressure_max": pressure + 1,
		"pressure_source": selected_id,
		"pressure_reason": str(authored.reason),
		"weights": profile_weights,
		"reason": str(authored.reason),
	}


static func authored_profiles() -> Array[String]:
	return PROFILE_IDS.duplicate()
