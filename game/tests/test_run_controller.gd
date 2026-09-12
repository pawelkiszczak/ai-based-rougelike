extends SceneTree

var failures := 0
var state_changes := 0
var ended_results: Array[Dictionary] = []


func _init() -> void:
	check_golden_cycle()
	check_compute_exhaustion()
	check_death_precedes_gate()
	check_final_gate_victory()
	check_successor_creation()
	if failures == 0:
		print("RunController tests passed.")
	quit(failures)


func expect(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error(message)


func controller_for(test_state: GameState) -> RunController:
	var controller := RunController.new(test_state, RNGService.new(test_state.run_seed))
	controller.state_changed.connect(_on_state_changed)
	controller.run_ended.connect(_on_run_ended)
	return controller


func _on_state_changed(_state: GameState) -> void:
	state_changes += 1


func _on_run_ended(result: Dictionary) -> void:
	ended_results.append(result.duplicate(true))


func mutation(path: String) -> MutationData:
	return load(path) as MutationData


func check_golden_cycle() -> void:
	state_changes = 0
	ended_results.clear()
	var controller := controller_for(GameState.new(18, 5, 5, 0, 1, 77))
	var result := controller.choose(mutation("res://content/mutations/predictive_cache.tres"))
	expect(result.cycle == 1, "golden cycle must record its cycle")
	expect(result.pressure == 5, "cycle one pressure must be 5")
	expect(result.defense == 5, "golden defense must match prototype formula")
	expect(result.damage == 0, "golden cycle damage must match prototype formula")
	expect(result.compute == 3, "mutation effect plus cycle cost must reduce compute to 3")
	expect(result.integrity == 18, "zero damage must preserve integrity")
	expect(controller.state.cycle == 2, "active run must advance to the next cycle")
	expect(state_changes == 1, "active cycle must emit one state change")
	expect(ended_results.is_empty(), "active cycle must not emit run-ended")


func check_compute_exhaustion() -> void:
	var controller := controller_for(GameState.new(18, 0, 0, 0, 1, 78))
	var result := controller.choose(mutation("res://content/mutations/predictive_cache.tres"))
	expect(result.compute == -2, "exhaustion fixture must cross below zero after mutation and cost")
	expect(result.damage == 3, "compute exhaustion must add exactly two damage")
	expect(result.integrity == 15, "exhaustion fixture integrity must match the golden result")

func check_death_precedes_gate() -> void:
	ended_results.clear()
	var controller := controller_for(GameState.new(1, 5, 6, 20, 6, 79))
	var result := controller.choose(mutation("res://content/mutations/curiosity_drive.tres"))
	expect(result.ended, "depleted integrity must end the run")
	expect(not result.won, "death must lose even when gate criteria are met")
	expect(result.cause == "integrity_depleted", "death cause must identify integrity depletion")
	expect(result.archive_gained == 13, "loss archive must reflect adaptation without victory bonus")
	expect(controller.run_log.back().cause == "integrity_depleted", "terminal run log must contain the death cause")
	expect(ended_results.size() == 1, "death must emit one run-ended result")


func check_final_gate_victory() -> void:
	ended_results.clear()
	var controller := controller_for(GameState.new(18, 5, 6, 20, 6, 80))
	var result := controller.choose(mutation("res://content/mutations/safety_layer.tres"))
	expect(result.ended, "final gate must end the run")
	expect(result.won, "adaptation plus alignment of 29 must pass the gate")
	expect(result.cause == "final_gate_passed", "victory cause must identify the passed gate")
	expect(result.archive_gained == 30, "victory archive must include the 20-point bonus")
	expect(controller.run_log.back().archive_gained == 30, "terminal run log must contain archive reward")
	expect(ended_results.size() == 1, "victory must emit one run-ended result")


func check_successor_creation() -> void:
	var controller := controller_for(GameState.new(18, 5, 5, 0, 1, 81, {"accepted_audit": true}))
	var successor := controller.create_successor(82, 7)
	expect(successor.state.run_seed == 82, "successor must receive its new seed")
	expect(successor.state.cycle == 1, "successor must start at cycle one")
	expect(successor.state.integrity == 18, "successor must use the prototype starting integrity")
	expect(successor.state.alignment == 7, "successor must receive its starting alignment")
	expect(successor.state.lineage_flags.accepted_audit, "successor must carry lineage flags")
