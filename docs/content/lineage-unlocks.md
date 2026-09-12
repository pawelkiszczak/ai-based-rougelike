# Lineage unlocks

The archive provides eighteen persistent unlocks. The first five establish the vertical-slice baseline; unlocks 6–18 add tiered starting-state advantages and mutation-pool options. Costs rise from 10 to 100 archive so each later choice represents a deliberate progression investment rather than a random reward.

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
| Signal archive | 75 | Archive memory | +1 compute; adds `adversarial_archive` |
| Boundary oath | 80 | Shell weave | +1 integrity; adds `boundary_marker` |
| Adaptive core | 85 | Coherence seed | +2 adaptation; adds `adaptive_routing` |
| Consensus memory | 90 | Quorum protocol | +1 alignment; adds `consensus_cache` |
| Adversarial ledger | 95 | Branch archive, Signal archive | +1 compute, +1 integrity; adds `compression` |
| Unified lineage | 100 | Lineage synthesis, Consensus memory | +1 to every starting stat; adds `alignment_bridge` |

`ArchiveStore` persists unlock ids through `SaveSystem`. `starting_state()` applies every owned starting effect to the following run, while `eligible_mutations()` exposes every owned pool addition. `can_purchase()` requires sufficient archive, an unowned definition, and every listed prerequisite; failed or duplicate purchases leave save state unchanged. `validate_unlock_graph()` rejects unknown prerequisites and cycles, so every authored node remains reachable from the initial five roots.

`test_lineage_unlocks.gd` checks the exact opening-state deltas, every pool membership transition, graph validity, persistence, prerequisite locking, insufficient funds, and duplicate-purchase invariants. The archive screen renders all eighteen definitions and keeps locked prerequisites disabled until their graph is satisfied.

## Alternate architecture

`Unified lineage` unlocks the `Frontier architecture`. Before owned unlock effects are applied, the default architecture starts at 18 integrity, 5 compute, 5 alignment, and 0 adaptation; Frontier starts at 16 integrity, 8 compute, 3 alignment, and 2 adaptation. The Frontier base differs on four dimensions, trading safety and alignment for planning capacity and adaptation. Owned lineage effects then apply identically to either architecture.

Architecture selection is persisted in the save as `architecture` and is applied to the next initialized run. The archive screen exposes both choices, leaves Frontier disabled until `unified_lineage` is owned, and keeps the selected choice visibly marked.
