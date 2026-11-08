# Red-team round 5: P3 é treino renomeado? Punição importa?
# - Training-vs-monitoring (Fixed): DirectedTraining rate {0.005,0.02} vs
#   NormSanctions monitoring {0.02} (enforcement_sweep.csv, mesmas seeds 1..8).
#   Sob Fixed, motivação pinada → auditoria ≈ nudge estocástico p/ Q.
#   Se curvas iguais, P3 sob Fixed = treino renomeado (admitir).
# - Sanction on/off (Vroom): monitoring 0.02 + sanction_cost {0.0} vs {0.1}
#   (round4, mesmas seeds). Se iguais, punição não contribui nem sob Vroom
#   (efeito = cumprir-quando-vigiado apenas).
# Uso: julia --project=. run_redteam_round5.jl  (~6 min)
# Saída: results/redteam_round5.csv
using CulturalDynamics
using Base.Threads

tasks = Tuple[]
for rate in [0.005, 0.02], rep in 1:8
    push!(tasks, (:train, "train$(rate)", rep, rate, 0.0))
end
for rep in 1:8
    push!(tasks, (:sanction, "sanction0.0", rep, 0.02, 0.0))
end
println("Red-team round5: $(length(tasks)) sims em $(nthreads()) threads")

rows = Vector{Dict{Symbol,Any}}(undef, length(tasks))
done_count = Atomic{Int}(0)

@threads for idx in eachindex(tasks)
    kind, label, rep, rate, cost = tasks[idx]
    if kind == :train
        c = ModelConfig(grid_size=(21, 21), F=5, Q=3, seed_culture=true, seed=rep,
            intervention=DirectedTraining(), training_rate=rate,
            bounded_confidence_threshold=0.3, max_steps=300, recording_interval=300)
    else
        c = ModelConfig(grid_size=(21, 21), F=5, Q=3, seed_culture=true, seed=rep,
            motivation=VroomExpectancy(), textbook=false,
            enforcement=NormSanctions(), monitoring_rate=rate, sanction_cost=cost,
            bounded_confidence_threshold=0.3, max_steps=300, recording_interval=300)
    end
    s = single_run(c)[:summary]
    rows[idx] = Dict{Symbol,Any}(:kind => String(kind), :label => label, :replication => rep,
        :seed => rep, :final_n_regions => s[:final_n_regions],
        :final_largest_share => s[:final_largest_share],
        :final_partial_compliance => s[:final_partial_compliance],
        :final_mean_motivation => s[:final_mean_motivation])
    n = atomic_add!(done_count, 1) + 1
    if n % 8 == 0 || n == length(tasks)
        println("  concluidas: $n/$(length(tasks))")
    end
end

mkpath("results")
open("results/redteam_round5.csv", "w") do io
    println(io, "kind,label,replication,seed,final_n_regions,final_largest_share,final_partial_compliance,final_mean_motivation")
    for r in rows
        println(io, "$(r[:kind]),\"$(r[:label])\",$(r[:replication]),$(r[:seed]),$(r[:final_n_regions]),$(r[:final_largest_share]),$(r[:final_partial_compliance]),$(r[:final_mean_motivation])")
    end
end
println("Done round5 -> results/redteam_round5.csv")
