using .CoreTypes
using ReinforcementLearningBase: AbstractEnv

"""
    ComplianceEnv <: AbstractEnv

RL environment wrapping a CulturalDynamics ABM.

The RL agent controls which neighbor to interact with and which trait to copy.

# State Space
- Observation: [own_features; neighbor_features; motivation; system2_weight]
- Normalized to [0, 1]

# Action Space
- Discrete {1..N, N+1} where N = valid neighbors, N+1 = "do nothing"

# Rewards
- :compliance — Δ overall compliance level
- :region — +1 if region became more homogeneous
- :motivation — Δ motivation force
"""
mutable struct ComplianceEnv <: AbstractEnv
    model::Any
    rl_config::RLConfig
    current_reward::Float64
    done::Bool
    step_in_episode::Int
    
    # Pre-allocated observation buffer
    obs_buffer::Vector{Float64}
end

"""
    ComplianceEnv(config::ModelConfig; rl_config::RLConfig=RLConfig())

Create a new RL environment from model configuration.
"""
function ComplianceEnv(config::ModelConfig; rl_config::RLConfig=RLConfig())
    model = build_model(config)
    
    # Pre-allocate observation buffer
    max_obs_dim = config.F * 9 + 2  # own + 8 neighbors + motivation + system2_weight
    obs_buffer = zeros(Float64, max_obs_dim)
    
    return ComplianceEnv(
        model,
        rl_config,
        0.0,
        false,
        0,
        obs_buffer,
    )
end
