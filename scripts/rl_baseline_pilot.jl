# F10 pilot: heuristic baselines + transfer for the tabular RL manager.
# Mirrors run_rl_heldout.jl protocol (11x11 F3Q3 150p, chunks of 25) at pilot
# scale (15 train eps, 6 held-out seeds), ADDS the two missing comparisons
# the paper declares absent: (1) domain-heuristic baselines
# (threshold-0.8, periodic-50%), (2) transfer to a 15x15 grid.
# Pilot-scale: NEVER a paper number (see TRACE T27). Corpus untouched.
# Usage: julia --project=. scripts/rl_baseline_pilot.jl  (~10 min)
using CulturalDynamics
using Accessors: @set
using Agents: abmproperties
using Statistics: mean
using CSV, DataFrames

const CHUNK = 25

function rollout(rate_fn, seed; grid=11, max_steps=150)
    cfg = ModelConfig(grid_size=(grid, grid), F=3, Q=3, seed_culture=true,
        seed=seed, max_steps=max_steps, recording_interval=max_steps,
        intervention=DirectedTraining(), training_rate=0.0)
    model = build_model(cfg)
    done, cost = 0, 0.0
    while done < max_steps
        rate = rate_fn(model)
        cfg_now = abmproperties(model)[:config]
        abmproperties(model)[:config] = @set cfg_now.training_rate = rate
        h = min(CHUNK, max_steps - done)
        step!(model, h)
        done += h
        cost += rate * h
    end
    return partial_compliance(model), cost / max_steps
end

stateless(rate) = (m -> rate)
threshold(th) = (m -> partial_compliance(m) < th ? 0.02 : 0.0)
periodic() = let k = Ref(0)
    (m -> (k[] += 1; isodd(k[]) ? 0.02 : 0.0))
end

println("Treinando pilot (seed_base=1000, 15 eps)...")
cfg = ModelConfig(grid_size=(11, 11), F=3, Q=3, seed_culture=true, seed=1,
                  max_steps=150)
rl = train_rl(cfg; n_episodes=15)
policy = rl[:policy]
println("pilot policy=$(policy)")
pol_fn = let pol = policy
    (m -> begin
        rd = count_regions(m)
        TRAINING_RATES[pol[discretize_state(partial_compliance(m),
                                            rd[:largest_share])]]
    end)
end

arms = Dict("policy" => pol_fn, "never" => stateless(0.0),
            "always" => stateless(0.02), "thresh08" => threshold(0.8),
            "periodic" => periodic())
heldout = 5001:5006
rows = Vector{Dict{Symbol,Any}}()
for grid in (11, 15), seed in heldout, (name, fn) in arms
    p, c = rollout(fn, seed; grid=grid)
    push!(rows, Dict(:grid => grid, :seed => seed, :arm => name,
                     :partial => p, :cost => c))
    println("done grid=$grid seed=$seed arm=$name p=$(round(p, digits=3))")
end
mkpath("results")
CSV.write("results/rl_baseline_pilot.csv", DataFrame(rows))
println("--- pilot means (partial / cost) ---")
for grid in (11, 15), name in keys(arms)
    sub = filter(r -> r[:grid] == grid && r[:arm] == name, rows)
    println("grid=$grid arm=$name partial=$(round(mean(r[:partial] for r in sub), digits=3)) " *
            "cost=$(round(mean(r[:cost] for r in sub), digits=4))")
end
println("Done -> results/rl_baseline_pilot.csv (pilot-scale, fora do corpus)")
