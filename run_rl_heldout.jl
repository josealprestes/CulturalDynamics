# HIGH-4 (red-team): avaliação held-out da política RL + baselines.
# Treina em seed_base=1000 (25 eps, 11×11 F3Q3 150p) e avalia a política
# greedy em 10 seeds held-out (5001..5010) contra nunca-treinar e
# sempre-0.02, nas MESMAS seeds. Reporta aderência + custo (taxa média usada).
# LIMITES (declarados no paper §sec:rl): sem baseline heurística de domínio
# (ex. treina-até-0.8), sem transferência p/ outra grade/conjunto de ações,
# λ=5.0 fixo sem ablação — proof-of-concept, não política implantável.
# Uso: julia --project=. run_rl_heldout.jl  (~5 min)
# Saída: results/rl_heldout.csv
using CulturalDynamics
using Accessors: @set
using Agents: abmproperties

function eval_policy(policy, seed; max_steps=150, chunk=25)
    cfg = ModelConfig(grid_size=(11, 11), F=3, Q=3, seed_culture=true, seed=seed,
        max_steps=max_steps, recording_interval=max_steps,
        intervention=DirectedTraining(), training_rate=0.0)
    model = build_model(cfg)
    done, cost = 0, 0.0
    while done < max_steps
        rd = count_regions(model)
        s = discretize_state(partial_compliance(model), rd[:largest_share])
        rate = TRAINING_RATES[policy[s]]
        # dois passos: @set aninhado em Dict devolveria o Dict todo
        cfg_now = abmproperties(model)[:config]
        abmproperties(model)[:config] = @set cfg_now.training_rate = rate
        h = min(chunk, max_steps - done)
        step!(model, h)
        done += h
        cost += rate * h
    end
    return partial_compliance(model), cost / max_steps
end

function eval_fixed(rate, seed; max_steps=150)
    cfg = ModelConfig(grid_size=(11, 11), F=3, Q=3, seed_culture=true, seed=seed,
        max_steps=max_steps, recording_interval=max_steps,
        intervention=DirectedTraining(), training_rate=rate)
    model = build_model(cfg)
    step!(model, max_steps)
    return partial_compliance(model)
end

println("Treinando (seed_base=1000, 25 eps)...")
# seed=1 abaixo é só o placeholder do config (train_rl deriva suas
# próprias streams de seed_base=1000) — sem colisão com sweeps.
cfg = ModelConfig(grid_size=(11, 11), F=3, Q=3, seed_culture=true, seed=1, max_steps=150)
rl = train_rl(cfg; n_episodes=25)
policy = rl[:policy]
println("policy=$(policy)")

heldout = 5001:5010
mkpath("results")
open("results/rl_heldout.csv", "w") do io
    println(io, "seed,policy_partial,policy_mean_rate,never_partial,always_partial")
    for seed in heldout
        pp, cost = eval_policy(policy, seed)
        pn = eval_fixed(0.0, seed)
        pa = eval_fixed(0.02, seed)
        println(io, "$(seed),$(pp),$(cost),$(pn),$(pa)")
        println("done seed=$seed")
    end
end
println("Done -> results/rl_heldout.csv")
