using .CoreTypes
using Random: Xoshiro, rand

"""
    assign_roles!(model, profiles::Dict) -> model

Assign role archetypes post-build (V2, hand-hygiene anchor): for each agent
whose `team_id` is a key of `profiles`, set motivation/openness/
expressiveness from the profile mapping (missing keys keep build values).
Deterministic given fixed profiles; e.g. doctors vs nurses:
`Dict(1 => Dict(:openness => 0.3, :motivation => 0.6),
      2 => Dict(:openness => 0.7, :motivation => 0.5))`.
"""
function assign_roles!(model, profiles::Dict)
    for agent in allagents(model)
        haskey(profiles, agent.team_id) || continue
        p = profiles[agent.team_id]
        haskey(p, :motivation) && (agent.motivation = Float64(p[:motivation]))
        haskey(p, :openness) && (agent.openness = Float64(p[:openness]))
        haskey(p, :expressiveness) && (agent.expressiveness = Float64(p[:expressiveness]))
    end
    return model
end

"""
    evaluate_moments(config::ModelConfig; role_profiles=nothing) -> Dict{Symbol,Float64}

Single-episode moments: build (optionally assign roles), record initial
adherence, run `max_steps`, return `:init_partial`, `:final_partial`,
`:decline` (= init − final), `:final_n_regions`, `:final_largest_share`.
"""
function evaluate_moments(config::ModelConfig; role_profiles=nothing)
    model = build_model(config)
    if !isnothing(role_profiles)
        assign_roles!(model, role_profiles)
    end
    p0 = partial_compliance(model)
    step!(model, config.max_steps)
    rd = count_regions(model)
    p1 = partial_compliance(model)
    return Dict{Symbol,Float64}(:init_partial => p0, :final_partial => p1,
        :decline => p0 - p1, :final_n_regions => Float64(rd[:n_regions]),
        :final_largest_share => rd[:largest_share])
end

function _apply_search_param(config, pname::Symbol, val::Float64)
    if pname == :fatigue_rate
        return @set config.fatigue_rate = val
    elseif pname == :training_rate
        return @set config.training_rate = val
    elseif pname == :monitoring_rate
        return @set config.monitoring_rate = val
    elseif pname == :bounded_confidence_threshold
        return @set config.bounded_confidence_threshold = val
    elseif pname == :copy_scale
        return @set config.copy_scale = val
    elseif pname == :mutation_rate
        config = @set config.mutation_rate = val
        return @set config.mutation = val > 0 ? PoissonMutation() : NoMutation()
    elseif pname == :turnover_rate
        return @set config.turnover_rate = val
    else
        error("parâmetro de busca desconhecido: $pname")
    end
end

"""
    calibrate(base_config::ModelConfig; search, n_samples=16, n_reps=3,
              seed_base=2000, targets=Dict(:decline=>0.085),
              role_profiles=nothing) -> Dict

Random-search calibration (V2): sample `n_samples` parameter vectors
uniformly from `search` ranges (e.g. `Dict(:fatigue_rate => (0.0005, 0.005))`),
evaluate `n_reps` episodes each (seeds derived from `seed_base`), and rank
by RMSE of episode-mean moments vs `targets` (keys of `evaluate_moments`).

Returns `:best_params`, `:best_loss`, `:best_means`, `:trials`.
Gate V2 (moments_hand_hygiene.md): RMSE ≤ 0.05 (5pp) or the thesis fails.
"""
function calibrate(base_config::ModelConfig;
                   search::Dict{Symbol,Tuple{Float64,Float64}} = Dict(:fatigue_rate => (0.0005, 0.005)),
                   n_samples::Int = 16, n_reps::Int = 3, seed_base::Int = 2000,
                   targets::Dict{Symbol,Float64} = Dict(:decline => 0.085),
                   role_profiles = nothing)
    pnames = collect(keys(search))
    tkeys = collect(keys(targets))
    trials = Dict{Symbol,Any}[]
    rng = Xoshiro(seed_base)
    best_loss, best = Inf, nothing
    for i in 1:n_samples
        vals = Dict(p => (search[p][1] + (search[p][2] - search[p][1]) * rand(rng)) for p in pnames)
        reps = Dict{Symbol,Vector{Float64}}(k => Float64[] for k in tkeys)
        for rep in 1:n_reps
            cfg = base_config
            for (p, v) in vals
                cfg = _apply_search_param(cfg, p, v)
            end
            cfg = @set cfg.seed = seed_base + i * 100 + rep
            m = evaluate_moments(cfg; role_profiles=role_profiles)
            for k in tkeys
                push!(reps[k], m[k])
            end
        end
        means = Dict(k => sum(reps[k]) / length(reps[k]) for k in tkeys)
        loss = sqrt(sum((means[k] - targets[k])^2 for k in tkeys) / length(tkeys))
        push!(trials, Dict{Symbol,Any}(:params => vals, :means => means, :loss => loss))
        if loss < best_loss
            best_loss, best = loss, trials[end]
        end
    end
    return Dict{Symbol,Any}(:best_params => best[:params], :best_loss => best_loss,
                            :best_means => best[:means], :trials => trials,
                            :targets => targets)
end
