import pandas as pd
import matplotlib.pyplot as plt
import os

csv = "results/study_C_sweep.csv"
outdir = "results/figures"
os.makedirs(outdir, exist_ok=True)

df = pd.read_csv(csv)
# agg
agg = df.groupby(["F","Q","sweep_epsilon"]).agg(mean_regions=("final_n_regions","mean"), sd_regions=("final_n_regions","std"), mean_share=("final_largest_share","mean")).reset_index()

# Fig1: n_regions vs epsilon por F (facet Q via color, aggregated)
plt.figure(figsize=(10,4))
for Fi in sorted(agg["F"].unique()):
    sub = agg[agg["F"]==Fi]
    # mean across Q per epsilon
    g = sub.groupby("sweep_epsilon").agg(mean_regions=("mean_regions","mean"), sd=("mean_regions","std")).reset_index()
    plt.errorbar(g["sweep_epsilon"], g["mean_regions"], yerr=g["sd"], marker="o", capsize=4, label=f"F={Fi}")

nreps = int(df.groupby(["F","Q","sweep_epsilon"]).size().min())
plt.xlabel("ε (bounded confidence)")
plt.ylabel("nº médio de regiões")
plt.title(f"Fragmentação vs seletividade social — média sobre Q ({nreps} reps/célula)")
plt.legend()
plt.tight_layout()
plt.savefig(f"{outdir}/fig1_regions_vs_epsilon.png", dpi=200)
plt.close()

# Fig2: n_regions vs Q por F (facet epsilon via linestyle)
plt.figure(figsize=(10,4))
for Fi in sorted(agg["F"].unique()):
    for eps in sorted(agg["sweep_epsilon"].unique()):
        sub = agg[(agg["F"]==Fi) & (agg["sweep_epsilon"]==eps)].sort_values("Q")
        plt.plot(sub["Q"], sub["mean_regions"], marker="o", label=f"F={Fi}, ε={eps}")

plt.xlabel("Q (níveis de adesão)")
plt.ylabel("nº médio de regiões")
plt.title(f"Fragmentação vs granularidade — por F e ε ({nreps} reps/célula)")
plt.legend(ncol=2, fontsize=8)
plt.tight_layout()
plt.savefig(f"{outdir}/fig2_regions_vs_Q.png", dpi=200)
plt.close()

# Fig3: heatmap mean_regions in F x Q x epsilon facets
# make 3 heatmaps one per epsilon
import numpy as np
eps_vals = sorted(agg["sweep_epsilon"].unique())
F_vals = sorted(agg["F"].unique())
Q_vals = sorted(agg["Q"].unique())

fig, axes = plt.subplots(1, len(eps_vals), figsize=(12,3.5), sharey=True)
for ax, eps in zip(axes, eps_vals):
    sub = agg[agg["sweep_epsilon"]==eps]
    mat = np.zeros((len(F_vals), len(Q_vals)))
    for i, F in enumerate(F_vals):
        for j, Q in enumerate(Q_vals):
            v = sub[(sub["F"]==F) & (sub["Q"]==Q)]["mean_regions"].values
            mat[i, j] = v[0] if len(v) else np.nan
    im = ax.imshow(mat, aspect="auto", cmap="magma")
    ax.set_xticks(range(len(Q_vals))); ax.set_xticklabels(Q_vals)
    ax.set_yticks(range(len(F_vals))); ax.set_yticklabels(F_vals)
    ax.set_xlabel("Q"); ax.set_title(f"ε={eps}\n(n_regions)")
    fig.colorbar(im, ax=ax, shrink=0.8)
axes[0].set_ylabel("F")
fig.suptitle(f"Heatmap de fragmentação média ({nreps} reps/célula)", y=1.05)
plt.tight_layout()
plt.savefig(f"{outdir}/fig3_heatmap.png", dpi=200)
plt.close()

print(f"Figuras em {outdir}: fig1, fig2, fig3")
for f in os.listdir(outdir):
    print(f, os.path.getsize(os.path.join(outdir, f)))
