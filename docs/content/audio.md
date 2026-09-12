# Slice audio contract

The audio manifest owns six SFX events and two loop tracks. `AudioDirector` records each event once per transition, changes to the boss track on the boss tell, and persists linear bus levels in `SaveSystem`.

| Event | Owner signal | Asset |
|---|---|---|
| `choice` | mutation choice committed | `sfx/choice.wav` |
| `damage` | damage resolved | `sfx/damage.wav` |
| `unlock` | archive purchase accepted | `sfx/unlock.wav` |
| `win` | final gate victory | `sfx/win.wav` |
| `lose` | integrity loss/final rejection | `sfx/lose.wav` |
| `boss_tell` | phase escalation preview | `sfx/boss_tell.wav` |

The environment loop is the default track. `begin_boss_crossfade()` transitions to the boss loop when the tell is emitted, not when phase two resolves. Bus levels are linear `[0, 1]`; `0` is fully muted.
