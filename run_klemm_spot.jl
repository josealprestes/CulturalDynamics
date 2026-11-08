# KILL-2 (red-team, spot Klemm): multiculturalidade sobrevive a ruído?
# F=5 Q=3 ε=0.3 21×21, PoissonMutation r ∈ {0, 1e-4, 1e-3}, até absorção ou
# cap de 10000 passos, com checkpoints. Semântica: maybe_mutate! dispara por
# agente que COPIOU no passo (taxa por traço = mutation_rate).
# Klemm et al. 2003: qualquer r>0 colapsa o mosaico (monocultura errante ou
# desordem sustentada) dado horizonte > T~N ln N.
# Uso: julia --project=. run_klemm_spot.jl  (~25-40 min)
# Saída: results/klemm_spot.csv
using CulturalDynamics
using Agents: abmproperties

rates = [0.0, 1e-4, 1e-3]
reps = 1:3
checkpoints = [300, 1000, 3000, 10000]
println("Klemm spot: $(length(rates)) rates x $(length(reps)) reps, cap $(maximum(checkpoints))")
mkpath("results")
open("results/klemm_spot.csv", "w") do io
    println(io, "rate,replication,step,final_n_regions,final_largest_share,final_partial_compliance,is_absorbed")
    for rate in rates
        for rep in reps
            strat = rate <= 0 ? NoMutation() : PoissonMutation()
            c = ModelConfig(grid_size=(21, 21), F=5, Q=3, seed_culture=true, seed=rep,
                mutation=strat, mutation_rate=rate,
                bounded_confidence_threshold=0.3, max_steps=maximum(checkpoints),
                recording_interval=maximum(checkpoints))
            model = build_model(c)
            prev = 0
            for cp in checkpoints
                step!(model, cp - prev)
                prev = cp
                meta = abmproperties(model)[:metadata]
                rd = count_regions(model)
                println(io, "$(rate),$(rep),$(cp),$(rd[:n_regions]),$(rd[:largest_share]),$(partial_compliance(model)),$(meta.is_absorbed)")
                flush(io)
                meta.is_absorbed && break
            end
        end
        println("done rate=$rate")
    end
end
println("Done -> results/klemm_spot.csv")
