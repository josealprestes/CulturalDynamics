# F1 full threaded: mesmo protocolo de run_study_C.jl (31×31, 500 passos,
# F{5,10}×Q{3,5,10}×ε{0,0.3,0.6}×30 reps = 540 sims), com Threads.@threads
# sobre a lista plana de tarefas.
#
# Determinismo: cada rep usa seed explícita (base.seed + rep), idêntica à do
# parameter_sweep serial (sweeps.jl usa `@set ...seed = base.seed + rep`);
# a ordem das linhas do CSV é a mesma do aninhamento serial (slots
# pré-alocados por índice). Resultado equivalente ao serial.
#
# Uso: JULIA_NUM_THREADS=4 julia --project=. run_study_C_threaded.jl
# Saída: results/study_C_sweep.{csv,json}
using CulturalDynamics
using Accessors: @set
using Base.Threads

base = ModelConfig(
    grid_size=(31,31),
    F=5, Q=3,
    seed_culture=true,
    seed=1,
    bounded_confidence_threshold=0.3,
    max_steps=500,
    # Otimização sem efeito nos resultados: export_csv/export_json usam só
    # :config e :summary (estado vivo do modelo); :history (record_metrics!
    # a cada passo, com count_regions O(N) + Dicts) é custo puro. Com
    # interval=max_steps, 1 registro em vez de 500. CSV/JSON idênticos.
    recording_interval=500,
)

F_values = [5, 10]
Q_values = [3, 5, 10]
epsilon_values = [0.0, 0.3, 0.6]
n_replications = 30

tasks = [(F, Q, eps, rep) for F in F_values for Q in Q_values for eps in epsilon_values for rep in 1:n_replications]
println("Estudo C threaded: $(length(tasks)) sims em $(nthreads()) threads")

results = Vector{Dict{Symbol,Any}}(undef, length(tasks))
done_count = Atomic{Int}(0)

@threads for idx in eachindex(tasks)
    F, Q, eps, rep = tasks[idx]
    config = @set base.F = F
    config = @set config.Q = Q
    config = @set config.bounded_confidence_threshold = eps
    config = @set config.seed = base.seed + rep
    r = single_run(config)
    r[:sweep_F] = F
    r[:sweep_Q] = Q
    r[:sweep_epsilon] = eps
    r[:replication] = rep
    results[idx] = r
    n = atomic_add!(done_count, 1) + 1
    if n % 30 == 0 || n == length(tasks)
        println("  concluidas: $n/$(length(tasks))")
    end
end

mkpath("results")
export_csv(results, "results/study_C_sweep.csv")
export_json(results, "results/study_C_sweep.json")
println("Done threaded: $(length(results)) results -> results/study_C_sweep.{csv,json}")
