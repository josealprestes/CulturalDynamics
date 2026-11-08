# src/core/model.jl — construction + step loop (CoreTypes partition)
#
# Loaded via `include` at the end of types.jl (same module/namespace).
# NOTE: `maybe_mutate!`, `apply_social_contagion!` and
# `build_network_overlay!` are owned by the core (defined below); the
# same-named functions in extensions/{mutation,social_contagion,networks}.jl
# are dead duplicates pending removal (ROADMAP_v4 A2) — the core wins.

"""
    compliance_agent_step!(agent::ComplianceAgent, model)
"""
function maybe_mutate!(agent::ComplianceAgent, model, config::ModelConfig)
    config.mutation isa NoMutation && return nothing
    Q = config.Q; rate = config.mutation_rate
    for i in 1:config.F
        if rand(abmrng(model)) < rate
            agent.features[i] = rand(abmrng(model), 1:Q)
        end
    end
    return nothing
end

function apply_social_contagion!(agent::ComplianceAgent, partner::ComplianceAgent, model, config::ModelConfig)
    config.social_contagion isa NoContagion && return nothing
    γ = agent.openness * partner.expressiveness
    influence = γ * (partner.motivation - agent.motivation)
    agent.motivation = clamp(agent.motivation + influence * 0.1, 0.0, 1.0)
    return nothing
end

"""
    apply_audit!(agent::ComplianceAgent, model, config::ModelConfig)

Norm enforcement audit (P3 — partial deontic remedy for KILL-1): with prob
`monitoring_rate` per agent-step, the agent is audited against the explicit
norm (all traits at Q). Compliant → small motivation reward. Non-compliant →
complies one level w.p. = motivation (the motivated comply when watched),
else punished (motivation −= `sanction_cost`: crowding-out, Frey).

This adds what Axelrod lacks minimally: an explicit norm, monitoring, a
costly choice, and a sanction. Still no roles/policy-text (open).
`NoEnforcement` (or rate ≤ 0) is a no-op — existing runs are unaffected.
"""
function apply_audit!(agent::ComplianceAgent, model, config::ModelConfig)
    config.enforcement isa NoEnforcement && return nothing
    config.monitoring_rate <= 0 && return nothing
    rng = abmrng(model)
    rand(rng) < config.monitoring_rate || return nothing
    below = findall(f -> f < config.Q, agent.features)
    if isempty(below)
        agent.motivation = clamp(agent.motivation + 0.05, 0.0, 1.0)
    elseif rand(rng) < agent.motivation
        agent.features[rand(rng, below)] += 1
    else
        agent.motivation = clamp(agent.motivation - config.sanction_cost, 0.0, 1.0)
    end
    return nothing
end

function compliance_agent_step!(agent::ComplianceAgent, model)
    config = abmproperties(model)[:config]
    meta = abmproperties(model)[:metadata]
    meta.attempted_interactions += 1
    apply_audit!(agent, model, config)
    apply_fatigue!(agent, model, config)
    if config.motivation isa VroomExpectancy
        agent.motivation = clamp(agent.openness * 0.8 + (1 - agent.openness) * 0.2 * (agent.social_rank * 0.6 + 0.4) * agent.motivation, 0.0, 1.0)
    end
    partner = select_partner(agent, model, config)
    isnothing(partner) && return
    similarity = compute_similarity(agent, partner, config)
    similarity < config.bounded_confidence_threshold && return
    p_copy = copy_probability(agent, similarity, config)
    rand(abmrng(model)) > p_copy && return
    differing = findall(i -> agent.features[i] != partner.features[i], 1:config.F)
    isempty(differing) && return
    trait_idx = rand(abmrng(model), differing)
    agent.features[trait_idx] = partner.features[trait_idx]
    meta.effective_interactions += 1
    apply_social_contagion!(agent, partner, model, config)
    maybe_mutate!(agent, model, config)
    ζ = 0.015; α_min = 0.1
    agent.system2_weight = clamp(agent.system2_weight + ζ * (α_min - agent.system2_weight), 0.0, 1.0)
    return nothing
end

