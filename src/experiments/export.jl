using .CoreTypes

"""
    export_csv(results::Vector{Dict{Symbol,Any}}, path::String)

Export experiment results to CSV format.

# Arguments
- `results`: Vector of result dictionaries from batch_run or parameter_sweep
- `path`: Output file path
"""
function export_csv(results::Vector{Dict{Symbol,Any}}, path::String)
    # Flatten results into rows
    rows = []
    
    for (i, r) in enumerate(results)
        config = r[:config]
        summary = r[:summary]
        
        row = Dict{Symbol,Any}(
            :experiment_id => i,
            :F => config.F,
            :Q => config.Q,
            :epsilon => config.bounded_confidence_threshold,
            :mutation_rate => config.mutation_rate,
            :training_rate => config.training_rate,
            :grid_size => config.grid_size,
            :seed => config.seed,
            :final_compliance_rate => summary[:final_compliance_rate],
            :final_partial_compliance => summary[:final_partial_compliance],
            :final_n_regions => summary[:final_n_regions],
            :final_largest_region => summary[:final_largest_region],
            :final_largest_share => summary[:final_largest_share],
            :final_mean_region_size => summary[:final_mean_region_size],
            :final_mean_motivation => summary[:final_mean_motivation],
            :final_system1_fraction => summary[:final_system1_fraction],
            :steps_to_absorption => summary[:steps_to_absorption],
            :absorbed_at => summary[:absorbed_at],
            :is_absorbed => summary[:is_absorbed],
        )
        
        # Add sweep metadata if present
        if haskey(r, :sweep_F)
            row[:sweep_F] = r[:sweep_F]
            row[:sweep_Q] = r[:sweep_Q]
            row[:sweep_epsilon] = r[:sweep_epsilon]
            row[:replication] = r[:replication]
        end
        
        push!(rows, row)
    end
    
    # Convert to DataFrame and write
    df = DataFrame(rows)
    CSV.write(path, df)
    
    println("Exported $(length(results)) results to $path")
    return nothing
end

"""
    export_json(results::Vector{Dict{Symbol,Any}}, path::String)

Export experiment results to JSON format.
"""
function export_json(results::Vector{Dict{Symbol,Any}}, path::String)
    # Convert to JSON-serializable structure
    json_data = []
    
    for r in results
        config = r[:config]
        summary = r[:summary]
        
        entry = Dict{String,Any}(
            "config" => Dict{String,Any}(
                "F" => config.F,
                "Q" => config.Q,
                "epsilon" => config.bounded_confidence_threshold,
                "mutation_rate" => config.mutation_rate,
                "training_rate" => config.training_rate,
                "grid_size" => collect(config.grid_size),
                "seed" => config.seed,
            ),
            "summary" => Dict{String,Any}(
                "final_compliance_rate" => summary[:final_compliance_rate],
                "final_partial_compliance" => summary[:final_partial_compliance],
                "final_n_regions" => summary[:final_n_regions],
                "final_largest_region" => summary[:final_largest_region],
                "final_largest_share" => summary[:final_largest_share],
                "final_mean_region_size" => summary[:final_mean_region_size],
                "final_mean_motivation" => summary[:final_mean_motivation],
                "final_system1_fraction" => summary[:final_system1_fraction],
                "steps_to_absorption" => summary[:steps_to_absorption],
                "absorbed_at" => summary[:absorbed_at],
                "is_absorbed" => summary[:is_absorbed],
            ),
        )
        
        push!(json_data, entry)
    end
    
    # Write JSON
    open(path, "w") do f
        JSON3.write(f, json_data)
    end
    
    println("Exported $(length(results)) results to $path")
    return nothing
end

"""
    export_jld2(results::Vector{Dict{Symbol,Any}}, path::String)

Export experiment results to JLD2 format (preserves Julia types).
"""
function export_jld2(results::Vector{Dict{Symbol,Any}}, path::String)
    JLD2.@save path results
    
    println("Exported $(length(results)) results to $path")
    return nothing
end
