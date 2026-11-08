"""
    RLConfig

Configuration for the RL environment.

# Fields
- `rl_agent_id`: ID of the agent controlled by RL
- `max_episode_steps`: Maximum steps per episode
- `reward_type`: Type of reward function (:compliance, :region, :motivation)
"""
Base.@kwdef struct RLConfig
    rl_agent_id::Int = 1
    max_episode_steps::Int = 1000
    reward_type::Symbol = :compliance  # :compliance, :region, :motivation
    # F4 tabular Q-learning (org-level training intensity)
    alpha::Float64 = 0.2
    gamma::Float64 = 0.95
    epsilon::Float64 = 0.15
    chunk_steps::Int = 25
    lambda_cost::Float64 = 5.0
end
