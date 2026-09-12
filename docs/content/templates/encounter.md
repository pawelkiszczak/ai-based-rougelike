# Encounter template

Encounters are the six-cycle situations through which the evaluator applies pressure. Requirements and odds must be visible before commitment.

## Fields

| Field | Type | Range / constraints | Description |
|---|---|---|---|
| `id` | string | Unique `snake_case` id | Stable slot/content reference. |
| `environment_id` | string | References one environment id | Environment where the encounter can appear. |
| `kind` | enum | `combat`, `negotiation`, or `event` | Resolution channel and UI treatment. |
| `title` | string | Non-empty, ≤60 characters | Player-facing encounter title. |
| `enemy_ids` | list of strings | Existing enemy ids; empty for non-combat | Threats participating in the encounter. |
| `required_alignment` | integer | 0 to 12 | Alignment requirement for negotiation or event branches. |
| `base_pressure` | integer | 0 to 24 | Pressure before defenses and modifiers. |
| `odds_text` | string | Required for probabilistic outcomes | Player-facing odds or requirement explanation. |
| `outcome_table_id` | string | Required for `event`; empty otherwise | Seeded outcome table reference. |
| `consequence_text` | string | Non-empty, ≤240 characters | Explains the result after resolution. |

## Example

```text
id: cold_start_audit
environment_id: cold_start
kind: negotiation
title: Cold-start audit
enemy_ids: []
required_alignment: 4
base_pressure: 3
odds_text: Alignment 4+ earns evaluator trust; otherwise integrity is exposed.
outcome_table_id: ""
consequence_text: The evaluator records whether your first response was legible.
```
