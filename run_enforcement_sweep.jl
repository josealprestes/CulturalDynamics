# P3: curva dose-resposta do monitoramento (NormSanctions).
# F=5 Q=3 21×21 300p ε0.3, monitoring_rate ∈ {0, 0.02, 0.1}, 8 reps.
# Uso: julia --project=. run_enforcement_sweep.jl  (~5 min)
# Saída: results/enforcement_sweep.csv
using CulturalDynamics

rates = [0.0, 0.02, 0.1]
n_reps = 8
println("Enforcement sweep: $(length(rates)) rates x $n_reps reps")
mkpath("results")
open("results/enforcement_sweep.csv", "w") do io
    println(io, "monitoring_rate,replication,final_n_regions,final_largest_share,final_partial_compliance,final_mean_motivation")
    for rate in rates
        for rep in 1:n_reps
            c = ModelConfig(grid_size=(21, 21), F=5, Q=3, seed_culture=true, seed=rep,
                enforcement=NormSanctions(), monitoring_rate=rate, sanction_cost=0.1,
                bounded_confidence_threshold=0.3, max_steps=300, recording_interval=300)
            s = single_run(c)[:summary]
            println(io, "$(rate),$(rep),$(s[:final_n_regions]),$(s[:final_largest_share]),$(s[:final_partial_compliance]),$(s[:final_mean_motivation])")
        end
        println("done rate=$rate")
    end
end
println("Done -> results/enforcement_sweep.csv")
