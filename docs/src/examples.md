# Examples

## 01: Textbook Mode (Axelrod Baseline)

Demonstrates the basic Axelrod model without extensions.

```julia
using CulturalDynamics

config = ModelConfig(
    grid_size = (61, 61),
    F = 5,
    Q = 15,
    textbook = true,
)

model = build_model(config)
step!(model, 1000)

compliance_rate(model)
count_regions(model)
```

## 02: Basic Compliance

Demonstrates compliance simulation with bounded confidence.

```julia
config = ModelConfig(
    grid_size = (31, 31),
    F = 10,
    Q = 3,
    bounded_confidence_threshold = 0.3,
    seed_culture = true,
)

model = build_model(config)
step!(model, 500)
```

## 03: Team Dynamics

Demonstrates how team composition affects compliance.

```julia
config = ModelConfig(
    grid_size = (31, 31),
    F = 5,
    Q = 3,
    n_teams = 5,
    social_contagion = WeightedContagion(),
)

model = build_model(config)
step!(model, 300)
```

## 04: Management Intervention

Demonstrates how management intervention affects compliance.

```julia
config = ModelConfig(
    grid_size = (31, 31),
    F = 5,
    Q = 3,
    intervention = DirectedTraining(),
    training_rate = 0.02,
)

model = build_model(config)
step!(model, 500)
```

## 05: RL Training

Demonstrates RL agent training on the compliance environment.

```julia
config = ModelConfig(grid_size=(11, 11), F=3, Q=3, max_steps=150)
rl = train_rl(config; n_episodes=25)   # Q-learning tabular do gestor
rl[:policy]                            # ação por estado (1..6)
```

## 06: Interactive Exploration

Demonstrates the interactive Makie application.

```julia
config = ModelConfig(
    grid_size = (31, 31),
    F = 5,
    Q = 3,
    bounded_confidence_threshold = 0.3,
)

fig = interactive_app(config)
display(fig)
```