"""
    copy_probability(agent::ComplianceAgent, similarity::Float64, config::ModelConfig) -> Float64

Effective per-interaction copy probability.

- `textbook=true` (default): pure Axelrod, returns `similarity × copy_scale`
  (`copy_scale=1.0` default → bit-identical baselines).
- `textbook=false`: Sharpanskykh coupling (all factors ≤ overweight):
  openness scales adoption (receptiveness), Vroom motivation scales it
  further (motivated agents comply more), and the dual-process weight
  modulates it (habitual `system2_weight→0.1` conforms up to 1.25×,
  deliberate `system2_weight=1` resists at 0.75×). Result clamped to [0,1].

Note: under `FixedCompliance`, motivation is exogenous, so
`WeightedContagion` only drifts the reported `mean_motivation` without
affecting copies — the contagion channel acts through Vroom motivation.

The `copy_scale` knob (default 1.0, inert) exists for mechanism
identification: a uniform rate reduction is the null control against
which heterogeneous couplings (Vroom/openness/dual) must prove content.
"""
function copy_probability(agent::ComplianceAgent, similarity::Float64, config::ModelConfig)
    config.textbook && return similarity * config.copy_scale
    p = similarity * (0.25 + 0.75 * agent.openness)
    if config.motivation isa VroomExpectancy
        p *= (0.25 + 0.75 * agent.motivation)
    end
    p *= clamp(1.25 - 0.5 * agent.system2_weight, 0.5, 1.25)
    return clamp(p, 0.0, 1.0)
end

"""
    apply_intervention!(model, config::ModelConfig)

Management training (F4): each agent is trained w.p. `training_rate` per
model step; training nudges one random below-Q trait one level toward Q
and resets the agent to System 2 (new procedure → deliberate mode,
Sharpanskykh & Haest 2016).

This is the model's only directional force: lateral copying conserves mean
adherence (F2.5), so only intervention moves `partial_compliance`.
`NoIntervention` (or rate ≤ 0) is a no-op — existing runs are unaffected.
"""
function apply_intervention!(model, config::ModelConfig)
    config.intervention isa NoIntervention && return nothing
    config.training_rate <= 0 && return nothing
    Q = config.Q
    rng = abmrng(model)
    for agent in allagents(model)
        rand(rng) < config.training_rate || continue
        below = findall(f -> f < Q, agent.features)
        isempty(below) && continue
        agent.features[rand(rng, below)] += 1
        agent.system2_weight = 1.0
    end
    return nothing
end

"""
    apply_fatigue!(agent::ComplianceAgent, model, config::ModelConfig)

Work fatigue (V2): per agent-step, motivation decays by `fatigue_rate` and
w.p. `fatigue_rate` one random trait above 1 decrements (cutting corners
when tired — Dai et al. 2014, −8.5pp/shift). Inert at rate 0.
"""
function apply_fatigue!(agent::ComplianceAgent, model, config::ModelConfig)
    config.fatigue_rate <= 0 && return nothing
    agent.motivation = clamp(agent.motivation - config.fatigue_rate, 0.0, 1.0)
    rng = abmrng(model)
    if rand(rng) < config.fatigue_rate
        above = findall(f -> f > 1, agent.features)
        isempty(above) || (agent.features[rand(rng, above)] -= 1)
    end
    return nothing
end

"""
    apply_shift_reset!(model, config::ModelConfig)

Shift boundary (V2): every `shift_length` model-steps, motivation resets to
baseline (rest) and each agent is replaced w.p. `turnover_rate` (handover:
features re-randomized — principled Klemm noise). Inert when disabled.
"""
function apply_shift_reset!(model, config::ModelConfig)
    config.shift_length <= 0 && return nothing
    meta = abmproperties(model)[:metadata]
    meta.step_count % config.shift_length != 0 && return nothing
    base_mot = config.motivation isa FixedCompliance ? 1.0 : 0.5
    rng = abmrng(model)
    for agent in allagents(model)
        agent.motivation = base_mot
        if rand(rng) < config.turnover_rate
            agent.features = rand(rng, 1:config.Q, config.F)
        end
    end
    return nothing
end

"""
    compliance_model_step!(model)
"""
function compliance_model_step!(model)
    config = abmproperties(model)[:config]
    meta = abmproperties(model)[:metadata]
    meta.step_count += 1
    apply_intervention!(model, config)
    apply_shift_reset!(model, config)
    if meta.step_count % config.recording_interval == 0
        record_metrics!(model)
    end
    check_absorption!(model)
    return nothing
end

"""
    build_network_overlay!(model, config::ModelConfig)
"""
function build_network_overlay!(model, config::ModelConfig)
    meta = abmproperties(model)[:metadata]
    n = nagents(model)
    n < 2 && return nothing
    if config.topology isa SmallWorldTopology
        k = get(config.network_params, :k, 6)
        β = get(config.network_params, :beta, 0.3)
        meta.network = watts_strogatz(n, k, β; rng=abmrng(model))
    elseif config.topology isa ScaleFreeTopology
        m = get(config.network_params, :m, 3)
        meta.network = barabasi_albert(n, m; rng=abmrng(model))
    else
        meta.network = SimpleGraph(n)
    end
    return nothing
