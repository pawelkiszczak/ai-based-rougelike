# Performance budget

## Reference configuration

The current measured host is an Apple M4 Max workstation running Darwin 25.5.0; its RAM capacity is not part of the repository evidence. This host is not treated as the required low-power reference. The release build uses the pinned Godot 4.7-stable editor, the Compatibility renderer, a 640×360 viewport, and the Linux/Windows release presets from `game/export_presets.cfg` for package checks.

The fixed worst-case scenario is `res://scenes/run.tscn` with the full authored mutation pool loaded and the run UI rendering three choices plus the capped run log. `tools/performance_probe.gd` warms up for 300 frames, then samples 600 consecutive frames. It reports p99 frame time in milliseconds and peak static memory; the 60 fps requirement is p99 ≤ 16.67 ms and peak memory < 1 GiB.

Run the probe with:

```text
godot --headless --path game -s ../tools/performance_probe.gd
```

Reference-hardware measurements are not inferred from shared CI runners. A low-power machine must still be named and measured before closing the performance gate.

## CI checks

`tools/validate_performance.py` rejects every Linux/Windows release archive at or above 500 MiB. CI export jobs remain a relative regression and packaging gate; they do not claim to measure the absolute 60 fps or memory threshold. The export job's generated archives and checksums are the reproducible package inputs for the reference report.
