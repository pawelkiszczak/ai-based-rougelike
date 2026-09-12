# Seeded daily runs and custom modifiers

Daily mode uses the canonical namespace `daily:v1:YYYY-MM-DD` with the UTC calendar date. `DailyRunConfig.seed_for_utc_timestamp()` derives the date in UTC, so the same date produces one seed across local time zones; rollover occurs at `00:00:00Z`. The system clock is an input, not an authority: manually entered seeds remain available when a player needs a reproducible run.

`parse_seed()` accepts either the canonical daily namespace or a signed integer manual seed. Invalid input returns an error without changing a current run. `normalise_modifiers()` accepts these run-config flags:

- `hardened_pressure`: increases each telegraphed pressure by 2.
- `single_category`: limits choices to the authored safety category.
- `low_compute`: subtracts 2 compute from the initialized state.

`RunController` consumes the modifier dictionary for pressure, choice filtering, and opening-state adjustment. Modifiers are deterministic configuration, not probabilistic content. `test_daily_runs.gd` covers same-date stability, UTC rollover, canonical/manual/invalid input, modifier validation, direct choice filtering, opening-state changes, and pressure telegraph effects.
