using .CoreTypes

"""
    update_system2_weight!(agent::ComplianceAgent, config::ModelConfig)

Update agent's System 2 weight based on dual process theory.

Following Kahneman (2011) and Sharpanskykh & Haest (2016), Eq. 2:
    α_i(t+Δt) = α_i(t) + ζ × (α_min - α_i(t)) × Δt

- Fresh procedures: System 2 (deliberate, high weight)
- Repeated execution: System 1 (habitual, low weight)
- Procedural changes: reset to System 2

# Arguments
- `agent`: The agent to update
- `config`: Model configuration

# Notes
- `system2_weight` decreases over time (habit formation)
- Minimum value is 0.1 (agent never becomes fully automatic)
- Transition rate ζ = 0.015 (~2 months for habit formation per Sharpanskykh)
"""
function update_system2_weight!(agent::ComplianceAgent, config::ModelConfig)
    # Transition rate (from Sharpanskykh 2016)
    ζ = 0.015
    
    # Minimum System 2 weight (agent retains some deliberation)
    α_min = 0.1
    
    # Update system2_weight: decrease towards α_min
    agent.system2_weight = agent.system2_weight + ζ * (α_min - agent.system2_weight)
    
    # Clamp to valid range
    agent.system2_weight = clamp(agent.system2_weight, 0.0, 1.0)
    
    return nothing
end

"""
    reset_system2!(agent::ComplianceAgent)

Reset agent to System 2 (deliberate reasoning) mode.

Called when procedures change or new rules are introduced.
"""
function reset_system2!(agent::ComplianceAgent)
    agent.system2_weight = 1.0
    return nothing
end
