extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	var templates := EventTemplateLibrary.load_all()
	_expect(templates.size() == 38, "all authored event templates load")
	_expect(EventTemplateLibrary.validate_all(templates).ok, "authored event templates pass validation")
	for template in templates:
		var first := template.instantiate(RNGService.new(41))
		var second := template.instantiate(RNGService.new(41))
		_expect(first.ok, "template instantiation succeeds: " + str(template.id))
		_expect(first == second, "same seed resolves identical event: " + str(template.id))
		_expect(not str(first.text).is_empty(), "resolved event text is non-empty: " + str(template.id))
		for outcome in first.outcomes:
			_expect(not str(outcome.id).is_empty(), "resolved outcome has an id: " + str(template.id))

	var malformed := EventTemplateData.new()
	malformed.id = &"malformed_fixture"
	malformed.text_template = "Invalid range {value}."
	malformed.parameters = [{"name": "value", "min": 4, "max": 2}]
	malformed.outcomes = [{"id": &"rejected", "odds": 1}]
	var validation := malformed.validate()
	_expect(not validation.ok and validation.error.contains("malformed_fixture"), "invalid range fails loudly with template id")
	var rejected := malformed.instantiate(RNGService.new(41))
	_expect(not rejected.ok, "invalid template cannot instantiate")
	if failures.is_empty():
		print("Event template tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
