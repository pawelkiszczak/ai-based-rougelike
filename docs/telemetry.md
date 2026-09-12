# Local telemetry v1

Telemetry is optional, local-only, and never authoritative for gameplay, progression, stats, or unlocks. The default is disabled. No network client or endpoint is part of this feature.

## Opt-in record

`TelemetryStore.record_run(recap, duration_ms)` appends one JSON object per completed `RunRecap` to `user://telemetry.jsonl` when enabled. Each line has:

- `schema_version`: `1`
- `run_seed`: deterministic run seed
- `choices`: ordered mutation ids
- `death_cycle`: terminal cycle for losses, `-1` for wins
- `cause`: authored terminal cause
- `duration_ms`: non-negative local duration
- `outcome`: `win` or `loss`

Malformed recap data is rejected before opening the file. Existing lines are never rewritten.

## Manual export

Copy `user://telemetry.jsonl` from the platform's Godot user-data directory to an analysis workspace. Exporting is a manual local operation; do not upload it automatically. Deleting the file has no effect on the SaveSystem file or progression state.

## Retention decision

The project does not collect remote analytics and does not use cohort D1 retention as a release gate. Local telemetry remains disabled by default and is never presented as a population-level retention measurement. Any future public retention study requires a separate consented method and an explicit privacy review before recruitment.
