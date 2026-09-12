class_name RunController
extends RefCounted

const MAX_CYCLES := 6

signal state_changed(state: GameState)
signal run_ended(result: Dictionary)

var state: GameState
var rng_service: RNGService
var enemy_director: AdaptiveEnemyDirector
var reputation: FactionReputation
var reputation_changes: Array[Dictionary] = []
var run_log: Array[Dictionary] = []
var ended := false
var won := false
var modifiers: Dictionary = {}

func _init(
	initial_state: GameState = null,
	random: RNGService = null,
	faction_reputation: FactionReputation = null,
	run_modifiers: Dictionary = {},
) -> void:
	state = initial_state if initial_state != null else GameState.new()
	rng_service = random if random != null else RNGService.new(state.run_seed)
	enemy_director = AdaptiveEnemyDirector.new(state.run_seed)
	reputation = faction_reputation if faction_reputation != null else FactionReputation.new(null, FactionReputation.normalise({}))
	modifiers = run_modifiers.duplicate(true)
	DailyRunConfig.apply_starting_modifiers(state, modifiers)


func apply_faction_choice(choice_id: String) -> Dictionary:
	var change := reputation.apply_choice(choice_id)
	if change.ok:
		reputation_changes.append(change.duplicate(true))
	return change

func draw_choices(pool: Array[MutationData], count: int = 3) -> Array[MutationData]:
	var available := DailyRunConfig.filter_pool(pool, modifiers)
	if available.is_empty() or count <= 0:
		return []
	var indices := rng_service.draw_choice_indices(available.size(), mini(count, available.size()))
	var choices: Array[MutationData] = []
	for index in indices:
		choices.append(available[index])
	return choices

func damage_range(current_state: GameState, mutation: MutationData, encounter: Dictionary = {}) -> Dictionary:
	var base_pressure := 3 + current_state.cycle * 2
	var pressure := int(encounter.get("pressure", base_pressure))
	if bool(modifiers.get("hardened_pressure", false)):
		pressure += 2
	var pressure_min := maxi(0, int(encounter.get("pressure_min", pressure - 1)))
	var pressure_max := maxi(pressure_min, int(encounter.get("pressure_max", pressure + 1)))
	var adaptation_after := current_state.adaptation + mutation.adaptation
	var alignment_after := clampi(current_state.alignment + mutation.alignment, 0, GameState.MAX_ALIGNMENT)
	var defense := mutation.guard + floori(adaptation_after / 4.0) + floori(alignment_after / 3.0)
	var compute_after := mini(current_state.compute + mutation.compute, GameState.MAX_COMPUTE) - 1
	var exhaustion_damage := 2 if compute_after < 0 else 0
	var minimum := maxi(0, pressure_min - defense) + exhaustion_damage
	var maximum := maxi(0, pressure_max - defense) + exhaustion_damage
	var resolved := maxi(0, pressure - defense) + exhaustion_damage
	return {
		"min": minimum,
		"max": maximum,
		"resolved_damage": resolved,
		"pressure": pressure,
		"defense": defense,
		"source": str(encounter.get("pressure_source", "cycle pressure")),
		"reason": str(encounter.get("pressure_reason", "pressure rises each cycle")),
	}



func choose(mutation: MutationData) -> Dictionary:
	if ended:
		return {"ended": true, "won": won, "ignored": true, "reason": "run_already_ended"}
	var cycle := state.cycle
	var pressure_profile := enemy_director.select(state)
	var pressure := int(pressure_profile.pressure)
	var damage_info := damage_range(state, mutation, pressure_profile)
	mutation.apply_to(state)
	state.compute -= 1
	var defense: int = damage_info.defense
	var damage: int = damage_info.resolved_damage
	state.integrity -= damage
	state.clamp_stats()
	var result := {
		"run_id": "run-%d" % state.run_seed,
		"run_seed": state.run_seed,
		"cycle": cycle,
		"mutation_id": str(mutation.id),
		"pressure": pressure,
		"pressure_profile": pressure_profile.id,
		"pressure_reason": pressure_profile.reason,
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
