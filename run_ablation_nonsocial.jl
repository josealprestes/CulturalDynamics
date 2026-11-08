# R1 (TCSS W2): ablação não-social — calibração SEM difusão.
# Mesmo protocolo de run_calibrate_V2.jl + copy_scale=0.0 (cópia desligada;
# o knob copy_scale multiplica p_copy — ver copy_probability em model.jl).
# NOTA DE DESENHO (honesta): deriva domina os momentos de nível, então RMSE
# deve empatar — o teste real é ESTRUTURAL (ver análise pós-run): o nulo sem
# cópia não produz coarsening (n_regions≈N estático); se o social difere
# estruturalmente por >2× com mesmos níveis, difusão trabalha em estrutura.
# Uso: julia --project=. run_ablation_nonsocial.jl  (~5 min)
# Saída: results/ablation_nonsocial.csv
using CulturalDynamics
using CSV, DataFrames

base = ModelConfig(grid_size=(15, 15), F=3, Q=3, seed_culture=true, seed=1,
    bounded_confidence_threshold=0.3, max_steps=300, recording_interval=300,
    copy_scale=0.0)

res = calibrate(base;
    search=Dict(:fatigue_rate => (0.0005, 0.006)),
    n_samples=16, n_reps=3, seed_base=2000,
    targets=Dict(:decline => 0.085, :final_partial => 0.415))

println("R1 nosocial: best_loss=$(round(res[:best_loss], digits=4)) (social: 0.004)")
println("  best_params=$(res[:best_params])")
println("  best_means=$(res[:best_means])")

mkpath("results")
rows = [Dict(:trial => i, :fatigue_rate => t[:params][:fatigue_rate],
             :mean_decline => t[:means][:decline],
             :mean_final => t[:means][:final_partial],
             :loss => t[:loss]) for (i, t) in enumerate(res[:trials])]
CSV.write("results/ablation_nonsocial.csv", DataFrame(rows))
println("Done -> results/ablation_nonsocial.csv")
