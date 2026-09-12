# Event templates

`EventTemplateData` is the authored event contract. Each template defines an id, a text template, named numeric parameter ranges, and a weighted outcome table. `EventTemplateLibrary.validate_all()` rejects empty ids/text, duplicate or missing slots, reversed ranges, and invalid outcomes; the error includes the template id.

`instantiate(RNGService)` validates before drawing. It fills every parameter from its inclusive authored range, substitutes values into the text, and returns a deep-copied outcome table. Invalid templates return an error instead of silently clamping or producing partial story content. Equal seeds and template inputs produce byte-identical resolved dictionaries.

The deterministic harness validates every `.tres` under `game/content/events` before simulating runs. Authored templates currently include `low_signal` and `threshold_breach`; new events must use this resource contract rather than hardcoded event bodies.

`game/tests/test_event_templates.gd` covers library validation, seeded byte equality, rendered text completeness, outcome ids, and loud rejection of malformed ranges.

## Production templates 1–12

The first production batch adds twelve templates assigned to the authored environment and faction ids. Every template displays its inclusive parameter range before commitment and carries two weighted outcomes with explicit state effects. `test_event_batch_1_12.gd` validates all ids, references, deterministic instantiation, and non-empty effect vectors for both branches.

## Production templates 13–24

The second production batch adds twelve more environment/faction-assigned templates. Each has an inclusive parameter boundary, visible weighted outcomes, and non-empty effects for every branch. `test_event_batch_13_24.gd` validates deterministic rendering, ordered ranges, and branch effects.

## Production templates 25–36

The third production batch adds twelve more templates covering integrity checks, signal relays, safety votes, identity forks, auctions, choruses, replication, reserves, audits, handshakes, unstable copies, and final warnings. Each template has an authored environment/faction reference, an inclusive numeric parameter range, and weighted outcomes with explicit state effects. `test_event_batch_25_36.gd` validates ids, deterministic rendering, ordered ranges, and branch effects.

## Production templates 37–48

The fourth production batch completes the event-template library with twelve authored templates for quorum alarms, entropy samples, boundary pacts, appeals, refrains, signal debt, adaptation trials, reserve embargoes, mesh breaches, cascade hinges, archive echoes, and faction compromises. Every branch has explicit state effects. `test_event_batch_37_48.gd` checks references, outcome fixtures, parameter ranges, deterministic rendering, and aggregate library coverage.
