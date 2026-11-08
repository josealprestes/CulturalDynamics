# Top-up 31² até n=50 (round 9): seeds 9021..9060, rep 21..60 (40 novos;
# somam aos 10 de run_scale_transfer.jl, seeds 9001..9010 — top-up
# pré-declarado, não amostra independente).
# Mesma config do R2 (F3Q3 ε0.3 300p, fatigue 0.0031).
# Uso: julia --project=. run_scale31_topup.jl  (~6 min)
# Saída: results/scale31_topup.csv
using CulturalDynamics

mkpath("results")
open("results/scale31_topup.csv", "w") do io
    println(io, "replication,seed,init_partial,final_partial_compliance,decline,final_n_regions")
    for rep in 21:60
        seed = 9000 + rep
        c = ModelConfig(grid_size=(31, 31), F=3, Q=3, seed_culture=true, seed=seed,
            bounded_confidence_threshold=0.3, max_steps=300, recording_interval=300,
            fatigue_rate=0.0031)
        m = evaluate_moments(c)
        println(io, "$(rep),$(seed),$(m[:init_partial]),$(m[:final_partial]),$(m[:decline]),$(m[:final_n_regions])")
    end
    println("done batch")
end
println("Done -> results/scale31_topup.csv")
