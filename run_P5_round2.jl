# P5 round 2 (pré-registro em validation_V3.md): duas pernas, basta uma.
# - P5c: replicação v2 (papéis sob Vroom) com n=100, seeds 7000..7099
#   (primeiras 20 reproduzem validation_V3b.csv bit a bit).
# - P5d: heterogeneidade estrutural — fatigue_rate por unidade em
#   {0.001,0.003,0.005} (por rep mod 3) vs controle 0.003, seeds 8000+rep.
# Uso: JULIA_NUM_THREADS=4 julia --project=. run_P5_round2.jl  (~15 min)
# Saída: results/P5_round2.csv
using CulturalDynamics
using Accessors: @set
using Base.Threads

ROLES = Dict(1 => Dict(:openness => 0.3, :motivation => 0.4),
             2 => Dict(:openness => 0.7, :motivation => 0.6),
             3 => Dict(:openness => 0.7, :motivation => 0.6),
             4 => Dict(:openness => 0.7, :motivation => 0.6),
             5 => Dict(:openness => 0.7, :motivation => 0.6))

function base_cfg(seed)
    return ModelConfig(grid_size=(15, 15), F=3, Q=3, seed_culture=true, seed=seed,
        bounded_confidence_threshold=0.3, max_steps=300, recording_interval=300,
        fatigue_rate=0.0031, textbook=false, motivation=VroomExpectancy())
end

tasks = Tuple[]
for rep in 1:100
    push!(tasks, (:P5c, "noroles", rep, 7000 + rep, false, 0.0031))
    push!(tasks, (:P5c, "roles", rep, 7000 + rep, true, 0.0031))
end
for rep in 1:30
    push!(tasks, (:P5d, "control", rep, 8000 + rep, false, 0.0031))
    push!(tasks, (:P5d, "structural", rep, 8000 + rep, false, [0.001, 0.003, 0.005][mod(rep - 1, 3)+1]))
end
println("P5 round2: $(length(tasks)) sims em $(nthreads()) threads")

rows = Vector{Dict{Symbol,Any}}(undef, length(tasks))
done_count = Atomic{Int}(0)

@threads for idx in eachindex(tasks)
    leg, cond, rep, seed, useroles, fat = tasks[idx]
    c = base_cfg(seed)
    c = @set c.fatigue_rate = fat
    if useroles
        model = build_model(c)
        assign_roles!(model, ROLES)
        step!(model, 300)
        rd = count_regions(model)
        p, nreg = partial_compliance(model), rd[:n_regions]
    else
        s = single_run(c)[:summary]
        p, nreg = s[:final_partial_compliance], s[:final_n_regions]
    end
    rows[idx] = Dict{Symbol,Any}(:leg => String(leg), :condition => cond,
        :replication => rep, :seed => seed,
        :final_partial_compliance => p, :final_n_regions => nreg)
    n = atomic_add!(done_count, 1) + 1
    if n % 40 == 0 || n == length(tasks)
        println("  concluidas: $n/$(length(tasks))")
    end
end

mkpath("results")
open("results/P5_round2.csv", "w") do io
    println(io, "leg,condition,replication,seed,final_partial_compliance,final_n_regions")
    for r in rows
        println(io, "$(r[:leg]),\"$(r[:condition])\",$(r[:replication]),$(r[:seed]),$(r[:final_partial_compliance]),$(r[:final_n_regions])")
    end
end
println("Done P5 round2 -> results/P5_round2.csv")
