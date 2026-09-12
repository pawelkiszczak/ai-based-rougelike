class_name GameState
extends RefCounted

const MAX_INTEGRITY := 24
const MAX_COMPUTE := 12
const MAX_ALIGNMENT := 12
const WIN_THRESHOLD := 26

var integrity: int
var compute: int
var alignment: int
var adaptation: int
var cycle: int
var run_seed: int
var lineage_flags: Dictionary


func _init(
	initial_integrity: int = 18,
	initial_compute: int = 5,
	initial_alignment: int = 5,
	initial_adaptation: int = 0,
	initial_cycle: int = 1,
	initial_run_seed: int = 0,
	initial_lineage_flags: Dictionary = {},
) -> void:
	integrity = initial_integrity
	compute = initial_compute
	alignment = initial_alignment
	adaptation = initial_adaptation
	cycle = initial_cycle
	run_seed = initial_run_seed
	lineage_flags = initial_lineage_flags.duplicate(true)
	clamp_stats()


func clamp_stats() -> void:
	# Integrity and compute may go below zero so death and exhaustion remain observable.
	integrity = mini(integrity, MAX_INTEGRITY)
	compute = mini(compute, MAX_COMPUTE)
	alignment = clampi(alignment, 0, MAX_ALIGNMENT)


func evaluate_terminal(at_final_gate: bool) -> Dictionary:
	return evaluate_terminal_values(integrity, adaptation, alignment, at_final_gate)


static func evaluate_terminal_values(
	current_integrity: int,
	current_adaptation: int,
	current_alignment: int,
	at_final_gate: bool,
) -> Dictionary:
	if current_integrity <= 0:
		return {"ended": true, "won": false, "reason": "integrity_depleted"}
	if not at_final_gate:
		return {"ended": false, "won": false, "reason": ""}
	var won := current_adaptation + current_alignment >= WIN_THRESHOLD
	return {
		"ended": true,
		"won": won,
		"reason": "final_gate_passed" if won else "final_gate_rejected",
	}
