class_name BossGate
extends RefCounted

signal tell_visible(tell: Dictionary)
signal phase_changed(phase: int)
signal gate_ended(result: Dictionary)

enum Phase {
	ONE,
	TWO,
	ENDED,
}

var data: BossData
var phase: Phase = Phase.ONE
var _tell_emitted := false


func _init(boss_data: BossData) -> void:
	data = boss_data


func preview(state: GameState) -> Dictionary:
	var transition_next_cycle := state.cycle + 1 >= data.transition_cycle
	var transition_next_adaptation := state.adaptation + 1 >= data.transition_adaptation
	var tell := phase == Phase.ONE and not _transition_reached(state) and (transition_next_cycle or transition_next_adaptation)
	if tell and not _tell_emitted:
		_tell_emitted = true
		tell_visible.emit({
			"phase": phase,
			"text": "The gate will escalate next cycle.",
		})
	return {
		"phase": phase,
		"pressure": data.phase_two_pressure if phase == Phase.TWO else data.phase_one_pressure + state.cycle,
		"tell": tell,
		"tell_text": "The gate will escalate next cycle." if tell else "",
		"transition_cycle": data.transition_cycle,
		"transition_adaptation": data.transition_adaptation,
	}


func resolve(state: GameState) -> Dictionary:
	if phase == Phase.ENDED:
		return {"ended": true, "ignored": true}
	if state.integrity <= 0:
		return _finish(false, "integrity_depleted")
	if phase == Phase.ONE and _transition_reached(state):
		phase = Phase.TWO
		phase_changed.emit(phase)
		return {"ended": false, "phase": phase, "transitioned": true, "tell": _tell_emitted}
	if phase == Phase.TWO and state.cycle >= RunController.MAX_CYCLES:
		var terminal := state.evaluate_terminal(true)
		return _finish(terminal.won, terminal.reason)
	return {"ended": false, "phase": phase, "transitioned": false}


func _transition_reached(state: GameState) -> bool:
	return state.cycle >= data.transition_cycle or state.adaptation >= data.transition_adaptation


func _finish(won_result: bool, reason: String) -> Dictionary:
	phase = Phase.ENDED
	var result := {"ended": true, "won": won_result, "reason": reason, "phase": phase}
	gate_ended.emit(result)
	return result
