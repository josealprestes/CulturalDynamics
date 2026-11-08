# Red-team round 4: top-up MED-6 fino (n=15→30) + Vroom+monitoring.
# - MED6-topup: F5Q5 ε∈{0.1,0.2,0.3,0.4} 31×31 500p, seeds 200..214 (+15).
# - Vroom+monitoring: F5Q3 21×21 300p ε0.3 textbook=false Vroom,
#   monitoring ∈ {0, 0.02, 0.1} × 8 reps — testa crowding-out em escala
#   (sob Fixed a punição nunca dispara; sob Vroom deve morder).
# Uso: JULIA_NUM_THREADS=4 julia --project=. run_redteam_round4.jl (~12 min)
# Saída: results/redteam_round4.csv
using CulturalDynamics
using Base.Threads

tasks = Tuple[]
for eps in [0.1, 0.2, 0.3, 0.4], rep in 200:214
    push!(tasks, (:med6topup, "e$(eps)", rep, 31, 500, eps, FixedCompliance(), WeightedContagion(), true, 0.0, 0.0))
end
for rate in [0.0, 0.02, 0.1], rep in 1:8
    push!(tasks, (:vroommon, "mon$(rate)", rep, 21, 300, 0.3, VroomExpectancy(), WeightedContagion(), false, rate, 0.1))
end
println("Red-team round4: $(length(tasks)) sims em $(nthreads()) threads")

rows = Vector{Dict{Symbol,Any}}(undef, length(tasks))
done_count = Atomic{Int}(0)

@threads for idx in eachindex(tasks)
    kind, label, rep, w, steps, eps, mot, con, textbook, rate, cost = tasks[idx]
    c = ModelConfig(grid_size=(w, w), F=5, Q=(kind == :med6topup ? 5 : 3),
        seed_culture=true, seed=rep, motivation=mot, social_contagion=con,
        textbook=textbook, bounded_confidence_threshold=eps,
        enforcement=(rate > 0 ? NormSanctions() : NoEnforcement()),
        monitoring_rate=rate, sanction_cost=cost,
        max_steps=steps, recording_interval=steps)
    s = single_run(c)[:summary]
    rows[idx] = Dict{Symbol,Any}(:kind => String(kind), :label => label, :replication => rep,
        :seed => rep, :final_n_regions => s[:final_n_regions],
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
open("results/redteam_round4.csv", "w") do io
    println(io, "kind,label,replication,seed,final_n_regions,final_largest_share,final_partial_compliance,final_mean_motivation,final_system1_fraction")
    for r in rows
        println(io, "$(r[:kind]),\"$(r[:label])\",$(r[:replication]),$(r[:seed]),$(r[:final_n_regions]),$(r[:final_largest_share]),$(r[:final_partial_compliance]),$(r[:final_mean_motivation]),$(r[:final_system1_fraction])")
    end
end
println("Done round4 -> results/redteam_round4.csv")
