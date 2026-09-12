extends SceneTree

const SAVE_PATH := "user://lineage-unlocks-test.json"

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")
	var watchdog := create_timer(5.0)
	watchdog.timeout.connect(_on_watchdog_timeout)


func _run() -> void:
	_cleanup()
	var save := SaveSystem.new(SAVE_PATH)
	var data := save.defaults()
	var lineage: Dictionary = data["lineage"]
	lineage["archive"] = 1000
	data["lineage"] = lineage
	var seed_result := save.save(data)
	_expect(seed_result.ok, "unlock fixture save succeeds")
	var store := ArchiveStore.new(save)
	_expect(store.definitions().size() == 12, "twelve lineage unlocks are authored")
	_expect(store.validate_unlock_graph().ok, "unlock prerequisite graph is acyclic and resolvable")
	_expect(store.definitions()[0].cost < store.definitions()[5].cost, "unlock costs are tiered")
	_expect(not store.can_purchase("branch_archive"), "dependent unlock stays locked before prerequisites")

	var baseline := store.starting_state(301)
	_expect(baseline.compute == 5 and baseline.integrity == 18 and baseline.alignment == 5 and baseline.adaptation == 0, "unlocked effects do not alter baseline state")
	var all_mutations := MutationLibrary.load_all()
	var locked_pool := store.eligible_mutations(all_mutations)
	for mutation_id in ["batch_scheduler", "anticipatory_defense", "coherence_kernel", "adaptive_cache", "consensus_mesh", "branch_predictor", "cascade_engine"]:
		_expect(not _has_mutation(locked_pool, mutation_id), "unowned pool mutation is ineligible: " + mutation_id)

	_purchase(store, "deep_reserves", "deep reserves purchase succeeds")
	_purchase(store, "hardened_shell", "hardened shell purchase succeeds")
	_purchase(store, "alignment_lens", "alignment lens purchase succeeds")
	_purchase(store, "threat_model", "threat model pool unlock succeeds")
	_purchase(store, "audit_trail", "audit trail pool unlock succeeds")
	_purchase(store, "reserve_matrix", "reserve matrix purchase succeeds")
	_purchase(store, "shell_weave", "shell weave purchase succeeds")
	_purchase(store, "coherence_seed", "coherence seed purchase succeeds")
	_purchase(store, "archive_memory", "archive memory purchase succeeds")
	_purchase(store, "quorum_protocol", "quorum protocol purchase succeeds")
	_purchase(store, "branch_archive", "branch archive purchase succeeds")
	_purchase(store, "lineage_synthesis", "lineage synthesis purchase succeeds")

	var upgraded := store.starting_state(302)
	_expect(upgraded.compute == 12, "lineage unlocks apply exact starting compute")
	_expect(upgraded.integrity == 24, "lineage unlocks apply exact starting integrity")
	_expect(upgraded.alignment == 10, "lineage unlocks apply exact starting alignment")
	_expect(upgraded.adaptation == 5, "lineage unlocks apply exact starting adaptation")
	var upgraded_pool := store.eligible_mutations(all_mutations)
	for mutation_id in ["threat_model", "audit_trail", "batch_scheduler", "anticipatory_defense", "coherence_kernel", "adaptive_cache", "consensus_mesh", "branch_predictor", "cascade_engine"]:
		_expect(_has_mutation(upgraded_pool, mutation_id), "purchased pool mutation enters subsequent pool: " + mutation_id)

	var reloaded := ArchiveStore.new(SaveSystem.new(SAVE_PATH))
	_expect(reloaded.is_unlocked("lineage_synthesis"), "final unlock persists through save/load")
	_expect(reloaded.starting_state(303).adaptation == 5, "persisted unlock affects next initialized run")
	_expect(reloaded.purchase("lineage_synthesis").get("error", "") == "already_owned", "double purchase is rejected")

	var poor_path := "user://lineage-unlocks-poor.json"
	var poor_save := SaveSystem.new(poor_path)
	var poor_data := poor_save.defaults()
	var poor_lineage: Dictionary = poor_data["lineage"]
	poor_lineage["archive"] = 0
	poor_data["lineage"] = poor_lineage
	_expect(poor_save.save(poor_data).ok, "poor unlock fixture save succeeds")
	var poor_store := ArchiveStore.new(poor_save)
	_expect(poor_store.purchase("deep_reserves").get("error", "") == "insufficient_funds", "insufficient unlock funds are rejected")
	_expect(poor_store.data.unlocks.is_empty(), "rejected purchase does not mutate unlock state")

	_cleanup()
	if failures.is_empty():
		print("Lineage unlock tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _on_watchdog_timeout() -> void:
	push_error("Lineage unlock test watchdog expired")
	quit(2)

func _purchase(store: ArchiveStore, unlock_id: String, message: String) -> void:
	var result := store.purchase(unlock_id)
	_expect(bool(result.get("ok", false)), message + " (" + str(result.get("error", "")) + ")")


func _has_mutation(pool: Array[MutationData], mutation_id: String) -> bool:
	for mutation in pool:
		if str(mutation.id) == mutation_id:
			return true
	return false


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _cleanup() -> void:
	for path in [SAVE_PATH, SAVE_PATH + ".tmp", "user://lineage-unlocks-poor.json", "user://lineage-unlocks-poor.json.tmp"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
