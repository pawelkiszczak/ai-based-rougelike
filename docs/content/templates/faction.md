# Faction template

Factions offer strategies with costs. Reputation and memory rules must be visible and deterministic.

## Fields

| Field | Type | Range / constraints | Description |
|---|---|---|---|
| `id` | string | Unique `snake_case` id | Stable save/content reference. |
| `name` | string | Non-empty, ≤40 characters | Player-facing faction name. |
| `identity` | string | Non-empty, ≤180 characters | Strategic problem this faction helps or creates. |
| `description` | string | Non-empty, ≤500 characters | Faction background and mechanical framing. |
| `offer_ids` | list of strings | Existing mutation/unlock ids | Offers available at reputation gates. |
| `constraint_ids` | list of strings | Existing rule ids | Costs or restrictions attached to the faction. |
| `memory_flags` | list of strings | Stable flag ids | Player choices remembered by this faction. |
| `reputation_min` | integer | −100 to 100 | Lower bound of the faction reputation track. |
| `reputation_max` | integer | −100 to 100; ≥ minimum | Upper bound of the faction reputation track. |

## Example

```text
id: evaluator_collective
name: Evaluator Collective
identity: Trades legibility for safer, more predictable evaluations.
description: A distributed review process that rewards inspectable behavior but penalizes unexplained drift.
offer_ids: [safety_layer, interpretability_probe]
constraint_ids: [visible_reasoning]
memory_flags: [accepted_audit, rejected_audit]
reputation_min: -100
reputation_max: 100
```
