class_name RNGService
extends RefCounted

var run_seed: int
var _rng := RandomNumberGenerator.new()


func _init(seed_value: int) -> void:
	run_seed = seed_value
	_rng.seed = seed_value


func next_int(from: int, to: int) -> int:
	return _rng.randi_range(from, to)


func next_float() -> float:
	return _rng.randf()


func draw_choice_indices(pool_size: int, count: int) -> Array[int]:
	if pool_size < 0 or count < 0 or count > pool_size:
		push_error("draw_choice_indices requires 0 <= count <= pool_size")
		return []

	var available: Array[int] = []
	for index in pool_size:
		available.append(index)

	var choices: Array[int] = []
	for _unused in count:
		var selected_index := _rng.randi_range(0, available.size() - 1)
		choices.append(available[selected_index])
		available.remove_at(selected_index)
	return choices
