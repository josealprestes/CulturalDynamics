import pandas as pd, matplotlib.pyplot as plt, os
os.makedirs("results/figures", exist_ok=True)

# C2 phase transition
c2 = pd.read_csv("results/study_C2_sweep.csv")
g = c2.groupby("epsilon").agg(mean_n=("final_n_regions","mean"), sd_n=("final_n_regions","std"), mean_share=("final_largest_share","mean")).reset_index()
plt.figure(figsize=(8,4))
plt.errorbar(g["epsilon"], g["mean_n"], yerr=g["sd_n"], marker="o", capsize=3)
plt.xlabel("ε"); plt.ylabel("n_regions médio (15 reps)")
plt.title("Transição de fase F=5 Q=3 21×21 300 passos")
plt.tight_layout(); plt.savefig("results/figures/fig6_phase_epsilon.png", dpi=200); plt.close()

# D ablation boxplot-ish via bar + sd
d = pd.read_csv("results/study_D_sweep.csv")
agg = d.groupby("label").agg(mean_n=("final_n_regions","mean"), sd_n=("final_n_regions","std")).reindex(["NoContagion+Fixed+Grid","Weighted+Fixed+Grid","Weighted+Vroom+Grid","NoContagion+Vroom+Grid","NoContagion+Fixed+SmallWorld","Weighted+Fixed+SmallWorld"])
plt.figure(figsize=(10,4))
plt.bar(range(len(agg)), agg["mean_n"], yerr=agg["sd_n"], capsize=4)
plt.xticks(range(len(agg)), agg.index, rotation=20, ha="right")
plt.ylabel("n_regions médio (8 reps)")
plt.title("Ablação Study D — F=5 Q=3 21×21 300p eps0.3")
plt.tight_layout(); plt.savefig("results/figures/fig7_ablation.png", dpi=200); plt.close()
print("Fig6 Fig7 done")
