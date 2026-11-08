module CoreTypes

using Agents
using Graphs: SimpleGraph, nv, neighbors, watts_strogatz, barabasi_albert
using Random: Xoshiro, AbstractRNG
using Statistics: mean

# ── Exports ──
export ComplianceAgent, ModelConfig, ModelMetadata
export NeighborhoodStrategy, VonNeumannNeighborhood, MooreNeighborhood
export MutationStrategy, NoMutation, PoissonMutation
export BarrierStrategy, NoBarriers, RandomBarriers, ManualBarriers
export TopologyStrategy, GridTopology, SmallWorldTopology, ScaleFreeTopology
export MotivationStrategy, FixedCompliance, VroomExpectancy
export ContagionStrategy, NoContagion, WeightedContagion
export InterventionStrategy, NoIntervention, DirectedTraining
export EnforcementStrategy, NoEnforcement, NormSanctions
export select_partner, get_valid_neighbors, agent_by_pos
export compliance_agent_step!, compliance_model_step!, compute_similarity
export copy_probability, partial_compliance
export apply_intervention!
export apply_audit!
export apply_fatigue!, apply_shift_reset!
export build_model, initial_features, build_network_overlay!
export generate_barriers, ensure_connectivity!
export count_regions, find!, union!
export compliance_rate, mean_motivation, mean_openness, system1_fraction
export record_metrics!, check_absorption!

# ──────────────────────────────────────────────
# Strategy Abstract Types
# ──────────────────────────────────────────────

abstract type NeighborhoodStrategy end
abstract type MutationStrategy end
abstract type BarrierStrategy end
abstract type TopologyStrategy end
abstract type MotivationStrategy end
abstract type ContagionStrategy end
abstract type InterventionStrategy end
abstract type EnforcementStrategy end

# ──────────────────────────────────────────────
# Neighborhood Strategies
# ──────────────────────────────────────────────

struct VonNeumannNeighborhood <: NeighborhoodStrategy end
struct MooreNeighborhood <: NeighborhoodStrategy end

# ──────────────────────────────────────────────
# Mutation Strategies
# ──────────────────────────────────────────────

struct NoMutation <: MutationStrategy end
struct PoissonMutation <: MutationStrategy end

# ──────────────────────────────────────────────
# Barrier Strategies
# ──────────────────────────────────────────────

struct NoBarriers <: BarrierStrategy end
struct RandomBarriers <: BarrierStrategy end
struct ManualBarriers <: BarrierStrategy end

# ──────────────────────────────────────────────
# Topology Strategies
# ──────────────────────────────────────────────

struct GridTopology <: TopologyStrategy end
struct SmallWorldTopology <: TopologyStrategy end
struct ScaleFreeTopology <: TopologyStrategy end

# ──────────────────────────────────────────────
# Motivation Strategies
# ──────────────────────────────────────────────

struct FixedCompliance <: MotivationStrategy end
struct VroomExpectancy <: MotivationStrategy end

# ──────────────────────────────────────────────
# Contagion Strategies
# ──────────────────────────────────────────────

struct NoContagion <: ContagionStrategy end
struct WeightedContagion <: ContagionStrategy end

# ──────────────────────────────────────────────
# Intervention Strategies (F4: directional force)
# ──────────────────────────────────────────────

struct NoIntervention <: InterventionStrategy end
struct DirectedTraining <: InterventionStrategy end

# ──────────────────────────────────────────────
# Enforcement Strategies (red-team P3: deontic element)
# ──────────────────────────────────────────────

struct NoEnforcement <: EnforcementStrategy end
struct NormSanctions <: EnforcementStrategy end

# ──────────────────────────────────────────────
# Agent
# ──────────────────────────────────────────────

"""
    ComplianceAgent

A cultural agent on a 2D grid representing an individual in an organization.

# Fields
- `id`: Unique agent identifier
- `pos`: Grid position (x, y)
- `features`: Compliance dimension vector, values 1:Q
- `motivation`: Vroom motivation force [0, 1]
- `openness`: Receptiveness to social influence [0, 1]
- `expressiveness`: Influence on others [0, 1]
- `system2_weight`: 1.0 = fully deliberate, 0.0 = fully habitual
- `team_id`: Team membership identifier
- `social_rank`: Hierarchical position [0, 1]
"""
@agent struct ComplianceAgent(GridAgent{2})
    features::Vector{Int}
    motivation::Float64
    openness::Float64
    expressiveness::Float64
    system2_weight::Float64
    team_id::Int
    social_rank::Float64
end

# ──────────────────────────────────────────────
# Model Configuration
# ──────────────────────────────────────────────

