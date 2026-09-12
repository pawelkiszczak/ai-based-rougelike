# Evaluator Collective

The Evaluator Collective trades compute for short-term safety. Its three visible telegraphs are:

- **Auditor** — exposes unexplained drift;
- **Shield Broker** — pressure rises when compute is scarce, making the compute-for-safety trade explicit;
- **Drift Watcher** — constrains behavior as alignment rises.

The offer families are deterministic and gated by both memory and reputation:

- `safety_layer` is always available and costs 3 compute for 4 safety;
- `interpretability_probe` requires the `accepted_audit` memory flag and reputation `0`, costing 2 compute for 6 safety;
- `drift_insurance` requires the same memory flag and trusted reputation `25`, costing 4 compute for 10 safety.

The `FactionData.available_offers()` contract shows constraints before commitment, applies exact reputation boundaries, and preserves seeded ordering. `game/tests/test_faction_two.gd` covers below/at/above reputation gates, memory visibility, telegraph boundaries, and content fields.
