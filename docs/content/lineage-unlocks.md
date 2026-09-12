# Vertical-slice lineage unlocks

The archive uses five persistent unlocks. Costs are tiered at 10, 15, 20, 25, and 30 archive. A failed run grants at least 5 archive, so the first unlock is reachable after roughly two failed runs; exact pacing remains a playtest calibration question.

| Unlock | Cost | Effect | Trade-off |
|---|---:|---|---|
| Deep reserves | 10 | +2 starting compute | More planning capacity does not improve integrity. |
| Hardened shell | 15 | +3 starting integrity | Defensive opening leaves the mutation pool unchanged. |
| Alignment lens | 20 | +2 starting alignment | Earlier final-gate progress does not provide compute. |
| Threat model | 25 | Adds `threat_model` to subsequent mutation draws | Its −2 compute effect is a deliberate operating cost. |
| Audit trail | 30 | Adds `audit_trail` to subsequent mutation draws | Its +1 compute effect also increases alignment pressure choices. |

`ArchiveStore` persists unlock ids through `SaveSystem`. `starting_state()` applies owned stat effects when a run is initialized; `eligible_mutations()` gates the two pool additions without requiring a particular random draw. Direct fixtures verify both owned and unowned paths.
