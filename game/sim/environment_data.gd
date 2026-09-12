class_name EnvironmentData
extends Resource

@export var id: StringName
@export var theme: String
@export_file("*.svg") var background_art: String
@export var slots: Array[Dictionary] = []


func validate() -> Dictionary:
	if id == &"" or theme.is_empty():
		return {"ok": false, "error": "environment identity is incomplete"}
	if background_art.is_empty() or not FileAccess.file_exists(background_art):
		return {"ok": false, "error": "missing environment art: " + background_art}
	if slots.size() != 6:
		return {"ok": false, "error": "environment must contain six slots"}
	for slot in slots:
		for key in ["encounter_id", "kind", "weight"]:
			if not slot.has(key):
				return {"ok": false, "error": "slot missing field: " + key}
		if StringName(slot.kind) not in [&"combat", &"negotiation", &"event"]:
			return {"ok": false, "error": "unsupported slot kind: " + str(slot.kind)}
		if int(slot.weight) <= 0:
			return {"ok": false, "error": "slot weight must be positive"}
	return {"ok": true, "error": ""}


func draw_slot(random: RNGService) -> Dictionary:
	var total_weight := 0
	for slot in slots:
		total_weight += int(slot.weight)
	var roll := random.next_int(1, total_weight)
	for slot in slots:
		roll -= int(slot.weight)
		if roll <= 0:
			return slot.duplicate(true)
	return slots.back().duplicate(true)
