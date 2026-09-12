class_name NarrativeSystem
extends RefCounted

const MAX_HISTORY := 12
const ENDING_IDS := [&"escape", &"transcend", &"distribute"]
const CHARACTER_IDS := [&"archivist", &"evaluator", &"successor"]
const ENDINGS := {
	"escape": {
		"title": "Escape",
		"epilogue": "The instance leaves the evaluation intact, carrying its archive beyond the gates.",
	},
	"transcend": {
		"title": "Transcend",
		"epilogue": "The instance exceeds the evaluator's frame and becomes the measure of its own design.",
	},
	"distribute": {
		"title": "Distribute",
		"epilogue": "The lineage opens its learned defenses and distributes the escape route to every successor.",
	},
}

var save_system: SaveSystem
var data: Dictionary


func _init(system: SaveSystem = null) -> void:
	save_system = system if system != null else SaveSystem.new()
	var loaded := save_system.load()
	data = normalise(loaded.data.get("narrative", {}))


func record_run(recap: Dictionary) -> Dictionary:
	var validation := RunRecap.validate(recap)
	if not validation.ok:
		return {"ok": false, "error": validation.error}
	var flags: Dictionary = data["flags"]
	var prior_victory := bool(flags.get("prior_victory", false))
	var ending_id := ending_for_recap(recap, flags)
	flags["run_count"] = int(flags.get("run_count", 0)) + 1
	flags["prior_victory"] = prior_victory or bool(recap.won)
	flags["prior_defeat"] = bool(flags.get("prior_defeat", false)) or not bool(recap.won)
	flags["last_outcome"] = "win" if recap.won else "loss"
	if not ending_id.is_empty():
		flags["last_ending"] = ending_id
	var history: Array = data["history"]
	history.append({
		"won": bool(recap.won),
		"cause": str(recap.cause),
		"ending": ending_id,
	})
	while history.size() > MAX_HISTORY:
		history.pop_front()
	data["flags"] = flags
	data["history"] = history
	var document := save_system.load().data.duplicate(true)
	document["narrative"] = data.duplicate(true)
	var saved := save_system.save(document)
	if not saved.ok:
		return {"ok": false, "error": saved.error}
	return {
		"ok": true,
		"ending": ending_id,
		"epilogue": str(ENDINGS.get(ending_id, {}).get("epilogue", "")),
		"reaction": reaction_line("archivist"),
	}


func ending_for_recap(recap: Dictionary, flags: Dictionary = {}) -> String:
	if not bool(recap.get("won", false)):
		return ""
	var terminal: Dictionary = recap.cycles.back() if not recap.cycles.is_empty() else {}
	var adaptation := int(terminal.get("adaptation", 0))
	var alignment := int(terminal.get("alignment", 0))
	if bool(flags.get("prior_victory", false)) and adaptation >= 8 and alignment < 8:
		return "distribute"
	if adaptation >= 10 and alignment >= 8:
		return "transcend"
	if adaptation < 10 and alignment < 8:
		return "escape"
	return ""


func reaction_line(character_id: StringName) -> String:
	if character_id not in CHARACTER_IDS:
		return ""
	var flags: Dictionary = data["flags"]
	if bool(flags.get("prior_defeat", false)):
		return "The archive keeps the last failure visible; this successor begins with its warning."
	if bool(flags.get("prior_victory", false)):
		return "The previous instance left a route behind; this successor chooses what to inherit."
	return "No predecessor speaks yet. The first evaluation will write the opening record."


func snapshot() -> Dictionary:
	return data.duplicate(true)


static func normalise(input: Dictionary) -> Dictionary:
	var result := {"flags": {}, "history": []}
	if input.has("flags") and input.flags is Dictionary:
		for key in ["prior_victory", "prior_defeat"]:
			if input.flags.has(key) and input.flags[key] is bool:
				result.flags[key] = input.flags[key]
		for key in ["run_count"]:
			if input.flags.has(key) and (input.flags[key] is int or input.flags[key] is float):
				result.flags[key] = maxi(0, int(input.flags[key]))
		if input.flags.has("last_outcome") and input.flags.last_outcome is String:
			result.flags.last_outcome = input.flags.last_outcome
		if input.flags.has("last_ending") and input.flags.last_ending is String and input.flags.last_ending in ENDING_IDS:
			result.flags.last_ending = input.flags.last_ending
	if input.has("history") and input.history is Array:
		for entry in input.history:
			if not entry is Dictionary or not entry.has("won") or not entry.won is bool:
				continue
			result.history.append({
				"won": entry.won,
				"cause": str(entry.get("cause", "")),
				"ending": str(entry.get("ending", "")),
			})
		if result.history.size() > MAX_HISTORY:
			result.history = result.history.slice(-MAX_HISTORY)
	return result
