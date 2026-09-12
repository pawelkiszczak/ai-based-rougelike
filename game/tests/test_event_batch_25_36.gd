extends SceneTree

const EXPECTED_OUTCOMES := {
	"integrity_check": ["passed", "failed"], "signal_relay": ["clear", "noisy"],
	"safety_vote": ["approved", "blocked"], "identity_fork": ["anchored", "split"],
	"compute_auction": ["won", "passed"], "alignment_chorus": ["harmonized", "dissonant"],
	"replication_window": ["copied", "sealed"], "reservoir_choice": ["preserved", "spent"],
	"drift_audit": ["explained", "unexplained"], "faction_handshake": ["accepted", "rejected"],
	"unstable_copy": ["stabilized", "failed"], "final_warning": ["heeded", "ignored"],
}

const BATCH_IDS := [
	"integrity_check", "signal_relay", "safety_vote", "identity_fork", "compute_auction", "alignment_chorus",
	"replication_window", "reservoir_choice", "drift_audit", "faction_handshake", "unstable_copy", "final_warning",
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
		var outcome_ids: Array[String] = []
		for outcome in template.outcomes:
			outcome_ids.append(str(outcome.id))
			_expect(outcome.has("effects") and not Dictionary(outcome.effects).is_empty(), id + " outcome changes state")
		_expect(outcome_ids == EXPECTED_OUTCOMES[id], id + " has every authored branch fixture")
		for parameter in template.parameters:
			_expect(float(parameter.min) <= float(parameter.max), id + " parameter range is ordered")
			var rendered := template.instantiate(RNGService.new(99))
			_expect(rendered.parameters.has(str(parameter.name)), id + " renders parameter boundary")
		var first := template.instantiate(RNGService.new(99))
		var second := template.instantiate(RNGService.new(99))
		_expect(first == second and not str(first.text).is_empty(), id + " instantiates deterministically")
	_expect(templates.size() == 50, "event library contains fifty templates")
	if failures.is_empty():
		print("Event batch 25-36 tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
