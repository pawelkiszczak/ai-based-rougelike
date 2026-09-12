#!/usr/bin/env python3
"""Enforce the distribution package size budget."""

from pathlib import Path
import sys


MAX_PACKAGE_BYTES = 500 * 1024 * 1024


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: validate_performance.py EXPORT_DIRECTORY", file=sys.stderr)
        return 2
    export_dir = Path(sys.argv[1])
    packages = sorted(export_dir.glob("*.zip"))
    if not packages:
        print(f"no release packages found in {export_dir}", file=sys.stderr)
        return 1
    failures: list[str] = []
    for package in packages:
        size = package.stat().st_size
        print(f"{package.name}: {size} bytes")
        if size >= MAX_PACKAGE_BYTES:
            failures.append(f"{package.name} exceeds 500 MiB")
    if failures:
        for failure in failures:
            print(f"FAIL: {failure}", file=sys.stderr)
        return 1
    print("Package size validation passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
