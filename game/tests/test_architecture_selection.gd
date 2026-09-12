extends SceneTree

const DEFAULT_PATH := "user://architecture-default-test.json"
const FRONTIER_PATH := "user://architecture-frontier-test.json"
var failures: Array[String] = []


func _init() -> void:
	_cleanup()
	var default_save := SaveSystem.new(DEFAULT_PATH)
	_expect(default_save.save(default_save.defaults()).ok, "default architecture fixture saves")
	var default_store := ArchiveStore.new(default_save)
	var default_state := default_store.starting_state(501)
	_expect(default_state.integrity == 18 and default_state.compute == 5 and default_state.alignment == 5 and default_state.adaptation == 0, "default opening state is balanced")
	_expect(not default_store.can_select_architecture("frontier"), "frontier architecture stays locked before unified lineage")

	var frontier_save := SaveSystem.new(FRONTIER_PATH)
	var frontier_data := frontier_save.defaults()
	frontier_data["unlocks"] = ["unified_lineage"]
	_expect(frontier_save.save(frontier_data).ok, "frontier architecture fixture saves")
	var frontier_store := ArchiveStore.new(frontier_save)
	_expect(frontier_store.can_select_architecture("frontier"), "frontier architecture unlocks from unified lineage")
	_expect(frontier_store.select_architecture("frontier").ok, "frontier architecture selection persists")
	var frontier_state := frontier_store.starting_state(502)
	_expect(frontier_state.integrity == 17 and frontier_state.compute == 9 and frontier_state.alignment == 4 and frontier_state.adaptation == 3, "frontier opening differs on four dimensions")
	var pool := frontier_store.eligible_mutations(MutationLibrary.load_all())
	_expect(str(pool[0].id) == "adversarial_fuzzing" and str(pool[1].id) == "compute_siphon" and str(pool[2].id) == "consent_gate", "frontier pool bias is deterministic")

	var reloaded := ArchiveStore.new(SaveSystem.new(FRONTIER_PATH))
	_expect(reloaded.selected_architecture() == "frontier", "architecture selection survives save/load")
	for environment_id in [&"command_mesh", &"entropy_basin", &"alignment_cascade"]:
		var route_state := reloaded.starting_state(600 + str(environment_id).hash())
		_expect(route_state.integrity > 0 and route_state.compute > 0 and route_state.alignment >= 0, "frontier has viable opening route for " + str(environment_id))

	_cleanup()
	if failures.is_empty():
		print("Architecture selection tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _cleanup() -> void:
	for path in [DEFAULT_PATH, FRONTIER_PATH, DEFAULT_PATH + ".tmp", FRONTIER_PATH + ".tmp"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
