# Environment 1 encounter channels

Environment 1 exposes one encounter of each kind. Each kind declares its commitment information before resolution:

| Kind | Resolution channel | Pre-commit information |
|---|---|---|
| Combat | Defense versus incoming pressure | Pressure and defense requirement |
| Negotiation | Alignment threshold, reduced by faction memory | Required alignment |
| Event | Seeded weighted outcome table | Exact configured odds |

`EncounterResolver` is authored deterministic logic. Combat boundaries use guard plus alignment defense; negotiation uses current alignment plus the remembered-faction bonus; events consume the run RNG only after their odds are shown. `test_encounter_variety.gd` constructs each boundary directly and compares same-seed event outcomes.
