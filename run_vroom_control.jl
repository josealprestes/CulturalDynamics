# HIGH-3 (red-team): controle de taxa uniforme vs Vroom.
# Se o efeito Vroom (+fragmentação) for só redução média de p_copy, as
# condições uniformes com mesma média devem reproduzir n_regions do Vroom
# (mecanismo não-identificado). Se Vroom divergir sistematicamente,
# heterogeneidade (motivação/openness/dual) tem conteúdo próprio.
# Uso: julia --project=. run_vroom_control.jl  (~5-10 min)
# Saída: results/vroom_control.csv
using CulturalDynamics

conds = [
    ("textbook-Fixed", true, FixedCompliance(), 1.0),
    ("uniform-0.25", true, FixedCompliance(), 0.25),
    ("uniform-0.40", true, FixedCompliance(), 0.40),
    ("uniform-0.60", true, FixedCompliance(), 0.60),
    ("vroom", false, VroomExpectancy(), 1.0),
]
n_reps = 12
println("Vroom control: $(length(conds)) conds x $n_reps reps => $(length(conds)*n_reps) sims")
mkpath("results")
open("results/vroom_control.csv", "w") do io
    println(io, "label,replication,final_n_regions,final_largest_share,final_partial_compliance,final_mean_motivation")
    for (label, textbook, motivation, scale) in conds
        for rep in 1:n_reps
            c = ModelConfig(grid_size=(21, 21), F=5, Q=3, seed_culture=true, seed=rep,
                motivation=motivation, textbook=textbook, copy_scale=scale,
                bounded_confidence_threshold=0.3, max_steps=300, recording_interval=300)
            s = single_run(c)[:summary]
            println(io, "\"$(label)\",$(rep),$(s[:final_n_regions]),$(s[:final_largest_share]),$(s[:final_partial_compliance]),$(s[:final_mean_motivation])")
        end
        println("done $label")
    end
end
println("Done -> results/vroom_control.csv")
