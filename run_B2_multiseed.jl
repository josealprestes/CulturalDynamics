# B2 multi-seed (red-team MED-7, n=20/braço; top-up até n=60 em
# run_B2_topup.jl, seeds 62..101). Julia fastest/randomly, F5Q3 ε0.3
# 31×31 300p. Lado Mesa: `for s in 42..101: MESA_SEED=$s python3
# benchmark/mesa_axelrod.py` (saídas por seed devem ser agregadas em
# results/B2_mesa.csv — o script escreve 1 linha por rodada).
# Uso: julia --project=. run_B2_multiseed.jl  (~15-20 min)
# Saída: results/B2_multiseed.csv
using CulturalDynamics

seeds = 42:61
mkpath("results")
open("results/B2_multiseed.csv", "w") do io
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
println("Done -> results/B2_multiseed.csv")
