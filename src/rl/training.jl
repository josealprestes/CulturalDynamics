using .CoreTypes
using Random: Xoshiro, rand

"""
    TRAINING_RATES

Discrete manager actions: training intensity applied for one chunk of steps.
Calibrated so that per-chunk adherence deltas (×10) and costs (λ×rate)
live on the same scale (see `train_rl`).
"""
const TRAINING_RATES = (0.0, 0.005, 0.02)

"""
    discretize_state(partial::Float64, largest_share::Float64) -> Int

Coarse org state 1..6: adherence bucket (low <0.55 / mid / high ≥0.85)
× fragmentation bucket (fragmented largest_share <0.1 / consolidated).
"""
function discretize_state(partial::Float64, largest_share::Float64)
    adh = partial < 0.55 ? 1 : (partial < 0.85 ? 2 : 3)
    frag = largest_share < 0.1 ? 1 : 2
    return (adh - 1) * 2 + frag
end

function observe_state(model)
    rd = count_regions(model)
    return discretize_state(partial_compliance(model), rd[:largest_share])
end

function epsilon_greedy(Q::Matrix{Float64}, s::Int, rng, epsilon::Float64)
    if rand(rng) < epsilon
        return rand(rng, 1:size(Q, 2))
    end
    return argmax(@view Q[s, :])
end

"""
    train_rl(config::ModelConfig; n_episodes=100, rl_config=RLConfig(),
             seed_base=1000, chunk_steps=25) -> Dict

Tabular Q-learning (F4) for the manager problem: which training intensity
minimizes cost while building adherence. Lateral copying conserves mean
adherence (F2.5), so the learned policy is a cost-aware shutoff: train
hard far from the cap, taper near it.

Episode: fresh model (seed_base + ep, intervention forced to
`DirectedTraining`); every `chunk_steps` the agent observes the coarse
state, sets `training_rate`, and earns
`reward = 10×Δpartial_compliance − λ×rate`.

Returns Q-table, greedy policy (action index per state 1..6), per-episode
rewards, final adherence. Legacy keys (`:rewards`, `:final_compliance`,
`:n_episodes`) preserved — note `:final_compliance` carries final *partial*
adherence (legacy name, kept for API stability).
"""
function train_rl(config::ModelConfig; n_episodes::Int=100, rl_config=RLConfig(),
                  seed_base::Int=1000, chunk_steps::Int=25, kwargs...)
    n_states, n_actions = 6, length(TRAINING_RATES)
    Q = zeros(Float64, n_states, n_actions)
    rewards = Float64[]
    finals = Float64[]
    α, γ, ϵ, λ = rl_config.alpha, rl_config.gamma, rl_config.epsilon, rl_config.lambda_cost

    for ep in 1:n_episodes
        rng = Xoshiro(seed_base + ep)
        cfg = config
        cfg = @set cfg.seed = seed_base + ep
        cfg = @set cfg.intervention = DirectedTraining()
        cfg = @set cfg.training_rate = 0.0
        model = build_model(cfg)
        total, done_steps = cfg.max_steps, 0
        s = observe_state(model)
        p_prev = partial_compliance(model)
        ep_reward = 0.0
        while done_steps < total
            a = epsilon_greedy(Q, s, rng, ϵ)
            rate = TRAINING_RATES[a]
            # NB: @set sobre props[:config].x devolveria o Dict todo;
            # atualizar em dois passos para preservar o ModelConfig.
            cfg_now = abmproperties(model)[:config]
            abmproperties(model)[:config] = @set cfg_now.training_rate = rate
            h = min(chunk_steps, total - done_steps)
            step!(model, h)
            done_steps += h
            p_now = partial_compliance(model)
            r = (p_now - p_prev) * 10.0 - λ * rate
            s2 = observe_state(model)
            Q[s, a] += α * (r + γ * maximum(@view Q[s2, :]) - Q[s, a])
            ep_reward += r
            s, p_prev = s2, p_now
        end
        push!(rewards, ep_reward)
        push!(finals, partial_compliance(model))
    end
    policy = vec(mapslices(argmax, Q; dims=2))
    final = isempty(finals) ? 0.0 : finals[end]
    println("train_rl: $n_episodes eps, Q-learning, partial final=$(round(final, digits=4)) " *
            "reward medio=$(round(sum(rewards) / max(1, length(rewards)), digits=4)) " *
            "policy=$(policy')")
    return Dict(:Q_table => Q, :policy => policy, :actions => collect(TRAINING_RATES),
                :rewards => rewards, :mean_reward => sum(rewards) / max(1, length(rewards)),
                :final_partial => final,
                :final_compliance => isempty(rewards) ? 0.0 : finals[end],
                :n_episodes => n_episodes)
end
