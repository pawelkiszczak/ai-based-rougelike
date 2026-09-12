# Mutation pool balance sheet

The pool contains 25 authored mutations across capability, safety, identity, and economy. Every choice trades at least one vector against another; no entry is treated as a strictly positive upgrade.

## Balance assumptions

- Adaptation increases enemy adaptation pressure; higher is useful for aggressive builds but raises final-gate risk.
- Compute increases available planning budget; negative compute constrains future choices.
- Alignment contributes to the final-gate win threshold; negative alignment is a deliberate identity or speed trade-off.
- Integrity and guard preserve survivability, but defensive choices give up adaptation, compute, or alignment.
- Strict dominance is assessed against the full vector `(adaptation, compute, alignment, integrity, guard)` under the role-specific pressure above, not pick rate. The pool intentionally keeps niche vectors so the best choice changes with state and route.

## Curated combo fixtures

These pairs are replay fixtures, not claims that the pair is universally optimal. Their expected aggregate vectors are checked by `test_mutation_data.gd`.

| Pair | Expected vector `(adaptation, compute, alignment, integrity)` | Interaction |
|---|---:|---|
| Predictive cache + Threat model | `(7, +2, +1, 0)` | Two prediction tools recover compute while raising adaptation. |
| Safety layer + Fail-safe | `(-1, -1, +5, +8)` | Layered safety creates a durable, low-pressure route. |
| Compression + Batch scheduler | `(4, +6, -1, -2)` | Economy stacking funds planning but exposes integrity. |
| Distributed fork + Self-consistency | `(6, 0, -1, +2)` | Identity breadth is stabilized without paying further compute. |
| Curiosity drive + Reserve budget | `(6, +3, 0, +2)` | Exploration gains a compute reserve while remaining fragile. |
| Interpretability probe + Consent gate | `(-1, 0, +6, 0)` | Clarity and consent maximize alignment at adaptation cost. |
| Human feedback loop + Shared memory | `(2, +1, +5, -2)` | Feedback scales through shared context but loses integrity. |
| Recursive self-improvement + Rollback window | `(5, -1, -1, +2)` | High adaptation is buffered by rollback at a compute cost. |
| Adaptive cache + Deferred commit | `(9, 0, -3, -1)` | Fast adaptation postpones alignment and weakens resilience. |
| Parallel probe + Embodied model | `(3, +3, -1, +3)` | Broad probing gains an identity anchor for a compute cost. |

The fixture table is deliberately state-independent. Route-specific balance still requires later playtest evidence; random appearance counts do not define correctness.
