# Authoritative stats and codex

`StatsStore` processes completed run results directly; telemetry is not read and cannot create gameplay statistics. Every result must carry a stable `run_id`. A previously processed id returns success with `processed: false` and leaves all counters unchanged.

Stored lifetime fields:

- completed runs and wins;
- best adaptation, alignment, and compute values;
- per-environment run/win records;
- processed run ids for idempotence;
- first-seen codex unlocks.

Codex entries are derived one-to-one from authored mutation, encounter, faction, environment, boss, and event resources. `StatsStore.validate_codex_mapping()` rejects missing or orphan entries. `process_run()` rejects unknown entity ids rather than silently creating unowned content. Stats and codex state persist in SaveSystem's `stats` field and work with telemetry disabled or deleted.

`game/tests/test_stats_store.gd` covers aggregate totals, duplicate run idempotence, codex unlock persistence, resource-to-entry completeness, and stable-id rejection.
