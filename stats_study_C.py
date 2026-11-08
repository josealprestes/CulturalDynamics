import pandas as pd
import scipy.stats as st

df = pd.read_csv("results/study_C_sweep.csv")
# KW por fator sobre final_n_regions
for col in ["F","Q","sweep_epsilon"]:
    groups = [g["final_n_regions"].values for _, g in df.groupby(col)]
    H, p = st.kruskal(*groups)
    print(f"KW {col}: H={H:.2f} p={p:.3g} groups={[len(g) for g in groups]}")
    # eta2 approx
    # also pairwise via mannwhitney if needed (not doing full Dunn here)
# Spearman epsilon vs n_regions por F fixo
for F in sorted(df["F"].unique()):
    sub = df[df["F"]==F]
    r, p = st.spearmanr(sub["sweep_epsilon"], sub["final_n_regions"])
    print(f"Spearman F={F} epsilon vs regions: r={r:.3f} p={p:.3g} n={len(sub)}")

# Medians/IQR por epsilon
print(df.groupby("sweep_epsilon")["final_n_regions"].describe().round(2))
