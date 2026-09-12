# Third-party licenses and provenance

This repository currently ships no third-party assets, fonts, models, generated prose, or runtime dependencies. The art, audio, data resources, and scripts under `game/` are authored for this project. The release manifest therefore contains zero third-party shipped paths.

## Third-party shipped paths

`none`

## Build tools and non-shipped dependencies

| Dependency | Version | Source | License | Attribution / constraints | Shipped path |
|---|---|---|---|---|---|
| Godot Engine | 4.7-stable | https://godotengine.org/download/archive/4.7-stable/ | MIT | Used by CI and local development; the engine binary is not bundled in release artifacts. | not shipped |

## Review record

- Reviewed 2026-09-12 against the tracked `game/art`, `game/audio`, `game/content`, `game/sim`, and `game/ui` paths.
- `game/art/manifest.json` is not present; authored SVG assets are not vendor imports.
- `game/audio/manifest.json` references only the eight authored WAV files under `game/audio`.
- Release validation fails if a path explicitly marked as third-party is absent from this record or if a manifest path is missing.
