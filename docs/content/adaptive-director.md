# Adaptive enemy director

`AdaptiveEnemyDirector` maps the current build vector to a seeded pressure-profile distribution. The profile order is stable, and all authored profiles retain a positive baseline weight so every profile remains reachable.

## Profiles

| Profile | Trigger weight | Player-facing reason |
|---|---:|---|
| `adaptation_pressure` | 4 when adaptation ≥ 6 | Adapting to your high adaptation |
| `alignment_pressure` | 4 when alignment ≤ 2 | Adapting to your low alignment |
| `compute_pressure` | 4 when compute ≤ 2 | Adapting to your low compute |
| `balanced_pressure` | 4 when no skew trigger applies | Adapting to your balanced build |
Non-triggered profiles have weight `1`. Multiple skew triggers can apply simultaneously; the seeded weighted draw resolves the final profile. The selected result carries its profile id, pressure, visible range, weights, and reason. Profiles preserve the base pressure while changing the opposition rationale and weight; this keeps existing damage contracts stable while making adaptation legible.


`RunController` owns one director per run seed. Every selected profile is written into the run log with `pressure_profile` and `pressure_reason`, so the run log and recap explain why pressure adapted.

## Verification

`game/tests/test_adaptive_enemy_director.gd` covers each build-vector partition, profile reachability, visible reasons, and same-seed sequence determinism.
