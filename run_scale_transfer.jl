# R2 (TCSS W1): transferência de escala do ponto calibrado.
# fatigue_rate=0.0031 (V2) em 31×31 e 61×61, n=10. Barra: decline≈0.085 e
# final≈0.415 dentro de ±0.05. Se derivar: recalibrar na escala e reportar
# taxa por escala (tabela, não desculpa); se colapsar: escopo encolhe.
# Os 10 reps de 31² (seeds 9001..9010) são completados até n=50 por
# run_scale31_topup.jl (seeds 9021..9060 — top-up pré-declarado,
# não amostra independente).
# Uso: julia --project=. run_scale_transfer.jl  (~30-40 min)
# Saída: results/scale_transfer.csv
using CulturalDynamics

mkpath("results")
open("results/scale_transfer.csv", "w") do io
    println(io, "grid,replication,seed,init_partial,final_partial_compliance,decline,final_n_regions")
    for w in [31, 61], rep in 1:10
        seed = 9000 + rep
        c = ModelConfig(grid_size=(w, w), F=3, Q=3, seed_culture=true, seed=seed,
            bounded_confidence_threshold=0.3, max_steps=300, recording_interval=300,
            fatigue_rate=0.0031)
        m = evaluate_moments(c)
        println(io, "$(w),$(rep),$(seed),$(m[:init_partial]),$(m[:final_partial]),$(m[:decline]),$(m[:final_n_regions])")
    end
    println("done batch")
end
println("Done -> results/scale_transfer.csv")
