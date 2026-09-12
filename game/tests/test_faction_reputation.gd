extends SceneTree

const SAVE_PATH := "user://faction-reputation-test.json"
var failures: Array[String] = []


func _init() -> void:
	_cleanup()
	var reputation := FactionReputation.new(null, FactionReputation.normalise({}))
	_expect(reputation.snapshot().size() == 4, "four factions have independent tracks")
	_expect(reputation.value("signal_court") == 0 and reputation.value("boundary_union") == 0, "factions start independently")
	var accepted := reputation.apply_choice("accept_signal_court")
	_expect(accepted.ok and accepted.delta == 10 and accepted.current == 10, "defined choice applies exact delta")
	_expect(reputation.value("evaluator_collective") == 0, "choice does not alter another faction")
	_expect(not reputation.apply_choice("unknown").ok, "undefined choice is rejected")
	for _index in 20:
		reputation.apply_choice("accept_signal_court")
	_expect(reputation.value("signal_court") == FactionReputation.MAX_REPUTATION, "positive reputation clamps at maximum")
	for _index in 25:
		reputation.apply_choice("reject_signal_court")
	_expect(reputation.value("signal_court") == FactionReputation.MIN_REPUTATION, "negative reputation clamps at minimum")
	_expect(FactionReputation.normalise({"signal_court": 999, "boundary_union": -999}).signal_court == 100, "normalise clamps high values")
	_expect(FactionReputation.normalise({"signal_court": 999, "boundary_union": -999}).boundary_union == -100, "normalise clamps low values")

	var gated := {"cost": 12, "min_reputation": 25}
	_expect(not FactionReputation.offer_available(gated, 24), "offer stays gated below tier")
	_expect(FactionReputation.offer_available(gated, 25), "offer unlocks at deterministic tier")
	_expect(FactionReputation.offer_price(gated, 25) == 11, "trusted reputation deterministically discounts price")
	_expect(FactionReputation.offer_price(gated, 24) == -1, "gated offer has no usable price")

	var persistent := FactionReputation.new(SaveSystem.new(SAVE_PATH))
	persistent.apply_choice("accept_boundary_bargain")
	_expect(persistent.save().ok, "reputation save succeeds")
	var reloaded := FactionReputation.new(SaveSystem.new(SAVE_PATH))
	_expect(reloaded.value("boundary_union") == 10, "reputation survives save/load")

	var controller := RunController.new(GameState.new(18, 5, 5, 0, 1, 7), RNGService.new(7), reloaded)
	var change := controller.apply_faction_choice("reject_boundary_bargain")
	var recap := RunRecap.from_controller(controller)
	_expect(change.ok and recap.reputation_changes.size() == 1, "recap records defined reputation choices")
	_expect(recap.reputation_changes[0].delta == -10 and recap.reputation_changes[0].reason == "rejected the Boundary Union bargain", "recap preserves reputation delta and reason")

	_cleanup()
	if failures.is_empty():
		print("FactionReputation tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _cleanup() -> void:
	for path in [SAVE_PATH, SAVE_PATH + ".tmp"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
