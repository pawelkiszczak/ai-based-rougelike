#!/usr/bin/env python3
"""Validate third-party provenance paths against the license record."""

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
LICENSES = ROOT / "docs" / "LICENSES.md"
ASSET_ROOTS = [ROOT / "game" / name for name in ("art", "audio", "content", "sim", "ui")]


def main() -> int:
    text = LICENSES.read_text(encoding="utf-8")
    if "## Third-party shipped paths" not in text:
        raise SystemExit("license record is missing the shipped-path section")
    declared = sorted(set(re.findall(r"\|\s*`([^`]+)`\s*\|", text)))
    for relative_path in declared:
        path = ROOT / relative_path
        if not path.exists():
            raise SystemExit(f"license manifest path is missing: {relative_path}")
    detected = sorted(
        str(path.relative_to(ROOT))
        for root in ASSET_ROOTS
        if root.exists()
        for path in root.rglob("*")
        if path.is_file() and "third-party" in str(path.relative_to(ROOT)).lower()
    )
    if detected != declared:
        raise SystemExit(f"third-party shipped paths differ: detected={detected}, declared={declared}")
    print(f"License validation passed ({len(declared)} third-party shipped paths).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
