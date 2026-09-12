extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var screen := preload("res://scenes/run.tscn").instantiate() as RunScreen
	get_root().add_child(screen)
	await process_frame

	_expect(screen.choice_container.get_child_count() == 3, "initial screen shows three data-driven choices")
	_expect(screen.stats_labels["integrity"].text.begins_with("Integrity:"), "initial screen renders integrity")
	_expect(screen.log_label.text == "No mutations selected.", "initial screen renders empty run log")

	var first_choice := screen.choice_container.get_child(0) as Button
	first_choice.emit_signal("pressed")
	await process_frame
	_expect(screen.controller.run_log.size() == 1, "choice is forwarded to RunController")
	_expect(screen.controller.state.cycle == 2 or screen.controller.ended, "choice advances or ends the run")
	_expect(screen.log_label.text != "No mutations selected.", "choice updates run log")

	var safety := 0
	while not screen.controller.ended and safety < 10:
		(screen.choice_container.get_child(0) as Button).emit_signal("pressed")
		await process_frame
		safety += 1
	_expect(screen.controller.ended, "successive choices reach a terminal state")
	_expect(screen.end_button.visible, "terminal state shows successor action")
	_expect(screen.choice_container.get_child_count() == 0, "terminal state removes choice cards")

	screen.queue_free()
	if failures.is_empty():
		print("RunScreen tests passed")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
