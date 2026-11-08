using .CoreTypes

"""
    state_space(env::ComplianceEnv) -> NamedTuple

Return the state space descriptor for the RL environment
(plain NamedTuple — no RLBase dependency; was `Space`, never loadable).
"""
function state_space(env::ComplianceEnv)
    config = abmproperties(env.model)[:config]
    max_obs_dim = config.F * 9 + 2
    return (type=:continuous, low=0.0, high=1.0, dims=max_obs_dim)
end

"""
    action_space(env::ComplianceEnv) -> NamedTuple

Return the action space descriptor for the RL environment.
Dynamic in principle (depends on valid neighbors); max 8 + "do nothing".
"""
function action_space(env::ComplianceEnv)
    # Dynamic — depends on number of valid neighbors
    # Max 8 neighbors + 1 "do nothing" = 9 actions max
    return (type=:discrete, n=9)
end

"""
    state(env::ComplianceEnv) -> Vector{Float64}

Return the current observation for the RL agent.
"""
function state(env::ComplianceEnv)
    config = abmproperties(env.model)[:config]
    F = config.F
    Q = config.Q
    
    # Find RL agent
    rl_agent = nothing
    for agent in allagents(env.model)
        if agent.id == env.rl_config.rl_agent_id
            rl_agent = agent
            break
        end
    end
    isnothing(rl_agent) && return zeros(Float64, F * 9 + 2)
    
    # Get valid neighbors
    neighbors = get_valid_neighbors(rl_agent, env.model, config)
    N = min(length(neighbors), 8)
    
    # Fill buffer
    fill!(env.obs_buffer, 0.0)
    
    # Own features (normalized)
    env.obs_buffer[1:F] .= rl_agent.features ./ Q
    
    # Neighbor features (normalized)
    for (i, nagent) in enumerate(neighbors[1:N])
        offset = F + (i-1) * F
        env.obs_buffer[offset+1:offset+F] .= nagent.features ./ Q
    end
    
    # Motivation and system2_weight
    env.obs_buffer[F*9+1] = rl_agent.motivation
    env.obs_buffer[F*9+2] = rl_agent.system2_weight
    
    return env.obs_buffer
end
