extends SceneTree

const BATCH_IDS := [
	"adversarial_fuzzing", "invariant_check", "speculative_branch", "trust_anchor", "elastic_scheduler",
	"mirror_descent", "quorum_vote", "rollback_cache", "gradient_probe", "consensus_mesh",
	"shard_allocator", "red_team_protocol", "latent_compiler", "audit_quorum", "federated_memory",
]

var failures: Array[String] = []


func _init() -> void:
	var resources := MutationLibrary.load_all()
	var by_id: Dictionary = {}
	for mutation in resources:
		by_id[str(mutation.id)] = mutation
	for id in BATCH_IDS:
		_expect(by_id.has(id), "batch resource resolves: " + id)
		if not by_id.has(id):
			continue
		var mutation: MutationData = by_id[id]
		_expect(not mutation.text.is_empty() and mutation.text.contains("Counterplay:"), id + " exposes counterplay")
		_expect(_has_tradeoff(mutation), id + " has a non-dominant effect vector")
	_expect(resources.size() == 40, "mutation batch expands the pool to forty resources")
	_check_combo(by_id, ["adversarial_fuzzing", "invariant_check"], [4, -4, 3, 1])
	_check_combo(by_id, ["trust_anchor", "mirror_descent"], [1, 0, 0, 4])
	_check_combo(by_id, ["elastic_scheduler", "rollback_cache"], [-2, 2, 0, 3])
	_check_combo(by_id, ["gradient_probe", "consensus_mesh"], [6, 3, 2, -3])
	_check_combo(by_id, ["red_team_protocol", "audit_quorum"], [0, -4, 7, 1])
	if failures.is_empty():
		print("Mutation batch 31-45 tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _has_tradeoff(mutation: MutationData) -> bool:
	var positive := mutation.adaptation > 0 or mutation.compute > 0 or mutation.alignment > 0 or mutation.integrity > 0 or mutation.guard > 0
	var negative := mutation.adaptation < 0 or mutation.compute < 0 or mutation.alignment < 0 or mutation.integrity < 0
	return positive and negative


func _check_combo(by_id: Dictionary, ids: Array[String], expected: Array[int]) -> void:
	var state := GameState.new()
	for id in ids:
		by_id[id].apply_to(state)
	_expect(state.adaptation == expected[0], "+".join(ids) + " adaptation fixture")
	_expect(state.compute == 5 + expected[1], "+".join(ids) + " compute fixture")
	_expect(state.alignment == clampi(5 + expected[2], 0, GameState.MAX_ALIGNMENT), "+".join(ids) + " alignment fixture")
	_expect(state.integrity == 18 + expected[3], "+".join(ids) + " integrity fixture")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
