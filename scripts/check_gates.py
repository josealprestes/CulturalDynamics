"""Deterministic public gates for CulturalDynamics (stdlib only).

Usage:  py -3 scripts/check_gates.py
Exit 0 = all gates green.

This is the public counterpart of the private gate runner. The manuscript
gates (paper static integrity, number-to-CSV checker, private skills sync)
stay in the private repository. Here G2/G3/G4/G7 are adapted to the public
surface: runner wiring, README structure, public counts and docs/code sync.
"""
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
fails = []
waived = []


def path(*parts):
    return os.path.join(ROOT, *parts)


def read(rel):
    with open(path(*rel.split("/")), encoding="utf-8", errors="replace") as f:
        return f.read()


def gate(gid, name, ok, detail=""):
    print(("PASS " if ok else "FAIL ") + gid + " " + name +
          (f" [{detail}]" if detail else ""))
    if not ok:
        fails.append(gid)


def g1():
    bad, ok_waived = [], []
    for dirpath, _, files in os.walk(path("test")):
        for fn in sorted(files):
            if not fn.endswith(".jl"):
                continue
            fp = os.path.join(dirpath, fn)
            with open(fp, encoding="utf-8", errors="replace") as f:
                for i, line in enumerate(f, 1):
                    if "|| true" in line:
                        rel = os.path.relpath(fp, ROOT)
                        if "GATE-WAIVER" in line:
                            ok_waived.append(f"{rel}:{i}")
                        else:
                            bad.append(f"{rel}:{i}")
    for w in ok_waived:
        print(f"WAIVED G1 vacuous-test waiver [{w}]")
        waived.append("G1:" + w)
    gate("G1", "no unwaived vacuous tests in test/",
         not bad, "; ".join(bad) if bad else f"{len(ok_waived)} waived")


def g2():
    ps = read("scripts/run_checks.ps1")
    sh = read("scripts/run_checks.sh")
    demo = os.path.isfile(path("apresentacao", "test", "demo.test.mjs"))
    compiles = subprocess.run(
        [sys.executable, "-m", "py_compile", path("scripts", "check_gates.py")],
        capture_output=True).returncode == 0
    ok = ("node --test" in ps and "node --test" in sh and demo and compiles)
    gate("G2", "public runner + demo wiring", ok,
         f"ps={('node --test' in ps)} sh={('node --test' in sh)} "
         f"demo={demo} compile={compiles}")


def g3():
    readme = read("README.md")
    sections = [
        "## Sobre", "## Como executar", "## Testes e verificação local",
        "## Reprodutibilidade", "## Contexto acadêmico",
        "## Metodologia de desenvolvimento", "## Licença", "## Citação",
    ]
    missing = [s for s in sections if s not in readme]
    for fn in ("CHANGELOG.md", "CONTRIBUTING.md", "CITATION.cff", "LICENSE"):
        if not os.path.isfile(path(fn)):
            missing.append(fn + ":missing")
    gate("G3", "public README/docs structure", not missing,
         "; ".join(missing) if missing else "sections + docs present")


def g4():
    need = {
        "README.md": ["268", "27"],
        "CHANGELOG.md": ["268"],
        "DATASETS.md": ["27", "268"],
    }
    missing = []
    for rel, tokens in need.items():
        src = read(rel)
        for t in tokens:
            if t not in src:
                missing.append(f"{rel}:{t!r}")
    # A versao NAO e literal do gate: sai do Project.toml e tem de casar em CITATION.cff,
    # no badge do README e no heading da release mais nova do CHANGELOG. Versao literal
    # apodrece calada (o gate segue verde enquanto os arquivos divergem entre si).
    m = re.search(r'^version\s*=\s*"([0-9]+\.[0-9]+\.[0-9]+)"', read("Project.toml"), re.M)
    if not m:
        missing.append("Project.toml:version")
    else:
        v = m.group(1)
        if f"version: {v}" not in read("CITATION.cff"):
            missing.append(f"CITATION.cff:version!={v}")
        if f"version-{v}-" not in read("README.md"):
            missing.append(f"README.md:badge!={v}")
        rels = re.findall(r"^## \[([0-9]+\.[0-9]+\.[0-9]+)\]", read("CHANGELOG.md"), re.M)
        if not rels:
            missing.append("CHANGELOG.md:release-heading")
        elif max(rels, key=lambda x: tuple(int(i) for i in x.split("."))) != v:
            missing.append(f"CHANGELOG.md:release!={v}")
    gate("G4", "count + version reconciliation", not missing,
         "; ".join(missing) if missing else "README/CHANGELOG/DATASETS/versao consistentes")


