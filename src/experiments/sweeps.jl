using .CoreTypes

"""
    parameter_sweep(
        base_config::ModelConfig;
        F_values = [5, 10, 15],
        Q_values = [3, 5, 10],
        epsilon_values = [0.0, 0.3, 0.6],
        n_replications = 30,
    ) -> Vector{Dict{Symbol, Any}}

Run a parameter sweep across Cartesian product of parameter values.

# Arguments
- `base_config`: Base model configuration
- `F_values`: Values of F to sweep
- `Q_values`: Values of Q to sweep
- `epsilon_values`: Values of ε to sweep
- `n_replications`: Number of replications per parameter combination

# Returns
- Vector of result dictionaries with parameter metadata
"""
function parameter_sweep(
    base_config::ModelConfig;
    F_values = [5, 10, 15],
    Q_values = [3, 5, 10],
    epsilon_values = [0.0, 0.3, 0.6],
    n_replications = 30,
)
    results = Dict{Symbol,Any}[]
    
    total_combinations = length(F_values) * length(Q_values) * length(epsilon_values)
    combination = 0
    
    for F in F_values, Q in Q_values, ε in epsilon_values
        combination += 1
        println("Sweep $combination/$total_combinations: F=$F, Q=$Q, ε=$ε")
        
        for rep in 1:n_replications
            config = @set base_config.F = F
            config = @set config.Q = Q
            config = @set config.bounded_confidence_threshold = ε
            config = @set config.seed = base_config.seed + rep
            
            # Run simulation
            result = single_run(config)
            
            # Add sweep metadata
            result[:sweep_F] = F
            result[:sweep_Q] = Q
            result[:sweep_epsilon] = ε
            result[:replication] = rep
            
            push!(results, result)
        end
    end
    
    return results
end
