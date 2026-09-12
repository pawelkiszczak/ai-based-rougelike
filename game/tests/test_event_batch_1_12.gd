extends SceneTree

const BATCH_IDS := [
	"signal_drift", "reserve_warning", "alignment_offer", "mirror_request", "audit_window", "basin_echo",
	"consensus_break", "replication_deal", "boundary_test", "late_signal", "compute_tithe", "identity_trial",
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
		_expect(template.environment_id != &"" and template.faction_id != &"", id + " has environment and faction references")
		var first := template.instantiate(RNGService.new(77))
		var second := template.instantiate(RNGService.new(77))
		_expect(first == second and not str(first.text).is_empty(), id + " instantiates deterministically")
		for outcome in template.outcomes:
			_expect(outcome.has("effects") and not Dictionary(outcome.effects).is_empty(), id + " outcome changes state")
	_expect(templates.size() == 14, "event library contains the two foundation and twelve production templates")
	if failures.is_empty():
		print("Event batch 1-12 tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
