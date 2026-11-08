using .CoreTypes

"""
    single_run(config::ModelConfig) -> Dict{Symbol, Any}

Run a single simulation and return results.

# Arguments
- `config`: Model configuration

# Returns
- Dictionary with:
  - `:config` — the configuration used
  - `:history` — metrics history
  - `:summary` — final summary metrics
"""
function single_run(config::ModelConfig)
    model = build_model(config)
    step!(model, config.max_steps)
    region_data = count_regions(model)
    meta = abmproperties(model)[:metadata]
    summary = Dict{Symbol,Any}(
        :final_compliance_rate => compliance_rate(model),
        :final_partial_compliance => partial_compliance(model),
        :final_n_regions => region_data[:n_regions],
        :final_largest_region => region_data[:largest_region],
        :final_largest_share => region_data[:largest_share],
        :final_mean_region_size => region_data[:mean_region_size],
        :final_mean_motivation => mean_motivation(model),
        :final_system1_fraction => system1_fraction(model),
        :steps_to_absorption => meta.step_count,
        :absorbed_at => meta.absorbed_at,
        :is_absorbed => meta.is_absorbed,
    )
    return Dict{Symbol,Any}(
        :config => config,
        :history => meta.history,
        :summary => summary,
    )
end

"""
    batch_run(config::ModelConfig; n_reps::Int=30) -> Vector{Dict{Symbol, Any}}

Run multiple replications of the simulation.

# Arguments
- `config`: Model configuration
- `n_reps`: Number of replications

# Returns
- Vector of result dictionaries
"""
function batch_run(config::ModelConfig; n_reps::Int=30)
    results = Dict{Symbol,Any}[]
    for rep in 1:n_reps
        rep_config = @set config.seed = config.seed + rep
        push!(results, single_run(rep_config))
    end
    return results
end
