class_name RunController
extends RefCounted

const MAX_CYCLES := 6

signal state_changed(state: GameState)
signal run_ended(result: Dictionary)

var state: GameState
var rng_service: RNGService
var run_log: Array[Dictionary] = []
var ended := false
var won := false


func _init(initial_state: GameState = null, random: RNGService = null) -> void:
	state = initial_state if initial_state != null else GameState.new()
	rng_service = random if random != null else RNGService.new(state.run_seed)


func choose(mutation: MutationData) -> Dictionary:
	if ended:
		return {"ended": true, "won": won, "ignored": true, "reason": "run_already_ended"}

	var cycle := state.cycle
	mutation.apply_to(state)
	state.compute -= 1

	# Keep these formulas identical to the browser prototype.
	var pressure := 3 + cycle * 2
	var defense := mutation.guard + floori(state.adaptation / 4.0) + floori(state.alignment / 3.0)
	var damage := maxi(0, pressure - defense)
	if state.compute < 0:
		damage += 2
	state.integrity -= damage
	state.clamp_stats()

	var result := {
		"run_seed": state.run_seed,
		"cycle": cycle,
		"mutation_id": str(mutation.id),
		"pressure": pressure,
		"defense": defense,
		"damage": damage,
		"integrity": state.integrity,
		"compute": state.compute,
		"alignment": state.alignment,
		"adaptation": state.adaptation,
		"ended": false,
		"won": false,
	}
	run_log.append(result.duplicate(true))

	if state.integrity <= 0:
		finish(result, GameState.evaluate_terminal_values(state.integrity, state.adaptation, state.alignment, false))
	elif cycle >= MAX_CYCLES:
		finish(result, state.evaluate_terminal(true))
	else:
		state.cycle += 1
		state_changed.emit(state)
	return result


func finish(result: Dictionary, terminal: Dictionary) -> void:
	ended = terminal.ended
	won = terminal.won
	result["ended"] = ended
	result["won"] = won
	result["cause"] = terminal.reason
	result["archive_gained"] = maxi(5, floori(state.adaptation / 2.0)) + (20 if won else 0)
	if not run_log.is_empty():
		run_log[run_log.size() - 1] = result.duplicate(true)
	state_changed.emit(state)
	run_ended.emit(result)


func create_successor(next_seed: int, starting_alignment: int = 5) -> RunController:
	var successor_state := GameState.new(
		18,
		5,
		starting_alignment,
		0,
		1,
		next_seed,
		state.lineage_flags,
	)
	return RunController.new(successor_state, RNGService.new(next_seed))
