# V3: validação held-out P4 (curva treino) + P5 (papéis × variância).
# Parâmetros congelados da V2: fatigue_rate=0.0031. Predições e barras em
# docs/research/validation_V3.md (pré-registro — ler antes de interpretar).
# Uso: julia --project=. run_validate_V3.jl  (~8 min)
# Saída: results/validation_V3.csv
using CulturalDynamics

ROLES = Dict(1 => Dict(:openness => 0.3, :motivation => 0.4),
             2 => Dict(:openness => 0.7, :motivation => 0.6),
             3 => Dict(:openness => 0.7, :motivation => 0.6),
             4 => Dict(:openness => 0.7, :motivation => 0.6),
             5 => Dict(:openness => 0.7, :motivation => 0.6))

mkpath("results")
open("results/validation_V3.csv", "w") do io
    println(io, "experiment,condition,replication,seed,final_partial_compliance,final_n_regions,final_mean_motivation")
    # P4: curva de treino
    for rate in [0.0, 0.005, 0.01, 0.02, 0.04], rep in 1:8
        seed = 5000 + rep
        c = ModelConfig(grid_size=(15, 15), F=3, Q=3, seed_culture=true, seed=seed,
            bounded_confidence_threshold=0.3, max_steps=300, recording_interval=300,
            fatigue_rate=0.0031, intervention=DirectedTraining(), training_rate=rate)
        s = single_run(c)[:summary]
        println(io, "P4,$(rate),$(rep),$(seed),$(s[:final_partial_compliance]),$(s[:final_n_regions]),$(s[:final_mean_motivation])")
    end
    println("done P4")
    # P5: unidades com/sem papéis (mesmas seeds)
    for rep in 1:20
        seed = 7000 + rep
        c = ModelConfig(grid_size=(15, 15), F=3, Q=3, seed_culture=true, seed=seed,
            bounded_confidence_threshold=0.3, max_steps=300, recording_interval=300,
            fatigue_rate=0.0031)
        s0 = single_run(c)[:summary]
        println(io, "P5,noroles,$(rep),$(seed),$(s0[:final_partial_compliance]),$(s0[:final_n_regions]),$(s0[:final_mean_motivation])")
        model = build_model(c)
        assign_roles!(model, ROLES)
        step!(model, 300)
        rd = count_regions(model)
        println(io, "P5,roles,$(rep),$(seed),$(partial_compliance(model)),$(rd[:n_regions]),$(mean_motivation(model))")
    end
    println("done P5")
end
println("Done -> results/validation_V3.csv")
