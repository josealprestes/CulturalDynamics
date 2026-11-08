using CulturalDynamics

# NOTA: script serial superseded por run_study_C_threaded.jl (mesmo protocolo,
# seeds idênticas, ~4× mais rápido, determinístico). Mantido para referência
# e máquinas single-thread. Para a rodada canônica F1, use o threaded.
# AVISO: escreve study_C_sweep.csv — rode SOMENTE se for regenerar o corpus
# canônico (sobrescreve as 540 linhas); para teste rápido use run_study_C_lean.jl.
base = ModelConfig(
    grid_size=(31,31),
    F=5, Q=3,
    seed_culture=true,
    seed=1,
    bounded_confidence_threshold=0.3,
    max_steps=500,
)

F_values = [5, 10]
Q_values = [3, 5, 10]
epsilon_values = [0.0, 0.3, 0.6]
n_replications = 30

println("Estudo C: F=$(F_values) Q=$(Q_values) ε=$(epsilon_values) reps=$n_replications")
println("Total: $(length(F_values)*length(Q_values)*length(epsilon_values)*n_replications) sims")

results = parameter_sweep(base;
    F_values=F_values,
    Q_values=Q_values,
    epsilon_values=epsilon_values,
    n_replications=n_replications,
)

mkpath("results")
export_csv(results, "results/study_C_sweep.csv")
export_json(results, "results/study_C_sweep.json")

println("Done: $(length(results)) results -> results/study_C_sweep.{csv,json}")
