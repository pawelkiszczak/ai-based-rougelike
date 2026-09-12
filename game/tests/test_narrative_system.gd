extends SceneTree

const SAVE_PATH := "user://narrative-system-test.json"
var failures := 0


func _init() -> void:
	_cleanup()
	check_ending_boundaries()
	check_flag_persistence_and_reactions()
	check_invalid_recap()
	_cleanup()
	if failures == 0:
		print("NarrativeSystem tests passed")
	quit(failures)


func expect(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error(message)


func check_ending_boundaries() -> void:
	var escape := NarrativeSystem.ending_for_recap(recap(true, 9, 7), {})
	var transcend := NarrativeSystem.ending_for_recap(recap(true, 10, 8), {})
	var distribute := NarrativeSystem.ending_for_recap(recap(true, 8, 7), {"prior_victory": true})
	expect(escape == "escape", "low adaptation and alignment reaches escape")
	expect(transcend == "transcend", "high adaptation and alignment reaches transcend")
	expect(distribute == "distribute", "prior victory and low alignment reaches distribute")
	expect(NarrativeSystem.ending_for_recap(recap(false, 20, 10), {}) == "", "loss has no victory ending")
	expect(NarrativeSystem.ending_for_recap(recap(true, 9, 8), {}) == "", "boundary conflict has no accidental ending")
	expect(NarrativeSystem.ending_for_recap(recap(true, 8, 7), {}) == "escape", "distribution requires predecessor victory flag")


func check_flag_persistence_and_reactions() -> void:
	var save := SaveSystem.new(SAVE_PATH)
	expect(save.save(save.defaults()).ok, "narrative fixture save succeeds")
	var narrative := NarrativeSystem.new(save)
	var loss := narrative.record_run(recap(false, 3, 2))
	expect(loss.ok and loss.ending == "", "loss records without an ending")
	expect(bool(narrative.snapshot().get("flags", {}).get("prior_defeat", false)), "defeat flag is set")
	expect(narrative.reaction_line("archivist").contains("last failure"), "characters react to prior defeat")
	var reloaded := NarrativeSystem.new(SaveSystem.new(SAVE_PATH))
	expect(reloaded.snapshot().history.size() == 1, "narrative history survives save/load")
	expect(reloaded.snapshot().get("flags", {}).get("last_outcome", "") == "loss", "last outcome survives save/load")
	var win := reloaded.record_run(recap(true, 9, 7))
	expect(win.ending == "escape", "first low-stat victory resolves to escape")
	var final_state := NarrativeSystem.new(SaveSystem.new(SAVE_PATH)).snapshot()
	expect(final_state.history.size() == 2 and bool(final_state.get("flags", {}).get("prior_victory", false)), "victory and history persist")
	expect(final_state.get("flags", {}).get("last_ending", "") == "escape", "ending persists as a flag")


func check_invalid_recap() -> void:
	var result := NarrativeSystem.new(SaveSystem.new(SAVE_PATH)).record_run({"won": true})
	expect(not result.ok and not result.error.is_empty(), "invalid recap is rejected")


func recap(won: bool, adaptation: int, alignment: int) -> Dictionary:
	return {
		"schema_version": RunRecap.SCHEMA_VERSION,
		"run_seed": 7,
		"choices": ["test"],
		"cycles": [{"cycle": 6, "mutation_id": "test", "adaptation": adaptation, "alignment": alignment}],
		"won": won,
		"cause": "final_gate_passed" if won else "integrity_depleted",
		"archive_gained": 20 if won else 5,
		"final_integrity": 12,
	}


func _cleanup() -> void:
	for suffix in ["", ".tmp"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH + suffix))
