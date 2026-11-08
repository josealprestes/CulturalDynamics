# Red-team round 3: MED-6 fino, contágio n=60, decomposição p2.
# - MED6-fine: F5Q5 ε∈{0.0,0.1,0.2,0.3,0.4} 31×31 500p, seeds 100..114 (n=15).
#   Localiza o dip e testa "filtro protege coarsening" (forma em U?).
# - Contágio n=60: Vroom × {No,Weighted} Grid 21×21 300p textbook=false,
#   seeds 31..60 (somam 1..30 → n=60). Regra pré-registrada: p<0.05 = efeito
#   pequeno existe; senão, canal decorativo para fragmentação.
# - Decomp p2a: Fixed non-textbook normal vs openness-homog (0.5), seeds 1..12.
# - Decomp p2b: Vroom + system2 congelado em 1.0 (reset por passo), seeds 1..12;
#   braço normal reaproveitado de redteam_round2.csv (determinístico).
# Uso: JULIA_NUM_THREADS=4 julia --project=. run_redteam_round3.jl (~20 min)
# Saída: results/redteam_round3.csv
using CulturalDynamics
using Agents: abmproperties, allagents, step!
using Base.Threads

tasks = Tuple[]
for eps in [0.0, 0.1, 0.2, 0.3, 0.4], rep in 100:114
    push!(tasks, (:med6fine, "e$(eps)", rep, 31, 500, eps, FixedCompliance(), WeightedContagion(), true, :single, 0.0))
end
for rep in 31:60
    push!(tasks, (:contagio60, "Vroom+No", rep, 21, 300, 0.3, VroomExpectancy(), NoContagion(), false, :single, 0.0))
    push!(tasks, (:contagio60, "Vroom+Weighted", rep, 21, 300, 0.3, VroomExpectancy(), WeightedContagion(), false, :single, 0.0))
end
for rep in 1:12
    push!(tasks, (:decomp2, "Fixed-homog", rep, 21, 300, 0.3, FixedCompliance(), WeightedContagion(), false, :homog, 0.0))
    push!(tasks, (:decomp2, "Fixed", rep, 21, 300, 0.3, FixedCompliance(), WeightedContagion(), false, :single, 0.0))
    push!(tasks, (:decomp2, "Vroom-sys2frozen", rep, 21, 300, 0.3, VroomExpectancy(), WeightedContagion(), false, :frozen, 0.0))
end
println("Red-team round3: $(length(tasks)) sims em $(nthreads()) threads")

rows = Vector{Dict{Symbol,Any}}(undef, length(tasks))
done_count = Atomic{Int}(0)

function run_summary(c, mode)
    if mode == :single
        return single_run(c)[:summary]
    end
    model = build_model(c)
    if mode == :homog
        for a in allagents(model)
            a.openness = 0.5
        end
        step!(model, c.max_steps)
    elseif mode == :frozen
        for _ in 1:c.max_steps
            step!(model, 1)
            for a in allagents(model)
                a.system2_weight = 1.0
            end
        end
    end
    rd = count_regions(model)
    return Dict{Symbol,Any}(:final_n_regions => rd[:n_regions],
        :final_largest_share => rd[:largest_share],
        :final_partial_compliance => partial_compliance(model),
        :final_mean_motivation => mean_motivation(model),
        :final_system1_fraction => system1_fraction(model))
end

@threads for idx in eachindex(tasks)
    kind, label, rep, w, steps, eps, mot, con, textbook, mode, _ = tasks[idx]
    seed = rep
    c = ModelConfig(grid_size=(w, w), F=5, Q=(kind == :med6fine ? 5 : 3),
        seed_culture=true, seed=seed, motivation=mot, social_contagion=con,
        textbook=textbook, bounded_confidence_threshold=eps,
        max_steps=steps, recording_interval=steps)
    s = run_summary(c, mode)
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
open("results/redteam_round3.csv", "w") do io
    println(io, "kind,label,replication,seed,final_n_regions,final_largest_share,final_partial_compliance,final_mean_motivation,final_system1_fraction")
    for r in rows
        println(io, "$(r[:kind]),\"$(r[:label])\",$(r[:replication]),$(r[:seed]),$(r[:final_n_regions]),$(r[:final_largest_share]),$(r[:final_partial_compliance]),$(r[:final_mean_motivation]),$(r[:final_system1_fraction])")
    end
end
println("Done round3 -> results/redteam_round3.csv")
