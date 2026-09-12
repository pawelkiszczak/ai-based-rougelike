#!/usr/bin/env python3
"""Validate manifest references and readable WAV headers."""

import json
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "game/audio/manifest.json"


def main() -> int:
    manifest = json.loads(MANIFEST.read_text())
    failures = []
    assets = {**manifest["sfx"], **manifest["music"]}
    for audio_id, relative in assets.items():
        path = MANIFEST.parent / relative
        if not path.is_file():
            failures.append(f"missing audio asset: {audio_id}")
            continue
        try:
            with wave.open(str(path), "rb") as source:
                if source.getnchannels() < 1 or source.getframerate() < 1 or source.getnframes() < 1:
                    failures.append(f"empty audio asset: {audio_id}")
        except wave.Error as error:
            failures.append(f"invalid WAV asset {audio_id}: {error}")
    if failures:
        for failure in failures:
            print(failure)
        return 1
    print(f"Audio validation passed ({len(assets)} assets).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
