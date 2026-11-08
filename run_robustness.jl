# Robustez a seeds (adversarial round 6): treino RL × 3 seed_bases e
# calibração × 3 seed_bases. Se políticas/fitted variarem muito, os
# resultados são sorte de seed (ameaça real: 1 único treino publicado).
# Uso: julia --project=. run_robustness.jl  (~20 min)
# Saída: results/robustness.csv
using CulturalDynamics

cfg_rl = ModelConfig(grid_size=(11, 11), F=3, Q=3, seed_culture=true, seed=1, max_steps=150)
base_cal = ModelConfig(grid_size=(15, 15), F=3, Q=3, seed_culture=true, seed=1,
    bounded_confidence_threshold=0.3, max_steps=300, recording_interval=300)

mkpath("results")
open("results/robustness.csv", "w") do io
    println(io, "kind,seed_base,policy,final_partial,mean_reward,best_fatigue,best_loss")
    for sb in [1000, 2000, 3000]
        r = train_rl(cfg_rl; n_episodes=25, seed_base=sb)
        pol = join(r[:policy], "")
        println(io, "rl,$(sb),\"$(pol)\",$(r[:final_partial]),$(r[:mean_reward]),,")
    end
    println("done rl")
    for sb in [2000, 3000, 4000]
        res = calibrate(base_cal; search=Dict(:fatigue_rate => (0.0005, 0.006)),
            n_samples=16, n_reps=3, seed_base=sb,
            targets=Dict(:decline => 0.085, :final_partial => 0.415))
        println(io, "calib,$(sb),,,$(res[:best_params][:fatigue_rate]),$(res[:best_loss])")
    end
    println("done calib")
end
println("Done -> results/robustness.csv")
