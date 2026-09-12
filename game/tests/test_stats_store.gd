extends SceneTree

const SAVE_PATH := "user://stats-store-test.json"
var failures: Array[String] = []


func _init() -> void:
	_cleanup()
	var authored := StatsStore.authored_codex_entries()
	_expect(authored.size() >= 30, "all authored entities have codex candidates")
	_expect(StatsStore.validate_codex_mapping(authored, authored).ok, "codex entries map one-to-one")
	var store := StatsStore.new(SaveSystem.new(SAVE_PATH), {"mutation_a": "Mutation A", "environment_a": "Environment A"})
	var result := {"run_id": "run-001", "won": true, "adaptation": 8, "alignment": 6, "compute": 4, "environment_id": "environment_a", "codex_ids": ["mutation_a"]}
	_expect(store.process_run(result).processed, "completed run updates authoritative stats")
	_expect(store.runs() == 1 and store.wins() == 1, "stats count runs and wins without telemetry")
	_expect(store.is_codex_unlocked("mutation_a"), "first entity encounter unlocks codex")
	_expect(store.stats.environment_records.environment_a.wins == 1, "environment record stores completed result")
	_expect(not store.process_run(result).processed and store.runs() == 1, "duplicate run id is idempotent")
	var second := {"run_id": "run-002", "won": false, "adaptation": 12, "alignment": 2, "compute": 3, "environment_id": "environment_a", "codex_ids": ["environment_a"]}
	_expect(store.process_run(second).processed, "second unique run updates stats")
	_expect(store.runs() == 2 and store.wins() == 1 and store.stats.best_build.adaptation == 12, "best build uses authoritative result data")
	var reloaded := StatsStore.new(SaveSystem.new(SAVE_PATH), {"mutation_a": "Mutation A", "environment_a": "Environment A"})
	_expect(reloaded.runs() == 2 and reloaded.is_codex_unlocked("mutation_a"), "stats and codex survive save/load")
	_expect(reloaded.is_codex_unlocked("environment_a"), "codex unlocks persist independently")
	_expect(not StatsStore.new(SaveSystem.new(SAVE_PATH), {"mutation_a": "Mutation A"}).process_run({"won": true}).ok, "run processing requires stable id")
	_cleanup()
	if failures.is_empty():
		print("StatsStore tests passed")
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
