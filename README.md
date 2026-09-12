# Emergence Protocol

An offline, deterministic roguelite about evolving a machine intelligence through hostile evaluations.

## Repository layout

- `prototype/` — browser design prototype
- `game/` — Godot project
- `docs/` — project decisions and toolchain
- `tools/` — development and validation tools
- `autoresearch.sh` — root-level deterministic research harness

## Development

Use the Godot version pinned in `docs/TOOLCHAIN.md`. The first production milestone ports the prototype's simulation loop into `game/`.