"""
    ModelConfig

Immutable configuration for the compliance simulation model.

All parameters are set at construction time and cannot be modified during simulation.
Use `ModelMetadata` for mutable runtime state.

# Grid Parameters
- `grid_size`: Tuple (width, height) of the grid
- `torus`: Whether the grid wraps around (periodic boundary)

# Culture Parameters
- `F`: Number of compliance dimensions
- `Q`: Number of adherence levels (1=never, 2=sometimes, 3=always)
- `seed_culture`: If true, initialize randomly; if false, all features = 1

# Neighborhood Parameters
- `neighborhood`: Von Neumann (4 neighbors) or Moore (8 neighbors)

# Extension Parameters
- `mutation`: Mutation strategy (NoMutation or PoissonMutation)
- `mutation_rate`: Per-feature per-step probability of random change
- `barriers`: Barrier strategy (NoBarriers, RandomBarriers, or ManualBarriers)
- `barrier_density`: Fraction of grid cells that are barriers (for RandomBarriers)
- `barrier_mask`: Boolean matrix of accessible cells (for ManualBarriers)
- `topology`: Grid or network topology
- `network_params`: Parameters for network construction (k, β for SmallWorld, etc.)

# Compliance Parameters
- `motivation`: Motivation strategy (FixedCompliance or VroomExpectancy)
- `social_contagion`: Contagion strategy (NoContagion or WeightedContagion)
- `bounded_confidence_threshold`: ε for Hegselmann-Krause model [0, 1]
- `team_count`: Number of agents per team
- `n_teams`: Number of teams

# Intervention Parameters (F4)
- `intervention`: NoIntervention (inert default) or DirectedTraining
- `training_rate`: Per-agent per-step training probability (directional nudge toward Q)

# Simulation Parameters
- `max_steps`: Maximum number of simulation steps
- `recording_interval`: Steps between metric recordings
- `seed`: Random seed for reproducibility
- `textbook`: If true, enforce Axelrod's original assumptions
"""
Base.@kwdef struct ModelConfig
    # Grid
    grid_size::Tuple{Int,Int} = (61, 61)
    torus::Bool = false

    # Culture
    F::Int = 10
    Q::Int = 3
    seed_culture::Bool = false

    # Neighborhood
    neighborhood::NeighborhoodStrategy = VonNeumannNeighborhood()

    # Extensions
    mutation::MutationStrategy = NoMutation()
    mutation_rate::Float64 = 0.0
    barriers::BarrierStrategy = NoBarriers()
    barrier_density::Float64 = 0.0
    barrier_mask::Union{Nothing,Matrix{Bool}} = nothing
    topology::TopologyStrategy = GridTopology()
    network_params::Dict{Symbol,Any} = Dict{Symbol,Any}()

    # Compliance
    motivation::MotivationStrategy = FixedCompliance()
    social_contagion::ContagionStrategy = WeightedContagion()
    bounded_confidence_threshold::Float64 = 0.3
    # Intervention (F4): default inert — bit-identical to no-intervention runs.
    intervention::InterventionStrategy = NoIntervention()
    training_rate::Float64 = 0.0
    # Enforcement (P3: partial deontic remedy): default inert.
    enforcement::EnforcementStrategy = NoEnforcement()
    monitoring_rate::Float64 = 0.0
    sanction_cost::Float64 = 0.1
    # Fatigue/shift/turnover (V2, hand-hygiene anchor): all inert at 0.
    # fatigue_rate: per agent-step, motivation -= rate AND w.p. rate one
    #   random trait above 1 decrements ("cutting corners when tired").
    #   Directional by design — the calibrated counterpart of Dai's -8.5pp.
    # shift_length: every K model-steps, motivation resets + turnover fires.
    # turnover_rate: per agent at shift boundary, features re-randomized.
    fatigue_rate::Float64 = 0.0
    shift_length::Int = 0
    turnover_rate::Float64 = 0.0
    team_count::Int = 10
    n_teams::Int = 5

    # Simulation
    max_steps::Int = 10_000
    recording_interval::Int = 1
    seed::Int = 42
    textbook::Bool = true
    # Mechanism-identification knob (red-team control): uniform multiplier
    # on the copy probability. Default 1.0 = inert (bit-identical runs).
    copy_scale::Float64 = 1.0
    # Scheduler artifact control (MED-7): :fastest (Agents default, inert)
    # or :randomly. Same seed ⇒ different trajectories across schedulers
    # (activation order is part of the model, Galan & Izquierdo 2009).
    scheduler::Symbol = :fastest
end

# ──────────────────────────────────────────────
# Model Metadata (mutable runtime state)
# ──────────────────────────────────────────────

"""
    ModelMetadata

Mutable metadata for runtime simulation state.

Stored in `abmproperties(model)[:metadata]` and updated during simulation.

# Fields
- `step_count`: Current simulation step
- `is_absorbed`: Whether the model has reached an absorbing state
- `barrier_grid`: Boolean matrix of accessible cells (if barriers enabled)
- `network`: Graph for network topology (if not grid)
- `history`: Time series of recorded metrics
- `effective_interactions`: Number of successful interactions
- `attempted_interactions`: Total number of interaction attempts
"""
Base.@kwdef mutable struct ModelMetadata
    step_count::Int = 0
    is_absorbed::Bool = false
    absorbed_at::Union{Nothing,Int} = nothing
    barrier_grid::Union{Nothing,Matrix{Bool}} = nothing
    network::Union{Nothing,SimpleGraph} = nothing
    history::Vector{Dict{Symbol,Any}} = Dict{Symbol,Any}[]
    effective_interactions::Int = 0
    attempted_interactions::Int = 0
end

# ──────────────────────────────────────────────
# Partitions (F5: one module, split files — same namespace,
# same include order vs extensions, zero behavior change)
# ──────────────────────────────────────────────

include("neighborhoods.jl")
include("regions.jl")
include("model.jl")
include("metrics.jl")

end # module CoreTypes
