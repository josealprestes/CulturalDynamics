using .CoreTypes

"""
    check_bounded_confidence(agent::ComplianceAgent, partner::ComplianceAgent, config::ModelConfig) -> Bool

Check if two agents should interact based on bounded confidence threshold.

If similarity < ε, agents reject each other and no interaction occurs.

# Arguments
- `agent`: The focal agent
- `partner`: The potential interaction partner
- `config`: Model configuration with bounded_confidence_threshold

# Returns
- `true` if interaction is allowed (similarity ≥ ε)
- `false` if interaction is blocked (similarity < ε)
"""
function check_bounded_confidence(agent::ComplianceAgent, partner::ComplianceAgent, config::ModelConfig)
    similarity = compute_similarity(agent, partner, config)
    return similarity >= config.bounded_confidence_threshold
end
