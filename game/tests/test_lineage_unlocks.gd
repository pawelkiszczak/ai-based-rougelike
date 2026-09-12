extends SceneTree

const SAVE_PATH := "user://lineage-unlocks-test.json"

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")
	var watchdog := create_timer(5.0)
	watchdog.timeout.connect(_on_watchdog_timeout)


func _run() -> void:
	_cleanup()
	print("lineage: save baseline")
	var save := SaveSystem.new(SAVE_PATH)
	var data := save.defaults()
	data.lineage.archive = 100
	_expect(save.save(data).ok, "unlock fixture save succeeds")
	var store := ArchiveStore.new(save)
	print("lineage: inspect definitions")
	_expect(store.definitions().size() == 5, "five vertical-slice unlocks are authored")
	_expect(store.definitions()[0].cost < store.definitions()[1].cost, "unlock costs are tiered")

	var baseline := store.starting_state(301)
	print("lineage: inspect baseline state")
	_expect(baseline.compute == 5 and baseline.integrity == 18 and baseline.alignment == 5, "unlocked effects do not alter baseline state")
	var all_mutations := MutationLibrary.load_all()
	var locked_pool := store.eligible_mutations(all_mutations)
	_expect(not _has_mutation(locked_pool, "threat_model"), "unowned pool mutation is ineligible")
	_expect(not _has_mutation(locked_pool, "audit_trail"), "second unowned pool mutation is ineligible")

	print("lineage: purchase unlocks")
	_expect(store.purchase("deep_reserves").ok, "deep reserves purchase succeeds")
	_expect(store.purchase("hardened_shell").ok, "hardened shell purchase succeeds")
	_expect(store.purchase("alignment_lens").ok, "alignment lens purchase succeeds")
	_expect(store.purchase("threat_model").ok, "threat model pool unlock succeeds")
	_expect(store.purchase("audit_trail").ok, "audit trail pool unlock succeeds")

	print("lineage: inspect upgraded state")
	var upgraded := store.starting_state(302)
	_expect(upgraded.compute == 7, "deep reserves applies exact starting compute")
	_expect(upgraded.integrity == 21, "hardened shell applies exact starting integrity")
	_expect(upgraded.alignment == 7, "alignment lens applies exact starting alignment")
	var upgraded_pool := store.eligible_mutations(all_mutations)
	_expect(_has_mutation(upgraded_pool, "threat_model"), "purchased threat model enters subsequent pool")
	_expect(_has_mutation(upgraded_pool, "audit_trail"), "purchased audit trail enters subsequent pool")

	print("lineage: reload persisted state")
	var reloaded := ArchiveStore.new(SaveSystem.new(SAVE_PATH))
	_expect(reloaded.is_unlocked("alignment_lens"), "stat unlock persists through save/load")
	_expect(reloaded.is_unlocked("threat_model"), "pool unlock persists through save/load")
	_expect(reloaded.starting_state(303).compute == 7, "persisted stat unlock affects next initialized run")

	print("lineage: reject poor purchase")
	var poor_path := "user://lineage-unlocks-poor.json"
	var poor_save := SaveSystem.new(poor_path)
	var poor_data := poor_save.defaults()
	poor_data.lineage.archive = 0
	_expect(poor_save.save(poor_data).ok, "poor unlock fixture save succeeds")
	var poor_store := ArchiveStore.new(poor_save)
	_expect(poor_store.purchase("deep_reserves").error == "insufficient_funds", "insufficient unlock funds are rejected")
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
