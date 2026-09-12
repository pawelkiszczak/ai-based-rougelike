# Performance budget

## Reference configuration

The named low-power reference is a 2025 MacBook Air-class machine with Apple M4, 16 GB RAM, and macOS 15.5. The game build uses the pinned Godot 4.7-stable editor, the Compatibility renderer, a 640×360 viewport, and the Linux/Windows release presets from `game/export_presets.cfg` for package checks.

The fixed worst-case scenario is `res://scenes/run.tscn` with the full authored mutation pool loaded and the run UI rendering three choices plus the capped run log. Warm up for 300 frames, then sample 600 consecutive frames. Record frame time and peak static memory; report p99 frame time in milliseconds and peak bytes. The 60 fps requirement is p99 ≤ 16.67 ms and peak memory < 1 GiB.

Reference-hardware measurements are intentionally not inferred from shared CI runners. Run the procedure on the named machine and attach the raw report before closing the performance gate.

## CI checks

`tools/validate_performance.py` rejects every Linux/Windows release archive at or above 500 MiB. CI export jobs remain a relative regression and packaging gate; they do not claim to measure the absolute 60 fps or memory threshold. The export job's generated archives and checksums are the reproducible package inputs for the reference report.
