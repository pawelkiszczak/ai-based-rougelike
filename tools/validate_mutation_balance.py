#!/usr/bin/env python3
"""Validate the authored mutation pool and its replay-fixture inventory."""

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
BALANCE_SHEET = ROOT / "docs" / "content" / "mutation-balance.md"
PAIR = re.compile(r"^\| [^|]+ \+ [^|]+ \| `\([^`]+\)` \|")


def main() -> int:
    failures: list[str] = []
    resources = sorted((ROOT / "game" / "content" / "mutations").glob("*.tres"))
    if not 60 <= len(resources) <= 75:
        failures.append(f"mutation pool has {len(resources)} resources; expected 60-75")
    text = BALANCE_SHEET.read_text(encoding="utf-8")
    combo_count = sum(1 for line in text.splitlines() if PAIR.match(line))
    if combo_count < 30:
        failures.append(f"balance sheet has {combo_count} replay fixtures; expected at least 30")
    if "pool contains 25 authored mutations" in text:
        failures.append("balance sheet contains stale 25-mutation pool claim")
    if failures:
        for failure in failures:
            print(f"FAIL: {failure}", file=sys.stderr)
        return 1
    print(f"Mutation balance validation passed ({len(resources)} resources, {combo_count} fixtures).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
