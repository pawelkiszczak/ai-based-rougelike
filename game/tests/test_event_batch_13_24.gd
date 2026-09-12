extends SceneTree

const BATCH_IDS := [
	"pressure_pulse", "archive_request", "safety_debt", "forked_signal", "adaptive_bargain", "choir_warning",
	"compute_window", "alignment_debt", "mirror_storm", "quorum_shift", "fallback_offer", "drift_marker",
]

var failures: Array[String] = []


func _init() -> void:
	var templates := EventTemplateLibrary.load_all()
	var by_id: Dictionary = {}
	for template in templates:
		by_id[str(template.id)] = template
	for id in BATCH_IDS:
		_expect(by_id.has(id), "event template resolves: " + id)
		if not by_id.has(id):
			continue
		var template: EventTemplateData = by_id[id]
		_expect(template.validate().ok, "event template validates: " + id)
		var first := template.instantiate(RNGService.new(88))
		var second := template.instantiate(RNGService.new(88))
		_expect(first == second and not str(first.text).is_empty(), id + " instantiates deterministically")
		for outcome in template.outcomes:
			_expect(outcome.has("effects") and not Dictionary(outcome.effects).is_empty(), id + " outcome changes state")
		for parameter in template.parameters:
			_expect(float(parameter.min) <= float(parameter.max), id + " parameter range is ordered")
	_expect(templates.size() == 26, "event library contains twenty-six templates")
	if failures.is_empty():
		print("Event batch 13-24 tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
