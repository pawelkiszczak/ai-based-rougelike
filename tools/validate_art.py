#!/usr/bin/env python3
"""Validate the locked slice art manifest and palette usage."""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST_PATH = ROOT / "game/art/slice/manifest.json"
HEX = re.compile(r"#[0-9a-fA-F]{6}")


def main() -> int:
    manifest = json.loads(MANIFEST_PATH.read_text())
    palette = {color.lower() for color in manifest["palette"]}
    failures = []
    for asset_id, filename in manifest["assets"].items():
        path = MANIFEST_PATH.parent / filename
        if not path.is_file():
            failures.append(f"missing art asset: {asset_id} ({path})")
            continue
        source = path.read_text()
        if 'viewBox=' not in source or '<svg ' not in source:
            failures.append(f"art asset lacks SVG geometry: {asset_id}")
        for color in HEX.findall(source):
            if color.lower() not in palette:
                failures.append(f"{asset_id} uses undeclared palette color: {color}")
    if failures:
        for failure in failures:
            print(failure)
        return 1
    print(f"Art validation passed ({len(manifest['assets'])} assets).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
