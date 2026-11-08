# src/core/metrics.jl — outcome metrics + recording (CoreTypes partition)
#
# Loaded via `include` at the end of types.jl (same module/namespace).

"""
    compute_similarity(agent::ComplianceAgent, partner::ComplianceAgent, config::ModelConfig) -> Float64
"""
function compute_similarity(agent::ComplianceAgent, partner::ComplianceAgent, config::ModelConfig)
    overlap = count(i -> agent.features[i] == partner.features[i], 1:config.F)
    return overlap / config.F
end

"""
    compliance_rate(model) -> Float64
"""
function compliance_rate(model)
    config = abmproperties(model)[:config]
    agents_list = collect(allagents(model))
    n = length(agents_list)
    n == 0 && return 0.0
    compliant = count(agent -> all(f -> f == config.Q, agent.features), agents_list)
    return compliant / n
end

function compliance_rate(model, dimension::Int)
    config = abmproperties(model)[:config]
    agents_list = collect(allagents(model))
    n = length(agents_list)
    n == 0 && return 0.0
    compliant = count(agent -> agent.features[dimension] == config.Q, agents_list)
    return compliant / n
end

"""
    partial_compliance(model) -> Float64

Mean normalized adherence across agents and dimensions, ∈ [0, 1].

Each trait contributes `(f - 1) / (Q - 1)` (0 = total rejection, 1 = full
adherence). Unlike strict `compliance_rate` (all F dims at Q, ≈0 almost
everywhere), this discriminates across the whole parameter space:
uniform random init ≈ 0.5, monoculture at Q → 1.0, at 1 → 0.0.
Primary outcome metric for intervention studies (F2.5+).
"""
function partial_compliance(model)
    config = abmproperties(model)[:config]
    agents_list = collect(allagents(model))
    n = length(agents_list)
    n == 0 && return 0.0
    config.Q <= 1 && return 1.0
    total = 0.0
    denom = config.Q - 1
    for agent in agents_list
        for f in agent.features
            total += (f - 1) / denom
        end
    end
    return total / (n * config.F)
end

"""
    mean_motivation(model) -> Float64

Mean Vroom motivation force across agents, ∈ [0, 1].
"""
function mean_motivation(model)
    agents_list = collect(allagents(model))
    isempty(agents_list) && return 0.0
    return mean(a -> a.motivation, agents_list)
end

"""
    mean_openness(model) -> Float64

Mean receptiveness to social influence across agents, ∈ [0, 1].
"""
function mean_openness(model)
    agents_list = collect(allagents(model))
    isempty(agents_list) && return 0.0
    return mean(a -> a.openness, agents_list)
end

"""
    system1_fraction(model) -> Float64

Share of habitual agents (`system2_weight < 0.5`), ∈ [0, 1].
"""
function system1_fraction(model)
    agents_list = collect(allagents(model))
    n = length(agents_list)
    n == 0 && return 0.0
    habitual = count(a -> a.system2_weight < 0.5, agents_list)
    return habitual / n
end

"""
    record_metrics!(model)

Append current outcome snapshot (compliance, regions, motivation,
interaction counters) to `metadata.history`.
"""
function record_metrics!(model)
    meta = abmproperties(model)[:metadata]
    config = abmproperties(model)[:config]
    region_data = count_regions(model)
    compliance_rates = Dict(d => compliance_rate(model, d) for d in 1:config.F)
    push!(meta.history, Dict{Symbol,Any}(
        :step => meta.step_count,
        :compliance_rate => compliance_rate(model),
        :partial_compliance => partial_compliance(model),
        :compliance_rates => compliance_rates,
        :n_regions => region_data[:n_regions],
        :largest_region => region_data[:largest_region],
        :largest_share => region_data[:largest_share],
        :mean_region_size => region_data[:mean_region_size],
        :mean_motivation => mean_motivation(model),
        :mean_openness => mean_openness(model),
        :system1_fraction => system1_fraction(model),
        :effective_interactions => meta.effective_interactions,
        :attempted_interactions => meta.attempted_interactions,
        :is_absorbed => meta.is_absorbed,
    ))
    return nothing
end

function check_absorption!(model)
    config = abmproperties(model)[:config]
    meta = abmproperties(model)[:metadata]
    meta.is_absorbed && return nothing
    for agent in allagents(model)
        nbrs = get_valid_neighbors(agent, model, config)
        for neighbor in nbrs
            overlap = count(i -> agent.features[i] == neighbor.features[i], 1:config.F)
            if 0 < overlap < config.F
                meta.is_absorbed = false
                return nothing
            end
        end
    end
    meta.is_absorbed = true
    meta.absorbed_at = meta.step_count
    return nothing
end
