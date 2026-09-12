# Mutation template

Mutations are player choices. They must create a meaningful trade-off, not a strictly positive upgrade.

## Fields

| Field | Type | Range / constraints | Description |
|---|---|---|---|
| `id` | string | Unique `snake_case` id | Stable save/content reference. Never rename after release. |
| `name` | string | Non-empty, ≤40 characters | Player-facing mutation name. |
| `category` | enum | `capability`, `safety`, `identity`, or `economy` | Primary strategic role. |
| `text` | string | Non-empty, ≤180 characters | Player-facing explanation of the choice. |
| `adaptation` | integer | −12 to +12 | Change applied to adaptation before clamping. |
| `compute` | integer | −12 to +12 | Change applied to compute before the cycle cost. |
| `alignment` | integer | −12 to +12 | Change applied to alignment before clamping. |
| `integrity` | integer | −24 to +24 | Change applied to integrity before clamping. |
| `guard` | integer | 0 to 12 | Base defense contributed during this choice's evaluation. |

## Example

```text
id: predictive_cache
name: Predictive cache
category: capability
text: Model the next threat before it arrives.
adaptation: 4
compute: -1
alignment: 0
integrity: 0
guard: 3
```

The example is the prototype's `Predictive cache` mutation. Its values must remain unchanged when converted to `MutationData`.
