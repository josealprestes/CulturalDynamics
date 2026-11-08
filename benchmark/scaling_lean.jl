# B1-lean: scaling spot-check (subset doc-sanctioned de benchmark/scaling.jl).
#
# O scaling.jl full (N×F×Q×ε×topologia com @benchmark) custa horas porque
# @benchmark amostra repetidamente configs pesadas (ex.: 201² = 40k agentes).
# Este script mede ms/step com min de 3× @elapsed step!(model, 100) em modelos
# frescos (mesmo seed) e escreve o MESMO schema de scaling.jl:
#   N,w,h,F,Q,epsilon,topology,ms_per_step,steps_per_sec
#
# Grade: N ∈ {21²,31²,61²,101²} F=5 Q=3 ε=0.3 Grid (curva Fig.8) +
#        1 spot SmallWorld (31²) + 1 spot F=10 (31² Grid).
# Métrica: min de 3× @elapsed (latência otimista; o full usa mediana de
# @benchmark). Hardware do run canônico: i5-3230M 2C/4T — re-medir ao
# citar em outra máquina (paper §sec:repro).
# Uso: julia --project=. benchmark/scaling_lean.jl
# Saída: benchmark/results/scaling.csv
using CulturalDynamics
using CSV
using DataFrames
using Printf

println("B1-lean: scaling spot-check")
println("=" ^ 60)

results = DataFrame(
    N = Int[], w = Int[], h = Int[], F = Int[], Q = Int[],
    epsilon = Float64[], topology = String[],
    ms_per_step = Float64[], steps_per_sec = Float64[],
)

function time_config(w, h, F, Q, eps, topo_strategy, topo_name; steps=100, reps=3, seed=42)
    best = Inf
    for r in 1:reps
        config = ModelConfig(
            grid_size = (w, h), F = F, Q = Q,
            bounded_confidence_threshold = eps,
            topology = topo_strategy,
            seed_culture = true, seed = seed + r, max_steps = steps,
        )
        model = build_model(config)
        t = @elapsed step!(model, steps)
        best = min(best, t)
    end
    ms = best / steps * 1000
    return ms
end

grid_sizes = [(21, 21), (31, 31), (61, 61), (101, 101)]
for (w, h) in grid_sizes
    ms = time_config(w, h, 5, 3, 0.3, GridTopology(), "Grid")
    N = w * h
    push!(results, (N, w, h, 5, 3, 0.3, "Grid", ms, 1000 / ms))
    @printf("%dx%d N=%d F=5 Q=3 eps=0.3 Grid: %.2f ms/step, %.0f steps/sec\n", w, h, N, ms, 1000 / ms)
end

# Spots
ms_sw = time_config(31, 31, 5, 3, 0.3, SmallWorldTopology(), "SmallWorld")
push!(results, (961, 31, 31, 5, 3, 0.3, "SmallWorld", ms_sw, 1000 / ms_sw))
@printf("31x31 N=961 F=5 Q=3 eps=0.3 SmallWorld: %.2f ms/step\n", ms_sw)

ms_f10 = time_config(31, 31, 10, 3, 0.3, GridTopology(), "Grid")
push!(results, (961, 31, 31, 10, 3, 0.3, "Grid", ms_f10, 1000 / ms_f10))
@printf("31x31 N=961 F=10 Q=3 eps=0.3 Grid: %.2f ms/step\n", ms_f10)

mkpath(joinpath(@__DIR__, "results"))
out = joinpath(@__DIR__, "results", "scaling.csv")
CSV.write(out, results)
println("\nCSV: $out ($(nrow(results)) linhas)")
println("=" ^ 60)
println("B1-lean complete! Ver docs/research/BENCHMARKS.md (B1).")
