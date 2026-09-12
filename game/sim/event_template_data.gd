class_name EventTemplateData
extends Resource

@export var id: StringName
@export var environment_id: StringName
@export var faction_id: StringName
@export var text_template: String
@export var parameters: Array[Dictionary] = []
@export var outcomes: Array[Dictionary] = []


func validate() -> Dictionary:
	if id == &"":
		return {"ok": false, "error": "event template id is empty"}
	if text_template.is_empty():
		return {"ok": false, "error": "event template %s has empty text" % id}
	if environment_id == &"" or faction_id == &"":
		return {"ok": false, "error": "event template %s has unresolved references" % id}
	var seen: Dictionary = {}
	for parameter in parameters:
		var name := str(parameter.get("name", ""))
		if name.is_empty() or seen.has(name):
			return {"ok": false, "error": "event template %s has invalid parameter name" % id}
		var minimum = parameter.get("min", null)
		var maximum = parameter.get("max", null)
		if not (minimum is int or minimum is float) or not (maximum is int or maximum is float):
			return {"ok": false, "error": "event template %s has invalid range for %s" % [id, name]}
		if float(minimum) > float(maximum):
			return {"ok": false, "error": "event template %s has reversed range for %s" % [id, name]}
		if not text_template.contains("{" + name + "}"):
			return {"ok": false, "error": "event template %s does not render %s" % [id, name]}
		seen[name] = true
	if outcomes.is_empty():
		return {"ok": false, "error": "event template %s has no outcomes" % id}
	for outcome in outcomes:
		if str(outcome.get("id", "")).is_empty() or int(outcome.get("odds", 0)) <= 0:
			return {"ok": false, "error": "event template %s has invalid outcome" % id}
	return {"ok": true, "error": ""}


func instantiate(random: RNGService) -> Dictionary:
	var validation := validate()
	if not validation.ok:
		return validation
	var values: Dictionary = {}
	for parameter in parameters:
		var name := str(parameter.name)
		values[name] = random.next_int(int(parameter.min), int(parameter.max))
	var outcomes_copy: Array[Dictionary] = []
	for outcome in outcomes:
		outcomes_copy.append(outcome.duplicate(true))
	return {
		"ok": true,
		"id": str(id),
		"text": text_template.format(values),
		"parameters": values,
		"outcomes": outcomes_copy,
	}
