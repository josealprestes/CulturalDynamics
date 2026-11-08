# src/core/neighborhoods.jl — partner selection, topologies, lookup (CoreTypes partition)
#
# Loaded via `include` at the end of types.jl (same module/namespace).

"""
    select_partner(agent::ComplianceAgent, model, config::ModelConfig) -> Union{ComplianceAgent, Nothing}

Select a random valid neighbor for potential interaction.
"""
function select_partner(agent::ComplianceAgent, model, config::ModelConfig)
    raw_neighbors = get_topology_neighbors(agent, model, config.topology)
    valid_neighbors = filter_neighbors(raw_neighbors, agent, model, config)
    isempty(valid_neighbors) && return nothing
    partner_pos = rand(abmrng(model), valid_neighbors)
    return agent_by_pos(model, partner_pos)
end

"""
    get_topology_neighbors(agent::ComplianceAgent, model, ::GridTopology) -> Vector{CartesianIndex}
"""
function get_topology_neighbors(agent::ComplianceAgent, model, ::GridTopology)
    config = abmproperties(model)[:config]
    return get_neighborhood_positions(agent, model, config.neighborhood)
end

"""
    get_topology_neighbors(agent::ComplianceAgent, model, ::SmallWorldTopology) -> Vector{CartesianIndex}
"""
function get_topology_neighbors(agent::ComplianceAgent, model, ::SmallWorldTopology)
    meta = abmproperties(model)[:metadata]
    isnothing(meta.network) && return CartesianIndex{2}[]
    agent_idx = agent.id
    agent_idx > nv(meta.network) && return CartesianIndex{2}[]
    graph_neighbors = collect(neighbors(meta.network, agent_idx))
    result = CartesianIndex{2}[]
    for nid in graph_neighbors
        if hasid(model, nid)
            nagent = getindex(model, nid)
            push!(result, CartesianIndex(nagent.pos))
        end
    end
    return result
end

"""
    get_topology_neighbors(agent::ComplianceAgent, model, ::ScaleFreeTopology) -> Vector{CartesianIndex}
"""
function get_topology_neighbors(agent::ComplianceAgent, model, ::ScaleFreeTopology)
    meta = abmproperties(model)[:metadata]
    isnothing(meta.network) && return CartesianIndex{2}[]
    agent_idx = agent.id
    agent_idx > nv(meta.network) && return CartesianIndex{2}[]
    graph_neighbors = collect(neighbors(meta.network, agent_idx))
    result = CartesianIndex{2}[]
    for nid in graph_neighbors
        if hasid(model, nid)
            nagent = getindex(model, nid)
            push!(result, CartesianIndex(nagent.pos))
        end
    end
    return result
end

"""
    get_neighborhood_positions(agent::ComplianceAgent, model, ::VonNeumannNeighborhood) -> Vector{CartesianIndex}
"""
function get_neighborhood_positions(agent::ComplianceAgent, model, ::VonNeumannNeighborhood)
    config = abmproperties(model)[:config]
    pos = CartesianIndex(agent.pos)
    directions = [CartesianIndex(0, 1), CartesianIndex(0, -1),
                  CartesianIndex(1, 0), CartesianIndex(-1, 0)]
    result = CartesianIndex{2}[]
    for d in directions
        new_pos = pos + d
        if !config.torus
            w, h = config.grid_size
            if 1 <= new_pos[1] <= w && 1 <= new_pos[2] <= h
                push!(result, new_pos)
            end
        else
            wrapped_x = mod1(new_pos[1], w)
            wrapped_y = mod1(new_pos[2], h)
            push!(result, CartesianIndex(wrapped_x, wrapped_y))
        end
    end
    return result
end

"""
    get_neighborhood_positions(agent::ComplianceAgent, model, ::MooreNeighborhood) -> Vector{CartesianIndex}
"""
function get_neighborhood_positions(agent::ComplianceAgent, model, ::MooreNeighborhood)
    config = abmproperties(model)[:config]
    pos = CartesianIndex(agent.pos)
    directions = [
        CartesianIndex(-1, -1), CartesianIndex(-1, 0), CartesianIndex(-1, 1),
        CartesianIndex(0, -1),                       CartesianIndex(0, 1),
        CartesianIndex(1, -1),  CartesianIndex(1, 0),  CartesianIndex(1, 1),
    ]
    result = CartesianIndex{2}[]
    for d in directions
        new_pos = pos + d
        if !config.torus
            w, h = config.grid_size
            if 1 <= new_pos[1] <= w && 1 <= new_pos[2] <= h
                push!(result, new_pos)
            end
        else
            wrapped_x = mod1(new_pos[1], w)
            wrapped_y = mod1(new_pos[2], h)
            push!(result, CartesianIndex(wrapped_x, wrapped_y))
        end
    end
    return result
end

"""
    filter_neighbors(positions::Vector{CartesianIndex}, agent::ComplianceAgent, model, config::ModelConfig) -> Vector{CartesianIndex}
"""
function filter_neighbors(positions::Vector{CartesianIndex{2}}, agent::ComplianceAgent, model, config::ModelConfig)
    meta = abmproperties(model)[:metadata]
    if isnothing(meta.barrier_grid)
        return positions
    end
    return filter(pos -> meta.barrier_grid[pos[1], pos[2]], positions)
end

"""
    get_valid_neighbors(agent::ComplianceAgent, model, config::ModelConfig) -> Vector{ComplianceAgent}
"""
function get_valid_neighbors(agent::ComplianceAgent, model, config::ModelConfig)
    raw_positions = get_topology_neighbors(agent, model, config.topology)
    valid_positions = filter_neighbors(raw_positions, agent, model, config)
    result = ComplianceAgent[]
    for pos in valid_positions
        nagent = agent_by_pos(model, pos)
        if !isnothing(nagent)
            push!(result, nagent)
        end
    end
    return result
end

"""
    agent_by_pos(model, pos) -> Union{ComplianceAgent, Nothing}
"""
function agent_by_pos(model, pos)
    agents_at = collect(agents_in_position(Tuple(pos), model))
    if isempty(agents_at)
        return nothing
    end
    return first(agents_at)
end
