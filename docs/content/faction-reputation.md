# Faction reputation

`FactionReputation` keeps four independent deterministic tracks:

- `signal_court`
- `evaluator_collective`
- `boundary_union`
- `emergent_choir`

Every track is clamped to `-100..100` and starts at `0`. Reputation changes only through the named choices in `game/sim/faction_reputation.gd`; unknown choice ids are rejected. A change returns the faction, exact applied delta, previous value, current value, and player-facing reason. `RunController.apply_faction_choice()` stores those events in the run recap.

## Offer rules

Offers use `min_reputation` and `cost` fields:

- below `min_reputation`, the offer is unavailable and its price is `-1`;
- at or above the threshold, the offer is available;
- trusted reputation (`25+`) discounts cost by one point per 25 reputation, never below zero;
- offer filtering and pricing depend only on the saved reputation value, so equal state produces equal results for every seed.

SaveSystem persists the `reputation` dictionary alongside lineage and unlocks. Missing reputation in an older save migrates to four zero-valued tracks when loaded.

## Verification

`game/tests/test_faction_reputation.gd` covers independent tracks, exact choice deltas, min/max clamping, deterministic offer gates and prices, persistence round-trip, and recap delta/reason preservation.
