# Entropy Leviathan

`entropy_leviathan` is the two-phase boss for Entropy Basin. It reuses `BossGate` and exposes two distinct pressure profiles:

- phase one: pressure `7 + cycle`, with transition tell one decision before cycle `4`;
- phase two: pressure `11`, reached at cycle `4` or adaptation `10`.

The tell emits once before escalation and is visible through `BossGate.preview()`. A high-adaptation/high-alignment route reaches the final gate and wins; integrity depletion in phase two produces a loss. The authored boss art is `game/art/bosses/entropy_leviathan.svg`, and the shared `boss_tell`, `boss_loop`, `win`, and `lose` audio events remain the active presentation contract.

`game/tests/test_boss_two.gd` covers tell ordering, one-shot emission, transition boundaries, phase pressure, scripted win/loss routes, and art resolution.
