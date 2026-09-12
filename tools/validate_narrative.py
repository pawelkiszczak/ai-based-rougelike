#!/usr/bin/env python3
"""Reject unresolved markers in shipped narrative content."""

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
NARRATIVE_FILES = (
    ROOT / "game" / "sim" / "narrative_system.gd",
    ROOT / "docs" / "content" / "narrative.md",
)
MARKER = re.compile(r"\b(?:TODO|FIXME|placeholder)\b", re.IGNORECASE)


def main() -> int:
    failures: list[str] = []
    for path in NARRATIVE_FILES:
        if not path.is_file():
            failures.append(f"missing narrative file: {path.relative_to(ROOT)}")
            continue
        for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if MARKER.search(line):
                failures.append(f"placeholder marker in {path.relative_to(ROOT)}:{line_number}")
    if failures:
        for failure in failures:
            print(failure, file=sys.stderr)
        return 1
    print("Narrative validation passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
