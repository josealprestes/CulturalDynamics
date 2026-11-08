using .CoreTypes

"""
    compute_reward(env::ComplianceEnv, action::Int) -> Float64

Compute reward based on the configured reward type.

# Arguments
- `env`: The RL environment
- `action`: The action taken by the RL agent

# Returns
- Reward value
"""
function compute_reward(env::ComplianceEnv, action::Int)
    config = abmproperties(env.model)[:config]
    
    # Get pre-action metrics
    old_compliance = compliance_rate(env.model)
    
    # Compute reward based on type
    if env.rl_config.reward_type == :compliance
        # Δ compliance level
        new_compliance = compliance_rate(env.model)
        return (new_compliance - old_compliance) * 10.0
        
    elseif env.rl_config.reward_type == :region
        # Region harmony reward
        region_data = count_regions(env.model)
        largest_share = region_data[:largest_share]
        return largest_share * 1.0
        
    elseif env.rl_config.reward_type == :motivation
        # Δ motivation force
        rl_agent = nothing
        for agent in allagents(env.model)
            if agent.id == env.rl_config.rl_agent_id
                rl_agent = agent
                break
            end
        end
        isnothing(rl_agent) && return 0.0
        return rl_agent.motivation * 0.1
        
    else
        return 0.0
    end
end
