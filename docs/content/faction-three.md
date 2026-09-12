# Boundary Union

The Boundary Union rewards alignment while constraining adaptation. Its telegraphs make that conflict explicit: the Harmonizer increases alignment pressure, the Adaptation Limiter punishes growth, and the Resonance Keeper turns alignment into a binding constraint.

Offer families are deterministic and visible before commitment:

- `alignment_accord` gains 2 alignment for 1 adaptation debt and is always available;
- `adaptive_brake` requires the `accepted_bargain` memory flag and reputation `0`, gaining 3 alignment for 2 adaptation debt;
- `convergence_charter` requires the same memory flag and trusted reputation `25`, gaining 4 alignment for 3 adaptation debt.

`game/tests/test_faction_three.gd` covers telegraph behavior, memory visibility, exact reputation boundaries, and the alignment/adaptation trade-off fields. This identity differs from Signal Court’s prediction/compute-scarcity play and Evaluator Collective’s compute-for-safety offers.
