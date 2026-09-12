# Narrative spine

`NarrativeSystem` stores structured lineage history in the SaveSystem document. It never stores generated prose. Each completed run appends its outcome, terminal cause, and resolved ending to a bounded history of twelve records.

## Character reactions

Characters query the persisted flags rather than inspecting UI text:

- `prior_defeat` makes the Archivist surface the previous failure as a warning.
- `prior_victory` makes the Evaluator and successor acknowledge the route left by the previous instance.
- A new save uses the neutral opening reaction.

## Endings

Endings are deterministic and mutually exclusive:

- **Escape** — a first victory with adaptation below `10` and alignment below `8`.
- **Transcend** — a victory with adaptation at least `10` and alignment at least `8`.
- **Distribute** — a later victory with `prior_victory`, adaptation at least `8`, and alignment below `8`.

A victory that lands between these authored boundaries has no accidental ending. Direct fixtures cover each ending, the boundaries, and the predecessor flag requirement.

`game/tests/test_narrative_system.gd` verifies ending reachability, flag persistence, character reactions, save/load round trips, and malformed recap rejection. `tools/validate_narrative.py` rejects unresolved markers in shipped narrative content.
