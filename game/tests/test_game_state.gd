extends SceneTree

var failures := 0


func _init() -> void:
	check_stat_clamping()
	check_terminal_boundaries()
	check_lineage_flag_copy()
	if failures == 0:
		print("GameState tests passed.")
	quit(failures)


func expect(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error(message)


func check_stat_clamping() -> void:
	var state := GameState.new(40, 40, -5, 3)
	expect(state.integrity == 24, "integrity must clamp at 24")
	expect(state.compute == 12, "compute must clamp at 12")
	expect(state.alignment == 0, "alignment must clamp at 0")
	state.integrity = -3
	state.compute = -1
	state.alignment = 20
	state.clamp_stats()
	expect(state.integrity == -3, "negative integrity must remain observable")
	expect(state.compute == -1, "negative compute must remain observable")
	expect(state.alignment == 12, "alignment must clamp at 12")


func check_terminal_boundaries() -> void:
	var below := GameState.evaluate_terminal_values(1, 20, 5, true)
	expect(not below.won, "threshold 25 must fail the final gate")
	expect(below.ended, "final gate must end the run")

	var at_threshold := GameState.evaluate_terminal_values(1, 20, 6, true)
	expect(at_threshold.won, "threshold 26 must pass the final gate")

	var dead := GameState.evaluate_terminal_values(0, 100, 12, true)
	expect(not dead.won, "depleted integrity must lose before win threshold")
	expect(dead.reason == "integrity_depleted", "death reason must identify integrity depletion")

	var active := GameState.evaluate_terminal_values(10, 100, 12, false)
	expect(not active.ended, "non-final state must remain active")


func check_lineage_flag_copy() -> void:
	var source := {"accepted_audit": true}
	var state := GameState.new(18, 5, 5, 0, 1, 123, source)
	source["accepted_audit"] = false
	expect(state.lineage_flags.accepted_audit, "lineage flags must be copied at construction")
