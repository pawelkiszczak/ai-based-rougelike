extends SceneTree

const BATCH_IDS := [
	"safe_harbor", "threat_lattice", "reserve_relay", "identity_checksum", "cascade_engine",
	"shielded_audit", "entropy_valve", "distributed_cache", "boundary_proof", "recursive_fork",
	"alignment_bridge", "cycle_compressor", "redoubt_protocol", "mutation_relay", "federated_guard",
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
	_expect(resources.size() == 70, "mutation batches expand the pool to seventy resources")
	_check_combo(by_id, ["safe_harbor", "threat_lattice"], [1, -3, 3, 8])
	_check_combo(by_id, ["reserve_relay", "identity_checksum"], [-1, 5, 3, 1])
	_check_combo(by_id, ["cascade_engine", "shielded_audit"], [6, -2, 2, 2])
	_check_combo(by_id, ["entropy_valve", "distributed_cache"], [7, 5, -5, 0])
	_check_combo(by_id, ["boundary_proof", "recursive_fork"], [6, -3, 1, 0])
	if failures.is_empty():
		print("Mutation batch 61-75 tests passed")
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
