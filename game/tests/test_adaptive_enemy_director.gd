extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	var low_alignment := GameState.new(18, 5, 0, 0, 1, 1)
	var low_compute := GameState.new(18, 0, 5, 0, 1, 1)
	var high_adaptation := GameState.new(18, 5, 5, 6, 1, 1)
	var balanced := GameState.new(18, 5, 5, 0, 1, 1)
	var director := AdaptiveEnemyDirector.new(1)
	_expect(director.weights(low_alignment).alignment_pressure == 4, "low alignment increases alignment pressure weight")
	_expect(director.weights(low_compute).compute_pressure == 4, "low compute increases compute pressure weight")
	_expect(director.weights(high_adaptation).adaptation_pressure == 4, "high adaptation increases adaptation pressure weight")
	_expect(director.weights(balanced).balanced_pressure == 4, "balanced build increases balanced pressure weight")
	for profile_id in AdaptiveEnemyDirector.authored_profiles():
		_expect(director.weights(balanced)[profile_id] > 0, "authored profile remains reachable: " + profile_id)

	var first := AdaptiveEnemyDirector.new(77)
	var second := AdaptiveEnemyDirector.new(77)
	var first_sequence: Array[String] = []
	var second_sequence: Array[String] = []
	for _index in 12:
		var first_profile := first.select(low_alignment)
		var second_profile := second.select(low_alignment)
		first_sequence.append(first_profile.id)
		second_sequence.append(second_profile.id)
	_expect(AdaptiveEnemyDirector.PROFILES["alignment_pressure"].reason.contains("low alignment"), "low alignment profile exposes its reason")

	if failures.is_empty():
		print("AdaptiveEnemyDirector tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