end

"""
    generate_barriers(rng::AbstractRNG, grid_size::Tuple{Int,Int}, density::Float64) -> Matrix{Bool}

Generate a random barrier grid (true = accessible, false = barrier).

Connectivity is ensured by flood-filling from the first accessible cell.
Deterministic for a given `rng` state; callers must pass `abmrng(model)`.
"""
function generate_barriers(rng::AbstractRNG, grid_size::Tuple{Int,Int}, density::Float64)
    w, h = grid_size
    mask = Matrix{Bool}(rand(rng, w, h) .> density)
    ensure_connectivity!(mask)
    return mask
end

"""
    ensure_connectivity!(mask::AbstractMatrix{Bool})

Ensure all accessible cells are connected via flood-fill from the first
accessible cell. Unreachable cells become barriers (false).
"""
function ensure_connectivity!(mask::AbstractMatrix{Bool})
    w, h = size(mask)
    start = nothing
    for x in 1:w, y in 1:h
        if mask[x, y]
            start = CartesianIndex(x, y)
            break
        end
    end
    isnothing(start) && return nothing
    visited = falses(w, h)
    queue = [start]
    visited[start[1], start[2]] = true
    while !isempty(queue)
        pos = popfirst!(queue)
        for d in [CartesianIndex(0, 1), CartesianIndex(0, -1),
                  CartesianIndex(1, 0), CartesianIndex(-1, 0)]
            new_pos = pos + d
            nx, ny = new_pos[1], new_pos[2]
            if 1 <= nx <= w && 1 <= ny <= h && !visited[nx, ny] && mask[nx, ny]
                visited[nx, ny] = true
                push!(queue, CartesianIndex(nx, ny))
            end
        end
    end
    for x in 1:w, y in 1:h
        if mask[x, y] && !visited[x, y]
            mask[x, y] = false
        end
    end
    return nothing
end

"""
    build_model(config::ModelConfig) -> ABM
"""
function build_model(config::ModelConfig)
    space = GridSpace(config.grid_size; periodic=config.torus)
    meta = ModelMetadata()
    sched = config.scheduler == :fastest ? Agents.Schedulers.fastest :
        config.scheduler == :randomly ? Agents.Schedulers.Randomly() :
        error("scheduler desconhecido: $(config.scheduler) (use :fastest ou :randomly)")
    model = ABM(
        ComplianceAgent, space;
        agent_step! = compliance_agent_step!,
        model_step! = compliance_model_step!,
        scheduler = sched,
        properties = Dict{Symbol,Any}(
            :config => config,
            :metadata => meta,
        ),
        rng = Xoshiro(config.seed),
        warn = false,
    )
    rng = abmrng(model)
    if config.barriers isa RandomBarriers && config.barrier_density > 0
        meta.barrier_grid = generate_barriers(rng, config.grid_size, config.barrier_density)
    elseif config.barriers isa ManualBarriers && !isnothing(config.barrier_mask)
        meta.barrier_grid = config.barrier_mask
    end
    F, Q = config.F, config.Q
    for pos in positions(model)
        if !isnothing(meta.barrier_grid) && !meta.barrier_grid[pos...]
            continue
        end
        features = initial_features(F, Q, config, rng)
        motivation = config.motivation isa FixedCompliance ? 1.0 : 0.5
        openness = rand(rng)
        expressiveness = rand(rng)
        system2_weight = 1.0
        team_id = rand(rng, 1:config.n_teams)
        social_rank = rand(rng)
        add_agent!(pos, ComplianceAgent, model;
            features = features,
            motivation = motivation,
            openness = openness,
            expressiveness = expressiveness,
            system2_weight = system2_weight,
            team_id = team_id,
            social_rank = social_rank,
        )
    end
    if !(config.topology isa GridTopology)
        build_network_overlay!(model, config)
    end
    return model
end

"""
    initial_features(F::Int, Q::Int, config::ModelConfig) -> Vector{Int}
"""
function initial_features(F::Int, Q::Int, config::ModelConfig, rng::AbstractRNG)
    if config.seed_culture
        return rand(rng, 1:Q, F)
    else
        return ones(Int, F)
    end
end
