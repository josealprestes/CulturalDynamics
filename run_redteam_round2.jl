# Red-team round 2: MED-6 (inversão F5Q5), contágio n=30, decomposição openness.
# - MED-6: F5Q5 ε{0.0,0.3} 31×31 500p, seeds 32..61 (somam às 1..31 → n=60).
# - Contágio: Vroom × {No,Weighted} Grid 21×21 300p textbook=false, seeds 9..30
#   (somam às 1..8 do Study D → n=30).
# - Decomposição: Vroom Grid com openness homogenizada (0.5 pós-build) vs
#   Vroom normal, mesmas seeds 1..12 — isola heterogeneidade de openness.
# Uso: JULIA_NUM_THREADS=4 julia --project=. run_redteam_round2.jl (~15 min)
# Saída: results/redteam_round2.csv
using CulturalDynamics
using Agents: abmproperties, allagents, step!
using Base.Threads

tasks = Tuple[]
for rep in 32:61
    push!(tasks, (:med6, "F5Q5e0.0", rep, 31, 500, 0.0, false, nothing, false))
    push!(tasks, (:med6, "F5Q5e0.3", rep, 31, 500, 0.3, false, nothing, false))
end
for rep in 9:30
    push!(tasks, (:contagio, "Vroom+No", rep, 21, 300, 0.3, true, NoContagion(), false))
    push!(tasks, (:contagio, "Vroom+Weighted", rep, 21, 300, 0.3, true, WeightedContagion(), false))
end
for rep in 1:12
    push!(tasks, (:decomp, "Vroom", rep, 21, 300, 0.3, true, WeightedContagion(), false))
    push!(tasks, (:decomp, "Vroom-openHomog", rep, 21, 300, 0.3, true, WeightedContagion(), true))
end
println("Red-team round2: $(length(tasks)) sims em $(nthreads()) threads")

rows = Vector{Dict{Symbol,Any}}(undef, length(tasks))
done_count = Atomic{Int}(0)

@threads for idx in eachindex(tasks)
    kind, label, rep, w, steps, eps, vroom, contag, homog = tasks[idx]
    mot = vroom ? VroomExpectancy() : FixedCompliance()
    con = contag === nothing ? WeightedContagion() : contag
    seed = kind == :med6 ? rep : (kind == :contagio ? rep : rep)
    c = ModelConfig(grid_size=(w, w), F=5, Q=(kind == :med6 ? 5 : 3),
        seed_culture=true, seed=seed, motivation=mot, social_contagion=con,
        textbook=!vroom, bounded_confidence_threshold=eps,
        max_steps=steps, recording_interval=steps)
    if homog
        model = build_model(c)
        for a in allagents(model)
            a.openness = 0.5
        end
        step!(model, steps)
        rd = count_regions(model)
        s = Dict{Symbol,Any}(:final_n_regions => rd[:n_regions],
            :final_largest_share => rd[:largest_share],
            :final_partial_compliance => partial_compliance(model),
            :final_mean_motivation => mean_motivation(model),
            :final_system1_fraction => system1_fraction(model))
    else
        s = single_run(c)[:summary]
    end
    rows[idx] = Dict{Symbol,Any}(:kind => String(kind), :label => label, :replication => rep,
        :seed => seed, :final_n_regions => s[:final_n_regions],
        :final_largest_share => s[:final_largest_share],
        :final_partial_compliance => s[:final_partial_compliance],
        :final_mean_motivation => s[:final_mean_motivation],
        :final_system1_fraction => s[:final_system1_fraction])
    n = atomic_add!(done_count, 1) + 1
    if n % 20 == 0 || n == length(tasks)
        println("  concluidas: $n/$(length(tasks))")
    end
end

mkpath("results")
open("results/redteam_round2.csv", "w") do io
    println(io, "kind,label,replication,seed,final_n_regions,final_largest_share,final_partial_compliance,final_mean_motivation,final_system1_fraction")
    for r in rows
        println(io, "$(r[:kind]),\"$(r[:label])\",$(r[:replication]),$(r[:seed]),$(r[:final_n_regions]),$(r[:final_largest_share]),$(r[:final_partial_compliance]),$(r[:final_mean_motivation]),$(r[:final_system1_fraction])")
    end
end
println("Done round2 -> results/redteam_round2.csv")
