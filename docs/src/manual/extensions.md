# Extensions

CulturalDynamics.jl provides composable extensions via strategy types.

## Neighborhood Strategies

- `VonNeumannNeighborhood`: 4 neighbors (N, S, E, W)
- `MooreNeighborhood`: 8 neighbors (includes diagonals)

## Mutation Strategies

- `NoMutation`: No random trait changes
- `PoissonMutation`: Random changes at configured rate

## Barrier Strategies

- `NoBarriers`: No spatial barriers
- `RandomBarriers`: Random placement based on density (deterministic per
  seed via `abmrng(model)`; built with `generate_barriers` and connected
  with `ensure_connectivity!`).
- `ManualBarriers`: User-provided barrier mask (`barrier_mask`; constructed
  and respected, integration-tested).

## Topology Strategies

- `GridTopology`: Standard 2D grid
- `SmallWorldTopology`: Watts-Strogatz small world
- `ScaleFreeTopology`: Barabasi-Albert scale-free

## Motivation Strategies

- `FixedCompliance`: Motivation always 1.0
- `VroomExpectancy`: Vroom's expectancy theory

## Contagion Strategies

- `NoContagion`: No social influence weighting
- `WeightedContagion`: Influence weighted by expressiveness/openness

## Composing Extensions

All non-default mechanisms are **inert at 0** — existing runs are unaffected.

```julia
config = ModelConfig(
    neighborhood = MooreNeighborhood(),
    mutation = PoissonMutation(),
    mutation_rate = 0.05,
    barriers = NoBarriers(),
    barrier_density = 0.0,
    topology = SmallWorldTopology(),
    motivation = VroomExpectancy(),
    social_contagion = WeightedContagion(),
    bounded_confidence_threshold = 0.3,
    intervention = NoIntervention(),  # or DirectedTraining() + training_rate
    enforcement = NoEnforcement(),    # or NormSanctions() + monitoring_rate
)
```
