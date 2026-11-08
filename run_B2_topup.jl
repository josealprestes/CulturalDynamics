# B2 top-up n=20→60 (red-team): seeds 62..101 × {fastest, randomly}.
# Somam às seeds 42..61 de run_B2_multiseed.jl (determinístico).
# Uso: julia --project=. run_B2_topup.jl  (~35 min)
# Saída: results/B2_topup.csv (merge em B2_multiseed.csv via python)
using CulturalDynamics

seeds = 62:101
mkpath("results")
open("results/B2_topup.csv", "w") do io
    println(io, "side,scheduler,seed,n_regions,largest,largest_share")
    for seed in seeds, sched in (:fastest, :randomly)
        c = ModelConfig(grid_size=(31, 31), F=5, Q=3, seed_culture=true, seed=seed,
            bounded_confidence_threshold=0.3, max_steps=300, recording_interval=300,
            scheduler=sched)
        m = build_model(c)
        step!(m, 300)
        rd = count_regions(m)
        println(io, "julia,$(sched),$(seed),$(rd[:n_regions]),$(rd[:largest_region]),$(rd[:largest_share])")
    end
    println("done batch")
end
println("Done -> results/B2_topup.csv")
