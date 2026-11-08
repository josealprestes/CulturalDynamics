"""Targeted mutation testing for CulturalDynamics core (F7).

Usage:  py -3 scripts/mutation.py
Runs each mutant against the FULL suite (268 tests, ~30s each after
precompile) in a fresh Julia process. Every mutant is reverted in a
`finally` block; aborts if target files are dirty before starting.

Target fixed BEFORE measuring (F7 plan): kill >= 70% of non-equivalent
mutants. Equivalent mutants (no behavior change by construction) are
reported separately, never counted. A surviving non-equivalent mutant is a
finding about the suite (weak oracle), not a failure of this script.

SOTA: MutGen (TSE 2026) — mutation score beats coverage as a quality signal;
100% line coverage can coexist with ~4% mutation score.
"""
import subprocess
import sys
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
JULIA = "julia"

# (id, file, old, new, rationale, expectation)
MUTANTS = [
    ("M1", "src/core/regions.jl",
     "agent.features != nagent.features && continue",
     "agent.features == nagent.features && continue",
     "inverts region union: all agents fuse into 1 region", "KILLED"),
    ("M2", "src/core/regions.jl",
     "largest_share = n > 0 ? largest / n : 0.0",
     "largest_share = n > 0 ? largest / (n + 1) : 0.0",
     "off-by-one in share denominator; no exact share oracle in suite",
     "SURVIVE-WEAK-ORACLE"),
    ("M3", "src/core/model.jl",
     "trait_idx = rand(abmrng(model), differing)",
     "trait_idx = differing[1]",
     "deterministic-first trait choice changes trajectories/goldens",
     "KILLED"),
    ("M4", "src/core/model.jl",
     "similarity < config.bounded_confidence_threshold && return",
     "similarity <= config.bounded_confidence_threshold && return",
     "boundary IS exercised (suite uses eps=0.2: similarity 0.2 blocked); "
     "verified KILLED 2026-10-13, first run flagged wrong EQUIVALENT guess",
     "KILLED"),
    ("M5", "src/core/metrics.jl",
     "total += (f - 1) / denom",
     "total += f / denom",
     "shifts partial_compliance; goldens use isapprox 1e-12", "KILLED"),
    ("M6", "src/core/metrics.jl",
     "return overlap / config.F",
     "return overlap / (config.F + 1)",
     "scales all similarities; copy probs and goldens move", "KILLED"),
    ("M7", "src/core/neighborhoods.jl",
     "CartesianIndex(1, 0), CartesianIndex(-1, 0)]",
     "CartesianIndex(1, 0)]",
     "VonNeumann loses a direction; trajectories/goldens move", "KILLED"),
    ("M8", "src/core/model.jl",
     "agent.features[trait_idx] = partner.features[trait_idx]",
     "agent.features[trait_idx] = config.Q",
     "copy becomes directional push to Q; goldens move", "KILLED"),
    ("M9", "src/core/metrics.jl",
     "habitual = count(a -> a.system2_weight < 0.5, agents_list)",
     "habitual = count(a -> a.system2_weight <= 0.5, agents_list)",
     "boundary: decay 1.0->0.1 by zeta never lands exactly on 0.5",
     "EQUIVALENT"),
    ("M10", "src/core/model.jl",
     "config.textbook && return similarity * config.copy_scale",
     "config.textbook && return similarity",
     "NOT a no-op: suite covers copy_scale!=1.0 (coupling tests); "
     "verified KILLED 2026-10-13, first run flagged wrong EQUIVALENT guess",
     "KILLED"),
]


def run_suite():
    r = subprocess.run(
        [JULIA, "--project=.", "-e", "using Pkg; Pkg.test()"],
        capture_output=True, text=True, cwd=ROOT, timeout=1500)
    out = (r.stdout or "") + (r.stderr or "")
    killed = ("tests failed" in out or "Test Failed" in out
              or "Error During Test" in out or "Got exception" in out)
    tail = "\n".join(out.strip().splitlines()[-3:])
    return killed, tail


def main():
    dirty = subprocess.run(["git", "status", "--porcelain"] + [m[1] for m in
                           {m[1] for m in [(x[0], x[1]) for x in MUTANTS]}],
                           capture_output=True, text=True, cwd=ROOT)
    targets = sorted({m[1] for m in MUTANTS})
    r = subprocess.run(["git", "status", "--porcelain"] + targets,
                       capture_output=True, text=True, cwd=ROOT)
    if r.stdout.strip():
        print("REFUSE: target files dirty:\n" + r.stdout)
        sys.exit(2)
    print(f"{len(MUTANTS)} mutants, target kill>=70% of non-equivalent")
    results = []
    for mid, rel, old, new, why, expect in MUTANTS:
        fp = os.path.join(ROOT, *rel.split("/"))
        with open(fp, encoding="utf-8") as f:
            src = f.read()
        assert src.count(old) == 1, f"{mid}: pattern found {src.count(old)}x"
        bak = fp + ".mutbak"
        try:
            with open(bak, "w", encoding="utf-8") as f:
                f.write(src)
            with open(fp, "w", encoding="utf-8") as f:
                f.write(src.replace(old, new))
            killed, tail = run_suite()
            verdict = "KILLED" if killed else "SURVIVED"
            ok = ((expect == "KILLED" and killed)
                  or (expect in ("EQUIVALENT", "SURVIVE-WEAK-ORACLE")
                      and not killed))
            flag = "" if ok else "  <-- UNEXPECTED, finding"
            print(f"{mid} {verdict} (expected {expect}){flag} :: {why}")
            print(f"    tail: {tail}")
            results.append((mid, killed, expect))
        finally:
            with open(bak, encoding="utf-8") as f:
                orig = f.read()
            with open(fp, "w", encoding="utf-8") as f:
                f.write(orig)
            os.remove(bak)
    scoring = [(m, k) for (m, k, e) in results if e != "EQUIVALENT"]
    kills = sum(1 for _, k in scoring if k)
    score = kills / len(scoring) if scoring else 1.0
    print(f"---- mutation score: {kills}/{len(scoring)} = {score:.0%} "
          f"(target >=70%) ----")
    weak = [m for (m, k, e) in results
            if e == "SURVIVE-WEAK-ORACLE" and not k]
    if weak:
        print(f"WEAK-ORACLE findings (backlog, not failure): {weak}")
    sys.exit(0 if score >= 0.70 else 1)


if __name__ == "__main__":
    main()
