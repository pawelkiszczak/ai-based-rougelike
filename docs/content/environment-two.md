# Environment two: Entropy Basin

`entropy_basin` reuses the validated six-slot encounter contract from `command_mesh` and deliberately covers combat, negotiation, and event slots. Its mechanic is `compute_scarcity`.

## Twist

Before commitment, the environment previews its rule: when compute is `0..2`, incoming pressure receives a `+2` modifier and the player-facing reason says `low compute increases pressure`. At compute `3+`, the modifier is `0` and the preview says reserves keep pressure stable. The boundary is explicit, deterministic, and changes the observable choice between preserving compute and spending it for mutation effects.

The environment uses `entropy_basin.svg`, shared authored encounter resources, and existing audio events. Slot draws use `RNGService`, so equal seeds produce equal slot sequences. `test_environment_two.gd` covers asset and slot integrity, all encounter kinds, the twist boundary, and deterministic draws.

Manual controller-only completion and legibility remain release-playtest checks; the automated suite proves the data contract and boundary behavior.
