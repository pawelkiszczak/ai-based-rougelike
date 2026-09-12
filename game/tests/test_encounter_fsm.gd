extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	for kind in [&"combat", &"negotiation", &"event"]:
		var fsm := EncounterFSM.new(kind, Callable(self, "_resolve_strategy"))
		var observed: Array[String] = []
		fsm.state_changed.connect(func(next_state: EncounterFSM.State, _payload: Dictionary): observed.append(fsm.state_name(next_state)))
		var completed: Array[Dictionary] = []
		fsm.encounter_completed.connect(func(result: Dictionary): completed.append(result))
		_expect(fsm.start({"pressure_source": "test"}), "%s enters intent" % kind)
		_expect(fsm.open_choice({"choices": ["a", "b", "c"]}), "%s enters choice" % kind)
		_expect(fsm.resolve({"mutation_id": "test_mutation"}), "%s enters resolution" % kind)
		_expect(fsm.apply_consequence(), "%s enters consequence" % kind)
		_expect(fsm.state_sequence_names() == ["intro", "intent", "choice", "resolution", "consequence"], "%s reaches every state" % kind)
		_expect(observed == ["intent", "choice", "resolution", "consequence"], "%s emits only transition signals" % kind)
		_expect(completed.size() == 1 and completed[0].kind == kind, "%s strategy result completes" % kind)
		for illegal_state in [EncounterFSM.State.INTRO, EncounterFSM.State.INTENT, EncounterFSM.State.CHOICE, EncounterFSM.State.RESOLUTION]:
			_expect(not fsm.can_transition(illegal_state), "%s rejects illegal transition from consequence" % kind)

	for kind in [&"combat", &"negotiation", &"event"]:
		var six_cycle_states: Array[String] = []
		for _cycle in 6:
			var fsm := EncounterFSM.new(kind)
			fsm.start()
			fsm.open_choice({})
			fsm.resolve({})
			fsm.apply_consequence()
			six_cycle_states.append_array(fsm.state_sequence_names())
		_expect(six_cycle_states.count("intro") == 6, "%s six-cycle integration records intro" % kind)
		_expect(six_cycle_states.count("consequence") == 6, "%s six-cycle integration records consequence" % kind)

	if failures.is_empty():
		print("EncounterFSM tests passed")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _resolve_strategy(encounter_kind: StringName, choice: Dictionary, _context: Dictionary) -> Dictionary:
	return {
		"accepted": true,
		"kind": encounter_kind,
		"mutation_id": choice.mutation_id,
	}


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
