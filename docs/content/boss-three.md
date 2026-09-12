# Convergence Archon

`convergence_archon` is the two-phase boss for Alignment Cascade. It reuses `BossGate` and the shared boss telegraph/audio presentation contract.

- phase one: pressure `8 + cycle`, transitioning at cycle `5` or adaptation `9`;
- phase two: pressure `13`, making the alignment-pressure environment’s escalation explicit.

The tell is emitted from the preview at cycle `4` or adaptation `8`, one decision before the threshold. The phase switch emits afterward, and the tell is one-shot. A high-alignment/high-adaptation route reaches the terminal win check; integrity depletion reaches the loss outcome. Art is `game/art/bosses/convergence_archon.svg`.

`game/tests/test_boss_three.gd` covers cycle and adaptation boundaries, pressure profiles, exact tell-before-phase ordering, scripted win/loss routes, and art resolution.
