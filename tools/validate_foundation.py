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
        "game/project.godot",
        "game/scenes/main.tscn",
        "prototype/index.html",
        "tools/validate_foundation.py",
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

    project = (ROOT / "game/project.godot").read_text(encoding="utf-8")
    required_project_values = (
        'config/name="Emergence Protocol"',
        'run/main_scene="res://scenes/main.tscn"',
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
