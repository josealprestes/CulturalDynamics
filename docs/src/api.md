# API Reference

## Core Types

```@docs
ComplianceAgent
ModelConfig
ModelMetadata
```

## Model Construction

```@docs
build_model
```

## Metrics

```@docs
compliance_rate
partial_compliance
count_regions
mean_motivation
mean_openness
system1_fraction
record_metrics!
```

## Neighborhoods

```@docs
select_partner
get_valid_neighbors
```

## Intervention & Enforcement (F2.5/P3)

```@docs
copy_probability
apply_intervention!
apply_audit!
```

## Experiments

```@docs
single_run
batch_run
parameter_sweep
sensitivity_analysis
```

## Export

```@docs
export_csv
export_json
export_jld2
```

## Extensions

```@docs
CulturalDynamics.CoreTypes.generate_barriers
CulturalDynamics.CoreTypes.ensure_connectivity!
CulturalDynamics.check_bounded_confidence
CulturalDynamics.update_system2_weight!
CulturalDynamics.reset_system2!
CulturalDynamics.compute_motivation
```

## RL Environment & Training

```@docs
ComplianceEnv
RLConfig
TRAINING_RATES
state_space
action_space
CulturalDynamics.state
discretize_state
compute_reward
train_rl
```

## Visualization

```@docs
plot_grid
plot_metrics
interactive_app
dashboard
CulturalDynamics.compliance_to_color
CulturalDynamics.features_to_color
```

## Internals (CoreTypes)

```@docs
CulturalDynamics.CoreTypes.compliance_model_step!
CulturalDynamics.CoreTypes.agent_by_pos
CulturalDynamics.CoreTypes.compute_similarity
CulturalDynamics.CoreTypes.initial_features
CulturalDynamics.CoreTypes.filter_neighbors
CulturalDynamics.CoreTypes.get_neighborhood_positions
CulturalDynamics.CoreTypes.get_topology_neighbors
CulturalDynamics.CoreTypes.maybe_mutate!
CulturalDynamics.CoreTypes.build_network_overlay!
CulturalDynamics.CoreTypes.apply_fatigue!
CulturalDynamics.CoreTypes.apply_shift_reset!
```

## Calibration

```@docs
calibrate
evaluate_moments
assign_roles!
```
