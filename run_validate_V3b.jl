# V3b — P5 corrigido: papéis sob acoplamento ativo (textbook=false + Vroom),
# onde openness/motivação entram na dinâmica (P5 original usou textbook, onde
# papéis são mortos por construção — falha de operacionalização, não da ideia).
# 20 unidades com/sem papéis, mesmas seeds 7000+rep.
# Uso: julia --project=. run_validate_V3b.jl  (~4 min)
# Saída: results/validation_V3b.csv
using CulturalDynamics

ROLES = Dict(1 => Dict(:openness => 0.3, :motivation => 0.4),
             2 => Dict(:openness => 0.7, :motivation => 0.6),
             3 => Dict(:openness => 0.7, :motivation => 0.6),
             4 => Dict(:openness => 0.7, :motivation => 0.6),
             5 => Dict(:openness => 0.7, :motivation => 0.6))

mkpath("results")
open("results/validation_V3b.csv", "w") do io
    println(io, "condition,replication,seed,final_partial_compliance,final_n_regions")
    for rep in 1:20
        seed = 7000 + rep
        c = ModelConfig(grid_size=(15, 15), F=3, Q=3, seed_culture=true, seed=seed,
            bounded_confidence_threshold=0.3, max_steps=300, recording_interval=300,
            fatigue_rate=0.0031, textbook=false, motivation=VroomExpectancy())
        s0 = single_run(c)[:summary]
        println(io, "noroles,$(rep),$(seed),$(s0[:final_partial_compliance]),$(s0[:final_n_regions])")
        model = build_model(c)
        assign_roles!(model, ROLES)
        step!(model, 300)
        rd = count_regions(model)
        println(io, "roles,$(rep),$(seed),$(partial_compliance(model)),$(rd[:n_regions])")
    end
    println("done batch")
end
println("Done V3b -> results/validation_V3b.csv")
