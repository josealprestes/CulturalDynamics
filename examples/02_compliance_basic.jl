# Example 02: Basic Compliance Scenario
# This example demonstrates compliance simulation with bounded confidence.

using CulturalDynamics

# Create configuration with bounded confidence
config = ModelConfig(
    grid_size = (31, 31),
    F = 10,          # 10 compliance dimensions
    Q = 3,           # 3 adherence levels (never/sometimes/always)
    bounded_confidence_threshold = 0.3,  # ε = 0.3
    seed_culture = true,  # Random initial culture
)

# Build model
model = build_model(config)

println("Compliance model built:")
println("  Grid size: $(config.grid_size)")
println("  Agents: $(nagents(model))")
println("  Bounded confidence ε: $(config.bounded_confidence_threshold)")

# Run simulation
println("\nRunning simulation...")
step!(model, 500)

# Analyze results
region_data = count_regions(model)
println("\nResults after 500 steps:")
println("  Compliance rate: $(compliance_rate(model))")
println("  Number of regions: $(region_data[:n_regions])")
println("  Mean motivation: $(mean_motivation(model))")
println("  System 1 fraction: $(system1_fraction(model))")
