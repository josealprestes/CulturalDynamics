# src/core/regions.jl — cultural regions via Union-Find (CoreTypes partition)
#
# Loaded via `include` at the end of types.jl (same module/namespace).

"""
    count_regions(model) -> Dict{Symbol, Any}
"""
function count_regions(model)
    config = abmproperties(model)[:config]
    agents_list = collect(allagents(model))
    n = length(agents_list)
    n == 0 && return Dict(:n_regions => 0, :largest_region => 0, :largest_share => 0.0,
                          :mean_region_size => 0.0, :region_sizes => Int[])
    parent = collect(1:n)
    rank_vec = zeros(Int, n)
    id_to_idx = Dict(a.id => i for (i, a) in enumerate(agents_list))
    for (i, agent) in enumerate(agents_list)
        for npos in get_topology_neighbors(agent, model, config.topology)
            meta = abmproperties(model)[:metadata]
            if !isnothing(meta.barrier_grid)
                if !meta.barrier_grid[npos[1], npos[2]]
                    continue
                end
            end
            nagent = agent_by_pos(model, npos)
            isnothing(nagent) && continue
            agent.features != nagent.features && continue
            j = get(id_to_idx, nagent.id, nothing)
            isnothing(j) && continue
            union!(parent, rank_vec, i, j)
        end
    end
    component_sizes = Dict{Int,Int}()
    for i in 1:n
        root = find!(parent, i)
        component_sizes[root] = get(component_sizes, root, 0) + 1
    end
    sizes = sort(collect(values(component_sizes)), rev=true)
    largest = isempty(sizes) ? 0 : sizes[1]
    largest_share = n > 0 ? largest / n : 0.0
    mean_size = isempty(sizes) ? 0.0 : sum(sizes) / length(sizes)
    return Dict(:n_regions => length(sizes), :largest_region => largest,
                :largest_share => largest_share, :mean_region_size => mean_size,
                :region_sizes => sizes)
end

function find!(parent::Vector{Int}, i::Int)
    if parent[i] != i
        parent[i] = find!(parent, parent[i])
    end
    return parent[i]
end

function union!(parent::Vector{Int}, rank::Vector{Int}, i::Int, j::Int)
    root_i = find!(parent, i)
    root_j = find!(parent, j)
    root_i == root_j && return nothing
    if rank[root_i] < rank[root_j]
        parent[root_i] = root_j
    elseif rank[root_i] > rank[root_j]
        parent[root_j] = root_i
    else
        parent[root_j] = root_i
        rank[root_i] += 1
    end
    return nothing
end
