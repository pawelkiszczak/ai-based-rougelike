# Lineage unlocks

The archive provides twelve persistent unlocks. The first five establish the vertical-slice baseline; unlocks 6–12 add tiered starting-state advantages and mutation-pool options. Costs rise from 10 to 70 archive so each later choice represents a deliberate progression investment rather than a random reward.

| Unlock | Cost | Prerequisites | Effect |
|---|---:|---|---|
| Deep reserves | 10 | — | +2 starting compute |
| Hardened shell | 15 | — | +3 starting integrity |
| Alignment lens | 20 | — | +2 starting alignment |
| Threat model | 25 | — | Adds `threat_model` to the mutation pool |
| Audit trail | 30 | — | Adds `audit_trail` to the mutation pool |
| Reserve matrix | 35 | Deep reserves | +2 compute; adds `batch_scheduler` |
| Shell weave | 40 | Hardened shell | +1 integrity; adds `anticipatory_defense` |
| Coherence seed | 45 | Alignment lens | +2 adaptation; adds `coherence_kernel` |
| Archive memory | 50 | Threat model | +1 compute, +1 alignment; adds `adaptive_cache` |
| Quorum protocol | 55 | Audit trail | +1 integrity, +1 alignment; adds `consensus_mesh` |
| Branch archive | 60 | Reserve matrix, Archive memory | +1 compute, +2 adaptation; adds `branch_predictor` |
| Lineage synthesis | 70 | Coherence seed, Branch archive | +1 to every starting stat; adds `cascade_engine` |

`ArchiveStore` persists unlock ids through `SaveSystem`. `starting_state()` applies every owned starting effect to the following run, while `eligible_mutations()` exposes every owned pool addition. `can_purchase()` requires sufficient archive, an unowned definition, and every listed prerequisite; failed or duplicate purchases leave save state unchanged. `validate_unlock_graph()` rejects unknown prerequisites and cycles, so every authored node remains reachable from the initial five roots.

`test_lineage_unlocks.gd` checks the exact opening-state deltas, every pool membership transition, graph validity, persistence, prerequisite locking, insufficient funds, and duplicate-purchase invariants. The archive screen renders all twelve definitions and keeps locked prerequisites disabled until their graph is satisfied.
