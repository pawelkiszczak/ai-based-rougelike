# Enemy archetypes

`EnemyArchetypeLibrary` composes six pure behavior primitives from authored resources. `resolve(archetype, intent, player_stats)` has no mutable state or random draw, so the same configuration and player state always produce the same action.

## Primitive contract

- **Explore** advances pressure when adaptation is low.
- **Defend** raises guard when the player's guard is low.
- **Replicate** creates copies based on available compute.
- **Persuade** raises an alignment demand when alignment is low.
- **Predict** exposes an early warning for a future cycle.
- **Hide** reduces immediate damage when integrity is low.

Eight configs compose these primitives: Scout, Bulwark, Swarm, Envoy, Oracle, Lurker, Raider, and Bastion. Each has a distinct authored telegraph; every primitive is represented by at least one config. Intent mismatches are rejected instead of silently selecting a different behavior.

`game/tests/test_enemy_archetypes.gd` validates the roster, primitive coverage, deterministic boundary fixtures, and intent rejection. The configuration validator rejects missing fields, duplicate ids or telegraphs, unknown primitives, and rosters outside the 8–10 target.
