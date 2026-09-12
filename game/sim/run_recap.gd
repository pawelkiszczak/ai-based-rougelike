class_name RunRecap
extends RefCounted

const SCHEMA_VERSION := 1


static func from_controller(controller: RunController) -> Dictionary:
	var choices: Array[String] = []
	var cycles: Array[Dictionary] = []
	for entry in controller.run_log:
		choices.append(entry.mutation_id)
		cycles.append({
			"cycle": entry.cycle,
			"mutation_id": entry.mutation_id,
			"pressure": entry.pressure,
			"damage": entry.damage,
			"integrity": entry.integrity,
		})
	var terminal: Dictionary = controller.run_log.back() if not controller.run_log.is_empty() else {}
	return {
		"schema_version": SCHEMA_VERSION,
		"run_seed": controller.state.run_seed,
		"choices": choices,
		"cycles": cycles,
		"won": controller.won,
		"cause": str(terminal.get("cause", "run_in_progress")),
		"archive_gained": int(terminal.get("archive_gained", 0)),
		"final_integrity": controller.state.integrity,
	}


static func validate(recap: Dictionary) -> Dictionary:
	for key in ["schema_version", "run_seed", "choices", "cycles", "won", "cause", "archive_gained", "final_integrity"]:
		if not recap.has(key):
			return {"ok": false, "error": "missing recap field: " + key}
	if recap.schema_version != SCHEMA_VERSION:
		return {"ok": false, "error": "unsupported recap schema"}
	if not recap.choices is Array or not recap.cycles is Array:
		return {"ok": false, "error": "invalid recap sequence"}
	if recap.choices.size() != recap.cycles.size():
		return {"ok": false, "error": "recap sequence length mismatch"}
	return {"ok": true, "error": ""}
