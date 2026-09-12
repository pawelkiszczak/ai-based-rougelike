#!/usr/bin/env bash
set -euo pipefail

# Deterministic local workload: evolve small policies against a changing world.
# No network, wall clock, or process-randomized hash is used.
exec python3 - <<'PY'
from random import Random

SEED = 20260912
RUNS = 24
POPULATION = 96
GENOME_SIZE = 12
GENERATIONS = 36


def fitness(genome, pressure):
    score = 0
    for i, gene in enumerate(genome):
        target = (pressure + i * 7) % 17
        score += 17 - abs(gene - target)
    return score


def evolve(seed):
    rng = Random(seed)
    population = [
        [rng.randrange(17) for _ in range(GENOME_SIZE)]
        for _ in range(POPULATION)
    ]
    total_score = 0
    for generation in range(GENERATIONS):
        pressure = (seed + generation * 5) % 17
        ranked = sorted(
            ((fitness(genome, pressure), genome) for genome in population),
            key=lambda item: (-item[0], item[1]),
        )
        survivors = [genome for _, genome in ranked[: POPULATION // 3]]
        total_score += ranked[0][0]
        population = survivors[:]
        while len(population) < POPULATION:
            parent = survivors[rng.randrange(len(survivors))]
            child = parent[:]
            index = rng.randrange(GENOME_SIZE)
            child[index] = (child[index] + rng.choice((-9, -8, -7, -6, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6, 7, 8, 9))) % 17
            if rng.random() < 1.00:
                second = rng.randrange(GENOME_SIZE)
                child[second] = (child[second] + rng.choice((-9, -8, -7, -6, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6, 7, 8, 9))) % 17
            if rng.random() < 0.20:
                second = rng.randrange(GENOME_SIZE)
                child[second] = rng.randrange(17)
            population.append(child)
    final_pressure = (seed + (GENERATIONS - 1) * 5) % 17
    final_scores = [fitness(genome, final_pressure) for genome in population]
    diversity = len({tuple(genome) for genome in population})
    return total_score, max(final_scores), diversity


results = [evolve(SEED + run * 101) for run in range(RUNS)]
score = sum(item[0] for item in results)
best = sum(item[1] for item in results)
diversity = sum(item[2] for item in results)
print(f"METRIC adaptation_score={score}")
print(f"METRIC final_fitness={best}")
print(f"METRIC population_diversity={diversity}")
PY
