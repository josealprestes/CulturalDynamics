# V2 gate: calibração lean da fadiga nos momentos P1–P2 (Dai).
# Alvos: decline=0.085 (8.5pp/turno), final_partial=0.415 (partindo ~0.5).
# Gate (moments_hand_hygiene.md): RMSE ≤ 0.05 ou a tese falha.
# Uso: julia --project=. run_calibrate_V2.jl  (~5 min)
# Saída: results/calibration_V2.csv (trials)
using CulturalDynamics
using CSV, DataFrames

base = ModelConfig(grid_size=(15, 15), F=3, Q=3, seed_culture=true, seed=1,
    bounded_confidence_threshold=0.3, max_steps=300, recording_interval=300)

res = calibrate(base;
    search=Dict(:fatigue_rate => (0.0005, 0.006)),
    n_samples=16, n_reps=3, seed_base=2000,
    targets=Dict(:decline => 0.085, :final_partial => 0.415))

println("V2 gate: best_loss=$(round(res[:best_loss], digits=4)) (teto 0.05)")
println("  best_params=$(res[:best_params])")
println("  best_means=$(res[:best_means])")
println("  targets=$(res[:targets])")

mkpath("results")
rows = [Dict(:trial => i, :fatigue_rate => t[:params][:fatigue_rate],
             :mean_decline => t[:means][:decline],
             :mean_final => t[:means][:final_partial],
             :loss => t[:loss]) for (i, t) in enumerate(res[:trials])]
CSV.write("results/calibration_V2.csv", DataFrame(rows))
println(res[:best_loss] <= 0.05 ? "GATE V2: PASS" : "GATE V2: FAIL — tese falha, parar")
