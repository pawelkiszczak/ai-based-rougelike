extends SceneTree

var failures := 0


func _init() -> void:
	check_same_seed_repeats_sequence()
	check_different_seed_changes_sequence()
	check_choice_indices_are_unique_and_bounded()
	check_invalid_choice_request_is_rejected()
	if failures == 0:
		print("RNGService tests passed.")
	quit(failures)


func expect(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error(message)


func sequence(service: RNGService) -> Array:
	var values: Array = []
	for _unused in 20:
		values.append(service.next_int(0, 1000000))
		values.append_array(service.draw_choice_indices(8, 3))
	return values


func check_same_seed_repeats_sequence() -> void:
	var left := RNGService.new(123456)
	var right := RNGService.new(123456)
	expect(left.run_seed == 123456, "service must retain the run seed")
	expect(sequence(left) == sequence(right), "same seed must produce the same sequence")


func check_different_seed_changes_sequence() -> void:
	var left := sequence(RNGService.new(123456))
	var right := sequence(RNGService.new(123457))
	expect(left != right, "different seeds must produce different sequences")


func check_choice_indices_are_unique_and_bounded() -> void:
	var choices := RNGService.new(7).draw_choice_indices(8, 3)
	var unique := {}
	for index in choices:
		expect(index >= 0 and index < 8, "choice index must stay inside the pool")
		unique[index] = true
	expect(choices.size() == 3, "choice count must match the request")
	expect(unique.size() == choices.size(), "choice indices must be unique")


func check_invalid_choice_request_is_rejected() -> void:
	var too_many := RNGService.new(7).draw_choice_indices(2, 3)
	expect(too_many.is_empty(), "request above pool size must return no choices")
	var negative := RNGService.new(7).draw_choice_indices(-1, 0)
	expect(negative.is_empty(), "negative pool size must return no choices")
