extends SceneTree

const EXPECTED_OUTCOMES := {
	"quorum_alarm": ["recalled", "silenced"], "entropy_sample": ["refined", "contaminated"],
	"boundary_pact": ["sealed", "breached"], "evaluator_appeal": ["upheld", "denied"],
	"choir_refrain": ["resonant", "overloaded"], "signal_debt": ["settled", "defaulted"],
	"adaptation_trial": ["learned", "rejected"], "reserve_embargo": ["released", "withheld"],
	"mesh_breach": ["contained", "spread"], "cascade_hinge": ["balanced", "tipped"],
	"archive_echo": ["restored", "lost"], "faction_compromise": ["agreed", "deadlocked"],
}

const BATCH_IDS := [
	"quorum_alarm", "entropy_sample", "boundary_pact", "evaluator_appeal", "choir_refrain", "signal_debt",
	"adaptation_trial", "reserve_embargo", "mesh_breach", "cascade_hinge", "archive_echo", "faction_compromise",
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
			var rendered := template.instantiate(RNGService.new(107))
			_expect(rendered.parameters.has(str(parameter.name)), id + " renders parameter")
		var first := template.instantiate(RNGService.new(107))
		var second := template.instantiate(RNGService.new(107))
		_expect(first == second and not str(first.text).is_empty(), id + " instantiates deterministically")
	_expect(templates.size() == 50, "event library contains fifty templates")
	if failures.is_empty():
		print("Event batch 37-48 tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
