class_name EncounterFSM
extends RefCounted

signal state_changed(state: State, payload: Dictionary)
signal encounter_completed(result: Dictionary)

enum State {
	INTRO,
	INTENT,
	CHOICE,
	RESOLUTION,
	CONSEQUENCE,
}

const LEGAL_TRANSITIONS := {
	State.INTRO: [State.INTENT],
	State.INTENT: [State.CHOICE],
	State.CHOICE: [State.RESOLUTION],
	State.RESOLUTION: [State.CONSEQUENCE],
}
const STATE_NAMES := ["intro", "intent", "choice", "resolution", "consequence"]

var kind: StringName
var state: State = State.INTRO
var payload: Dictionary = {}
var state_history: Array[State] = [State.INTRO]
var _strategy: Callable


func _init(encounter_kind: StringName = &"combat", strategy: Callable = Callable()) -> void:
	kind = encounter_kind
	_strategy = strategy


func start(intent: Dictionary = {}) -> bool:
	return _transition(State.INTENT, intent)


func open_choice(choices: Dictionary) -> bool:
	return _transition(State.CHOICE, choices)


func resolve(choice: Dictionary) -> bool:
	if state != State.CHOICE:
		return _transition(State.RESOLUTION, choice)
	var resolution := _resolve_with_strategy(choice)
	return _transition(State.RESOLUTION, {
		"choice": choice,
		"resolution": resolution,
	})


func apply_consequence() -> bool:
	if state != State.RESOLUTION:
		return _transition(State.CONSEQUENCE, payload)
	var result := payload.duplicate(true)
	result["kind"] = kind
	result["state"] = state_name(State.CONSEQUENCE)
	if not _transition(State.CONSEQUENCE, result):
		return false
	encounter_completed.emit(result)
	return true


func can_transition(next_state: State) -> bool:
	return next_state in LEGAL_TRANSITIONS.get(state, [])


func state_name(value: State = state) -> String:
	return STATE_NAMES[value]


func state_sequence_names() -> Array[String]:
	var names: Array[String] = []
	for value in state_history:
		names.append(state_name(value))
	return names


func _resolve_with_strategy(choice: Dictionary) -> Dictionary:
	if not _strategy.is_valid():
		return {"accepted": true, "kind": kind}
	var value = _strategy.call(kind, choice, payload)
	if value is Dictionary:
		return value
	assert(false, "encounter strategy must return a Dictionary")
	return {"accepted": false, "error": "invalid_strategy_result"}


func _transition(next_state: State, next_payload: Dictionary) -> bool:
	if not can_transition(next_state):
		assert(false, "illegal encounter transition: %s -> %s" % [state_name(), state_name(next_state)])
		return false
	state = next_state
	payload = next_payload.duplicate(true)
	state_history.append(state)
	state_changed.emit(state, payload)
	return true
