#!/usr/bin/env python3
"""Validate the build metadata embedded in exported packages."""

import json
import sys
from pathlib import Path

REQUIRED = ("version", "source_commit", "build_timestamp", "channel")


def validate(path: Path) -> None:
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError("build metadata must be an object")
    for key in REQUIRED:
        if not isinstance(data.get(key), str) or not data[key]:
            raise ValueError(f"build metadata field is empty: {key}")


def main() -> int:
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("game/build_metadata.json")
    validate(path)
    print(f"Build metadata validation passed: {path}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, json.JSONDecodeError) as error:
        raise SystemExit(str(error))
