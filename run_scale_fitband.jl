# Fit-band por escala (review final W2): recalibra fadiga em 31² e 61²
# com o mesmo protocolo V2 (16 amostras × 3 reps, alvos decline/final).
# 15² já tem: best 0.0031, loss 0.004 (calibration_V2.csv).
# Uso: julia --project=. run_scale_fitband.jl  (~45 min)
# Saída: results/scale_fitband.csv
using CulturalDynamics
using CSV, DataFrames

mkpath("results")
open("results/scale_fitband.csv", "w") do io
    println(io, "grid,best_fatigue,best_loss,best_decline,best_final")
    for w in [31, 61]
        base = ModelConfig(grid_size=(w, w), F=3, Q=3, seed_culture=true, seed=1,
            bounded_confidence_threshold=0.3, max_steps=300, recording_interval=300)
        res = calibrate(base;
            search=Dict(:fatigue_rate => (0.0005, 0.008)),
            n_samples=16, n_reps=3, seed_base=4000 + w,
            targets=Dict(:decline => 0.085, :final_partial => 0.415))
        bp = res[:best_params][:fatigue_rate]
        println(io, "$(w),$(bp),$(res[:best_loss]),$(res[:best_means][:decline]),$(res[:best_means][:final_partial])")
        println("done $(w)x$(w): best=$(round(bp,digits=5)) loss=$(round(res[:best_loss],digits=4))")
    end
end
println("Done -> results/scale_fitband.csv")
