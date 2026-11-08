# Getting Started

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/josealprestes/CulturalDynamics")

# Pin de compatibilidade (Agents 6.2.10): Distributions =0.25.120.
# Se o resolver travar, rode Pkg.resolve() — nunca Pkg.update() cego.
```

## Basic Usage

```julia
using CulturalDynamics

# 1. Create configuration
config = ModelConfig(
    grid_size = (61, 61),  # 61x61 grid
    F = 10,                # 10 compliance dimensions
    Q = 3,                 # 3 adherence levels
    bounded_confidence_threshold = 0.3,
)

# 2. Build model
model = build_model(config)

# 3. Run simulation
step!(model, 1000)

# 4. Analyze results
compliance_rate(model)      # Overall compliance rate
count_regions(model)         # Region statistics
mean_motivation(model)       # Mean motivation force
```

## Configuration Options

See `ModelConfig` documentation for all available parameters.

## Running Experiments

```julia
# Single run (final summary + history)
result = single_run(config)
result[:summary]  # final metrics

# Batch run with multiple replications
results = batch_run(config; n_reps=30)

# Parameter sweep
sweep_results = parameter_sweep(
    config;
    F_values = [5, 10, 15],
    Q_values = [3, 5, 10],
    epsilon_values = [0.0, 0.3, 0.6],
    n_replications = 30,
)

# Export results (results/ é gitignored)
export_csv(sweep_results, "results/sweep.csv")
```

## Visualization

O backend Makie não é dependência do pacote: `plot_grid`/`interactive_app` **constroem** a figura
e o chamador escolhe quem renderiza. Instale o backend num ambiente de trabalho:

```julia
using Pkg; Pkg.activate("viz"); Pkg.develop(path="."); Pkg.add("GLMakie")
```
e carregue-o antes de usar (rodando com `--project=viz`):

```julia
# Static grid plot
using GLMakie
fig = plot_grid(model)
display(fig)

# Interactive app
fig = interactive_app(config)
display(fig)
```