def g5():
    need = {
        "run_study_C_threaded.jl": ["base.seed + rep"],
        "src/experiments/sweeps.jl": ["base_config.seed + rep"],
        "run_scale_transfer.jl": ["9001..9010"],
        "run_scale31_topup.jl": ["9021..9060"],
        "run_robustness.jl": ["1000, 2000, 3000"],
    }
    missing = []
    for rel, tokens in need.items():
        try:
            src = read(rel)
        except FileNotFoundError:
            missing.append(f"{rel}:FILE-MISSING")
            continue
        for t in tokens:
            if t not in src:
                missing.append(f"{rel}:{t!r}")
    lean = read("run_study_C_lean.jl")
    written = set(re.findall(r'"results/([^"]+)"', lean))
    nonlean = sorted(w for w in written if not w.startswith("study_C_lean."))
    if nonlean:
        missing.append("run_study_C_lean.jl:writes=" + ",".join(nonlean))
    gate("G5", "seed/contract tokens in run scripts", not missing,
         "; ".join(missing) if missing else "5 scripts + lean contract OK")


def g6():
    srv = read("src/web_server.jl")
    html = read("web/index.html")
    keys = ["agents", "compliance", "partial", "regions",
            "largest_region", "largest_share", "grid"]
    missing = [k for k in keys if f'"{k}"' not in srv]
    if "grid_nested" not in srv:
        missing.append("grid_nested(matrix-not-flat)")
    if "/simulate" not in html:
        missing.append("web/index.html:/simulate")
    if "grid-canvas" not in html:
        missing.append("web/index.html:grid-canvas")
    gate("G6", "web /simulate contract (static)", not missing,
         "; ".join(missing) if missing else "keys+nested+fetch OK")


def g7():
    problems = []
    ds = read("DATASETS.md")
    for s in sorted(set(re.findall(r"`([A-Za-z0-9_/\-]+\.jl)`", ds))):
        if not os.path.isfile(path(s)):
            problems.append(f"DATASETS:{s}-missing")
    odd = read("docs/research/ODD.md")
    headers = re.findall(r"^## \d\. .+", odd, re.M)
    if len(headers) < 7:
        problems.append(f"ODD:skeleton headers={len(headers)}/7")
    tr = read("docs/research/TRACE.md")
    rows = [ln for ln in tr.splitlines() if ln.startswith("| T")]
    if len(rows) < 15:
        problems.append(f"TRACE:rows={len(rows)}/15")
    gate("G7", "docs/code sync (ODD, TRACE, DATASETS)",
         not problems, "; ".join(problems) if problems else
         f"ODD 7/7, TRACE {len(rows)} rows, scripts OK")


def g8():
    r = subprocess.run(["git", "ls-files"], capture_output=True, text=True,
                       cwd=ROOT)
    tracked = r.stdout.splitlines() if r.returncode == 0 else []
    badpats = ("results/", "benchmark/results/", "__pycache__/",
               ".commandcode/", "paper/", "AGENTS.md", "HANDOFF.md")
    badext = (".pdf", ".aux", ".log", ".out")
    bad = [t for t in tracked
           if (t.startswith(badpats) and os.path.basename(t) != ".gitkeep")
           or (t.startswith("docs/") and t.endswith(badext))]
    gate("G8", "no private/build artifacts tracked", not bad,
         "; ".join(bad[:8]) if bad else "index clean")


def g9():
    src = read("test/core/test_properties.jl")
    run = read("test/runtests.jl")
    missing = []
    for token in ("GOLDEN", "Quantization", "isapprox"):
        if token not in src:
            missing.append(f"test_properties.jl:{token}")
    if "test_properties.jl" not in run:
        missing.append("runtests.jl:include-missing")
    gate("G9", "deterministic goldens wired in suite", not missing,
         "; ".join(missing) if missing else "quant+determ+goldens in suite")


def main():
    print(f"check_gates.py (public)  root={ROOT}")
    for g in (g1, g2, g3, g4, g5, g6, g7, g8, g9):
        try:
            g()
        except Exception as e:
            gate("?", "unexpected error", False, repr(e))
    print("---- public gates: %d/9 green, %d failed ----" %
          (9 - len(fails), len(fails)))
    sys.exit(0 if not fails else len(fails))


if __name__ == "__main__":
    main()
