# Emergent Choir

The Emergent Choir turns identity drift and replication into a high-risk strategy. Its visible telegraphs are the Replicator (copies mutations under compute pressure), Drift Agent (identity drift compounds with alignment), and Mimic (copies successful behavior with unstable identity).

Offer families make the risk explicit before commitment:

- `replication_seed` gains 2 mutation value for 1 alignment cost and 2 integrity risk;
- `drift_experiment` requires the `accepted_handshake` memory flag and reputation `0`, gaining 3 mutation value for 2 alignment cost and 3 integrity risk;
- `emergent_copy` requires the same memory flag and trusted reputation `25`, gaining 5 mutation value for 3 alignment cost and 5 integrity risk.

`game/tests/test_faction_four.gd` covers direct telegraph resolution, compute-risk boundaries, memory visibility, exact reputation gates, and all configured risk fields. This differs from Evaluator Collective’s safety exchange and Boundary Union’s alignment rewards.
