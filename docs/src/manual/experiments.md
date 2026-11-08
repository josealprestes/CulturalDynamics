# Experiments

## Single Run

```julia
result = single_run(config)
result[:summary]  # Final metrics
result[:history]  # Time series
```

## Batch Run

```julia
results = batch_run(config; n_reps=30)
```

## Parameter Sweep

```julia
results = parameter_sweep(
    config;
    F_values = [5, 10, 15],
    Q_values = [3, 5, 10],
    epsilon_values = [0.0, 0.3, 0.6],
    n_replications = 30,
)
```

## Sensitivity Analysis

```julia
sensitivity = sensitivity_analysis(
    config;
    param_ranges = Dict(
        :F => (5.0, 15.0),
        :Q => (3.0, 10.0),
        :bounded_confidence_threshold => (0.0, 1.0),
    ),
    n_samples = 1024,
)
```

## Export Results

```julia
# CSV
export_csv(results, "results.csv")

# JSON
export_json(results, "results.json")

# JLD2 (Julia native)
export_jld2(results, "results.jld2")
```

## Validation

1. Run F=5, Q=15 on 61×61, compare with NetLogo
2. Test ε=0 (standard Axelrod) vs ε=1 (complete fragmentation)
3. Verify convergence as grid size increases
