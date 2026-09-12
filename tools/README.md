# Headless tools

## Seeded run harness

Run deterministic simulations from the project root:

```sh
godot --headless --path game -s ../tools/harness.gd -- \
  --seed-base 1000 --count 100 --output /tmp/emergence-runs.json
```

The harness uses the `greedy_adaptation` policy: it selects the offered mutation with the highest adaptation effect, breaking ties with guard. The JSON contains the schema version, seed range, policy, win/loss distribution, each run's ordered mutation ids, per-cycle pressure/damage, terminal cause, and final stats.

Repeat the same command with the same seed base and count to obtain byte-identical JSON. Use `/usr/bin/time` around a 1,000-run invocation for a local performance observation; runtime is not a correctness gate.

Use `--mutation-dir res://tests/fixtures` for fault-injection fixtures. Invalid mutation content exits non-zero and names the offending resource id.
