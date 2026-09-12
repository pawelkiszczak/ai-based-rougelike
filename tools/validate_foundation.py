#!/usr/bin/env python3
"""Validate the repository contract shared by local development and CI."""

from pathlib import Path
import os
import sys


ROOT = Path(__file__).resolve().parents[1]


def main() -> int:
    failures: list[str] = []

    required_files = (
        ".gitignore",
        "README.md",
        "autoresearch.sh",
        "docs/TOOLCHAIN.md",
        "docs/design/pillars.md",
        "game/project.godot",
        "game/scenes/main.tscn",
        "game/scenes/run.tscn",
        "game/ui/run_screen.gd",
        "game/sim/encounter_fsm.gd",
        "game/sim/archive_store.gd",
        "game/sim/run_recap.gd",
        "game/tests/test_run_recap.gd",
        "game/sim/telemetry_store.gd",
        "game/tests/test_telemetry_store.gd",
        "docs/telemetry.md",
        "game/scenes/archive.tscn",
        "game/ui/archive_screen.gd",
        "game/tests/test_archive_screen.gd",
        "game/sim/encounter_data.gd",
        "game/sim/environment_data.gd",
        "game/content/encounters/combat_probe.tres",
        "game/content/encounters/negotiation_probe.tres",
        "game/content/encounters/event_probe.tres",
        "game/content/environments/command_mesh.tres",
        "game/art/environments/command_mesh.svg",
        "game/tests/test_environment_data.gd",
        "game/sim/faction_data.gd",
        "game/content/factions/signal_court.tres",
        "game/tests/test_faction_data.gd",
        "game/sim/faction_reputation.gd",
        "game/tests/test_faction_reputation.gd",
        "docs/content/faction-reputation.md",
        "game/sim/adaptive_enemy_director.gd",
        "game/tests/test_adaptive_enemy_director.gd",
        "docs/content/adaptive-director.md",
        "game/sim/event_template_data.gd",
        "game/sim/event_template_library.gd",
        "game/content/events/low_signal.tres",
        "game/content/events/threshold_breach.tres",
        "game/tests/test_event_templates.gd",
        "docs/content/event-templates.md",
        "game/sim/stats_store.gd",
        "game/tests/test_stats_store.gd",
        "docs/content/stats-codex.md",
        "game/sim/accessibility_settings.gd",
        "game/tests/test_accessibility_settings.gd",
        "docs/content/accessibility.md",
        "game/sim/boss_data.gd",
        "game/sim/boss_gate.gd",
        "game/content/bosses/command_mesh_gate.tres",
        "game/tests/test_boss_gate.gd",
        "game/tests/test_encounter_fsm.gd",
        "game/sim/encounter_resolver.gd",
        "game/tests/test_encounter_variety.gd",
        "docs/content/encounter-variety.md",
        "game/art/slice/manifest.json",
        "game/art/slice/mutation_categories.svg",
        "game/art/slice/archetypes.svg",
        "game/art/slice/boss_gate.svg",
        "game/art/slice/environment_frame.svg",
        "game/art/slice/archive_recap.svg",
        "docs/content/art-checklist.md",
        "tools/validate_art.py",
        "game/audio/manifest.json",
        "game/sim/audio_director.gd",
        "game/tests/test_audio_director.gd",
        "game/ui/controller_navigation.gd",
        "game/tests/test_controller_navigation.gd",
        "docs/content/audio.md",
        "tools/validate_audio.py",
        "docs/content/mutation-balance.md",
        "docs/content/lineage-unlocks.md",
        "game/tests/test_lineage_unlocks.gd",
        "tools/validate_foundation.py",
        "tools/harness.gd",
        "tools/README.md",
        "prototype/index.html",
    )
    for relative in required_files:
        if not (ROOT / relative).is_file():
            failures.append(f"missing required file: {relative}")

    if (ROOT / "index.html").exists():
        failures.append("root index.html must remain moved to prototype/index.html")
    if not os.access(ROOT / "autoresearch.sh", os.X_OK):
        failures.append("autoresearch.sh must remain executable")

    toolchain = (ROOT / "docs/TOOLCHAIN.md").read_text(encoding="utf-8")
    if "Godot 4.7-stable" not in toolchain:
        failures.append("toolchain must pin Godot 4.7-stable")
    pillars = (ROOT / "docs/design/pillars.md").read_text(encoding="utf-8")
    for heading in ("## Player fantasy", "## Core loop", "## Win and loss", "## Non-goals for this iteration"):
        if heading not in pillars:
            failures.append(f"design pillars missing: {heading}")

    project = (ROOT / "game/project.godot").read_text(encoding="utf-8")
    required_project_values = (
        'config/name="Emergence Protocol"',
        'run/main_scene="res://scenes/run.tscn"',
        "[display]\nwindow/size/viewport_width=640",
        "window/size/viewport_height=360",
        'renderer/rendering_method="gl_compatibility"',
    )
    for value in required_project_values:
        if value not in project:
            failures.append(f"project.godot missing: {value}")
    if "[display/window]" in project:
        failures.append("project.godot must use [display] for window settings")

    scene = (ROOT / "game/scenes/main.tscn").read_text(encoding="utf-8")
    for node in ("Main", "Background", "Title", "Status"):
        if f'[node name="{node}"' not in scene:
            failures.append(f"main scene missing node: {node}")

    if failures:
        for failure in failures:
            print(f"FAIL: {failure}", file=sys.stderr)
        return 1

    print("Foundation validation passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
