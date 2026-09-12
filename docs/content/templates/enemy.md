# Enemy template

Enemies are authored pressure sources. Their behavior is deterministic and their intent is visible before the player commits.

## Fields

| Field | Type | Range / constraints | Description |
|---|---|---|---|
| `id` | string | Unique `snake_case` id | Stable encounter/content reference. |
| `name` | string | Non-empty, ≤40 characters | Player-facing enemy name. |
| `faction_id` | string | References one faction id | Owning faction and reputation context. |
| `archetype` | enum | `explore`, `defend`, `replicate`, `persuade`, or `predict` | Authored behavior primitive used by the director. |
| `base_pressure` | integer | 0 to 24 | Pressure before player defenses and modifiers. |
| `guard` | integer | 0 to 12 | Additional defense when this enemy is the active threat. |
| `behavior` | string | Stable rule id, not free-form code | References an authored deterministic behavior rule. |
| `telegraph` | string | Non-empty, ≤180 characters | Explains the next pressure and counterplay. |
| `codex_text` | string | Non-empty, ≤500 characters | Mechanics explanation shown after discovery. |

## Example

```text
id: mirror_probe
name: Mirror probe
faction_id: evaluator_collective
archetype: predict
base_pressure: 7
guard: 2
behavior: predict_low_alignment
telegraph: It models your weakest alignment signal before the next choice.
codex_text: A forecasting process that redirects pressure toward exposed alignment gaps.
```
