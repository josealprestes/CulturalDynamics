import pandas as pd
import matplotlib.pyplot as plt
import os

df = pd.read_csv("results/study_C_sweep.csv")
ts = pd.read_csv("results/study_C_timeseries.csv")
outdir = "results/figures"
os.makedirs(outdir, exist_ok=True)

# Fig4: boxplot n_regions por epsilon (por F)
plt.figure(figsize=(10,4))
try:
    import seaborn as sns
    plt.figure(figsize=(10,4))
    sns.boxplot(data=df, x="sweep_epsilon", y="final_n_regions", hue="F")
    nreps = int(df.groupby(["F","sweep_epsilon"]).size().min())
    plt.title(f"Boxplot n_regions por ε (por F) — {nreps} reps/célula")
    plt.tight_layout()
    plt.savefig(f"{outdir}/fig4_boxplot.png", dpi=200)
    plt.close()
except Exception as e:
    print("seaborn failed", e)
    # fallback matplotlib boxplot
    plt.figure(figsize=(10,4))
    for Fi in sorted(df["F"].unique()):
        sub = df[df["F"]==Fi]
        data = [sub[sub["sweep_epsilon"]==e]["final_n_regions"].values for e in sorted(df["sweep_epsilon"].unique())]
        plt.boxplot(data, positions=[0,1,2] if Fi==5 else [0.4,1.4,2.4], widths=0.3, patch_artist=True)
    plt.xticks([0,1,2], ["0.0","0.3","0.6"])
    plt.tight_layout()
    plt.savefig(f"{outdir}/fig4_boxplot.png", dpi=200)
    plt.close()

# Fig5: n_regions(t) por epsilon (média 10 reps, F=5 Q=3)
plt.figure(figsize=(8,4))
for eps in sorted(ts["epsilon"].unique()):
    sub = ts[ts["epsilon"]==eps]
    g = sub.groupby("step")["n_regions"].mean().reset_index()
    plt.plot(g["step"], g["n_regions"], label=f"ε={eps}")
plt.xlabel("passo")
plt.ylabel("n_regions (média reps)")
plt.title("Convergência n_regions(t) por ε — F=5 Q=3")
plt.legend()
plt.tight_layout()
plt.savefig(f"{outdir}/fig5_timeseries.png", dpi=200)
plt.close()

print("Fig4/5 done")
