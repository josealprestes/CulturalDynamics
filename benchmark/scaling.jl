using BenchmarkTools
using CulturalDynamics
using CSV
using DataFrames

println("CulturalDynamics.jl Benchmark Suite — SOTA (B1)")
println("=" ^ 60)

results = DataFrame(
    N = Int[], w = Int[], h = Int[], F = Int[], Q = Int[],
    epsilon = Float64[], topology = String[],
    ms_per_step = Float64[], steps_per_sec = Float64[],
)

grid_sizes = [(31, 31), (61, 61), (101, 101), (201, 201)]
F_values = [5, 10]
Q_values = [3, 5]
epsilon_values = [0.0, 0.3]
topologies = ["Grid", "SmallWorld"]

for (w, h) in grid_sizes, F in F_values, Q in Q_values, eps in epsilon_values, topo in topologies
    topo_strategy = topo == "SmallWorld" ? SmallWorldTopology() : GridTopology()
    config = ModelConfig(
        grid_size = (w, h), F = F, Q = Q,
        bounded_confidence_threshold = eps,
        topology = topo_strategy,
        seed_culture = true, seed = 42, max_steps = 500,
    )
    model = build_model(config)
    b = @benchmark step!($model, 100)
    ms = median(b).time / 100 / 1e6
    sps = 1000 / ms
    N = w * h
    push!(results, (N, w, h, F, Q, eps, topo, ms, sps))
    println("$(w)×$(h) N=$(N) F=$(F) Q=$(Q) ε=$(eps) $(topo): $(round(ms, digits=2)) ms/step, $(round(sps, digits=0)) steps/sec")
end

mkpath(joinpath(@__DIR__, "results"))
out = joinpath(@__DIR__, "results", "scaling.csv")
CSV.write(out, results)
println("\nCSV: $out ($(nrow(results)) linhas)")
println("=" ^ 60)
println("Benchmark complete! Ver docs/research/BENCHMARKS.md (B1).")
