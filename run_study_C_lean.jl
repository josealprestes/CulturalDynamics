# Lean 21×21 8 reps — qualitativo/aprovação rápida. NÃO sobrescreve o
# corpus canônico: escreve study_C_lean.csv (o sweep 31×31 30 reps vive em
# study_C_sweep.csv via run_study_C_threaded.jl).
using CulturalDynamics

base = ModelConfig(
    grid_size=(21,21),
    F=5, Q=3,
    seed_culture=true,
    seed=1,
    bounded_confidence_threshold=0.3,
    max_steps=300,
    recording_interval=300,
)

F_values = [5, 10]
Q_values = [3, 5, 10]
epsilon_values = [0.0, 0.3, 0.6]
n_replications = 8

total = length(F_values)*length(Q_values)*length(epsilon_values)*n_replications
println("Estudo C lean: 21x21 300 passos F=$(F_values) Q=$(Q_values) ε=$(epsilon_values) reps=$n_replications => $total sims")

results = parameter_sweep(base;
    F_values=F_values,
    Q_values=Q_values,
    epsilon_values=epsilon_values,
    n_replications=n_replications,
)

mkpath("results")
export_csv(results, "results/study_C_lean.csv")
export_json(results, "results/study_C_lean.json")
println("Done lean: $(length(results)) -> results/study_C_lean.{csv,json}")
