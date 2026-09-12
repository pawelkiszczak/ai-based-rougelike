class_name DailyRunConfig
extends RefCounted

const NAMESPACE := "daily:v1:"
const MODIFIER_IDS := [&"hardened_pressure", &"single_category", &"low_compute"]


static func seed_for_date(date: String) -> Dictionary:
	if not _valid_date(date):
		return {"ok": false, "error": "invalid_daily_date"}
	return {"ok": true, "namespace": NAMESPACE + date, "seed": (NAMESPACE + date).hash()}


static func seed_for_utc_timestamp(unix_time: int) -> Dictionary:
	var date := Time.get_datetime_dict_from_unix_time(unix_time, true)
	return seed_for_date("%04d-%02d-%02d" % [date.year, date.month, date.day])


static func parse_seed(input: String) -> Dictionary:
	var value := input.strip_edges()
	if value.begins_with(NAMESPACE):
		return seed_for_date(value.trim_prefix(NAMESPACE))
	if value.is_valid_int():
		return {"ok": true, "namespace": "manual", "seed": value.to_int()}
	return {"ok": false, "error": "invalid_seed"}


static func normalise_modifiers(input: Array[StringName]) -> Dictionary:
	var modifiers: Dictionary = {}
	for modifier in input:
		if modifier not in MODIFIER_IDS:
			return {"ok": false, "error": "unknown_modifier"}
		modifiers[str(modifier)] = true
	return {"ok": true, "modifiers": modifiers}


static func apply_starting_modifiers(state: GameState, modifiers: Dictionary) -> void:
	if bool(modifiers.get("low_compute", false)):
		state.compute -= 2
	state.clamp_stats()


static func filter_pool(pool: Array[MutationData], modifiers: Dictionary) -> Array[MutationData]:
	if not bool(modifiers.get("single_category", false)):
		return pool.duplicate()
	var filtered: Array[MutationData] = []
	for mutation in pool:
		if mutation.category == &"safety":
			filtered.append(mutation)
	return filtered


static func _valid_date(date: String) -> bool:
	if not date.match("????-??-??"):
		return false
	var parts := date.split("-")
	if parts.size() != 3:
		return false
	var year := parts[0].to_int()
	var month := parts[1].to_int()
	var day := parts[2].to_int()
	if year < 1970 or month < 1 or month > 12 or day < 1 or day > 31:
		return false
	return "%04d-%02d-%02d" % [year, month, day] == date
