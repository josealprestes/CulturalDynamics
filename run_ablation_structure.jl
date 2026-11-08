# R1 structural (TCSS W2; red-team Round 7): social vs non-social STRUCTURE.
# Pure-diffusion contrast isolating coarsening: textbook Axelrod 15^2 F3Q3
# eps0.3, 300 steps, copy_scale 1.0 (social) vs 0.0 (static null, mosaic
# frozen at initial culture), seeds 1..10, n=10/arm.
# Companion to run_ablation_nonsocial.jl (which fits LEVELS without diffusion;
# RMSE 0.008 vs 0.004): this script tests STRUCTURE (n_regions, share).
# Uso: julia --project=. run_ablation_structure.jl  (~2-4 min)
# Saída: results/ablation_structure.csv
using CulturalDynamics
using CSV, DataFrames

function arm_mean(arm, scale)
    rows = Vector{Dict{Symbol,Any}}()
    for rep in 1:10
        c = ModelConfig(grid_size=(15, 15), F=3, Q=3, seed_culture=true, seed=rep,
            bounded_confidence_threshold=0.3, max_steps=300, recording_interval=300,
            textbook=true, copy_scale=scale)
        s = single_run(c)[:summary]
        push!(rows, Dict(:arm => arm, :replication => rep,
            :final_n_regions => s[:final_n_regions],
            :final_largest_share => s[:final_largest_share],
            :final_partial_compliance => s[:final_partial_compliance]))
    end
    return rows
end

rows = vcat(arm_mean("social", 1.0), arm_mean("nosocial", 0.0))
mkpath("results")
CSV.write("results/ablation_structure.csv", DataFrame(rows))
for arm in ["social", "nosocial"]
    sub = filter(r -> r[:arm] == arm, rows)
    n = [r[:final_n_regions] for r in sub]
    println("$arm: n_regions=$(round(sum(n)/length(n), digits=1)) (n=10)")
end
println("Done -> results/ablation_structure.csv")
