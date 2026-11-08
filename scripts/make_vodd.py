"""vODD figure (Szangolies et al. 2024): standardized visual ODD summary.
Usage: py -3 scripts/make_vodd.py  ->  docs/research/vODD.png
Panels: I=Initialisation, S=Submodels, O=Observations (+ Scales footer).
Content mirrors docs/research/ODD.md; regenerate if ODD.md changes.
"""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

fig, ax = plt.subplots(figsize=(12, 4.5))
ax.set_xlim(0, 12)
ax.set_ylim(0, 5)
ax.axis("off")

panels = [
    (0.3, "I · INITIALISATION",
     ["grid W×H, torus=false", "agents: F traits 1..Q", "motivation/openness/rank",
      "seed_culture=true: U{1..Q}", "Xoshiro(seed), seeds base+rep"]),
    (4.2, "S · SUBMODELS (per step)",
     ["audit → fatigue → Vroom", "partner → overlap/F → gate ε (1/F)",
      "copy 1 trait (p_copy) → contagion", "mutate → system2 decay",
      "train / shift-reset / record / absorb?"]),
    (8.1, "O · OBSERVATIONS",
     ["n_regions (Union-Find)", "largest_share, mean size", "partial_compliance ∈[0,1]",
      "motivation/openness/system1", "attempted/effective counters"]),
]
for x, title, bullets in panels:
    ax.add_patch(FancyBboxPatch((x, 1.0), 3.5, 3.2,
                 boxstyle="round,pad=0.05", fc="#f4f6fb", ec="#4455aa", lw=1.5))
    ax.text(x + 1.75, 3.9, title, ha="center", va="center", fontsize=10,
            weight="bold", color="#223366")
    for i, b in enumerate(bullets):
        ax.text(x + 0.2, 3.4 - 0.42 * i, "• " + b, ha="left", va="center",
                fontsize=8.5)
ax.add_patch(FancyArrowPatch((3.8, 2.6), (4.2, 2.6), arrowstyle="-|>",
             mutation_scale=14, color="#4455aa", lw=1.5))
ax.add_patch(FancyArrowPatch((7.7, 2.6), (8.1, 2.6), arrowstyle="-|>",
             mutation_scale=14, color="#4455aa", lw=1.5))
ax.add_patch(FancyBboxPatch((0.3, 0.15), 11.3, 0.6, boxstyle="round,pad=0.02",
             fc="#eef3e6", ec="#5a8a3c", lw=1.2))
ax.text(6.0, 0.45, "SCALES: 1 step = 1 full activation round · horizon 300–500 "
        "(one management cycle, transients) · N = 441–10201",
        ha="center", va="center", fontsize=8.5, color="#335522")
ax.set_title("CulturalDynamics — visual ODD (vODD): purpose P1–P5 patterns, "
             "finite-horizon norm-diffusion lab", fontsize=10, pad=10)
fig.tight_layout()
fig.savefig("docs/research/vODD.png", dpi=150)
print("wrote docs/research/vODD.png")
