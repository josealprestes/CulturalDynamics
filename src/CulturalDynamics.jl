module CulturalDynamics

using Agents
using Random: Xoshiro
using Graphs
using Statistics: mean
using StructArrays
using Accessors: @set
using JLD2
using CSV
using DataFrames
using JSON3

# ── Core ──
include("core/types.jl")

using .CoreTypes

# ── Extensions ──
include("extensions/mutation.jl")
include("extensions/barriers.jl")
include("extensions/networks.jl")
include("extensions/bounded_confidence.jl")
include("extensions/social_contagion.jl")
include("extensions/motivation.jl")
include("extensions/dual_process.jl")

# ── Visualization ──
include("visualization/colors.jl")
include("visualization/grid_plot.jl")
include("visualization/metrics_plot.jl")
include("visualization/interactive.jl")
include("visualization/web_dashboard.jl")

# ── Experiments ──
include("experiments/batch.jl")
include("experiments/sweeps.jl")
include("experiments/export.jl")
include("experiments/sensitivity.jl")
include("experiments/calibration.jl")

# ── RL ──
include("rl/types.jl")
include("rl/environment.jl")
include("rl/spaces.jl")
include("rl/rewards.jl")
include("rl/training.jl")

# ── Public API ──
export ModelConfig, ComplianceAgent, build_model
export NeighborhoodStrategy, VonNeumannNeighborhood, MooreNeighborhood
export MutationStrategy, NoMutation, PoissonMutation
export BarrierStrategy, NoBarriers, RandomBarriers, ManualBarriers
export TopologyStrategy, GridTopology, SmallWorldTopology, ScaleFreeTopology
export MotivationStrategy, FixedCompliance, VroomExpectancy
export ContagionStrategy, NoContagion, WeightedContagion
export InterventionStrategy, NoIntervention, DirectedTraining
export EnforcementStrategy, NoEnforcement, NormSanctions
export apply_intervention!, apply_audit!
export apply_fatigue!, apply_shift_reset!
export ModelMetadata
export step!, run!, nagents, allagents, abmruns
export count_regions, compliance_rate, agent_by_pos
export partial_compliance, copy_probability
export get_valid_neighbors, get_neighborhood_positions, get_topology_neighbors
export select_partner, compute_similarity, compute_overlap
export record_metrics!, check_absorption!
export mean_motivation, mean_openness, system1_fraction
export single_run, batch_run, parameter_sweep, sensitivity_analysis
export assign_roles!, evaluate_moments, calibrate
export export_csv, export_json, export_jld2
export train_rl, RLConfig, ComplianceEnv, compute_reward, state_space, action_space
export discretize_state, TRAINING_RATES
export plot_grid
export plot_metrics, interactive_app, dashboard
export find!, union!

end # module CulturalDynamics
