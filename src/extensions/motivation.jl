using .CoreTypes

"""
    compute_motivation(agent::ComplianceAgent, config::ModelConfig) -> Float64

Compute motivation force using Vroom's Expectancy Theory.

Following Vroom (1964) and Sharpanskykh & Haest (2016), Eq. 1:
    F_k,i(t) = Σₗ E_kl,i(t) × Σₕ V_h,i(t) × I_klh,i(t)

where:
    E = expectancy (belief that compliance leads to outcome)
    I = instrumentality (belief that outcome leads to goal)
    V = valence (desire for the goal)

# Returns
- Motivation force ∈ [0, 1]
"""
function compute_motivation(agent::ComplianceAgent, config::ModelConfig)
    # For FixedCompliance, motivation is always 1.0
    config.motivation isa FixedCompliance && return 1.0
    
    # For VroomExpectancy, compute based on agent characteristics
    # Simplified model: motivation depends on openness and social rank
    
    # Expectancy: belief that compliance leads to safety/approval
    expectancy = agent.openness * 0.8 + (1 - agent.openness) * 0.2
    
    # Instrumentality: belief that safety leads to goals
    instrumentality = agent.social_rank * 0.6 + 0.4
    
    # Valence: desire for the goal (varies by agent)
    valence = agent.motivation
    
    # Motivation force (normalized to [0, 1])
    motivation_force = expectancy * instrumentality * valence
    
    return clamp(motivation_force, 0.0, 1.0)
end
