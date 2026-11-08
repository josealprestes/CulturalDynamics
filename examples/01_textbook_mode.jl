# Example 01: Textbook Mode (Axelrod Baseline)
# This example demonstrates the basic Axelrod model without extensions.

using CulturalDynamics
using Agents: abmproperties

# Create configuration (textbook mode)
config = ModelConfig(
    grid_size = (61, 61),
    F = 5,           # 5 compliance dimensions
    Q = 15,          # 15 adherence levels
    seed_culture = false,  # All features start at 1
    textbook = true,       # Enforce Axelrod's original assumptions
)

# Build model
model = build_model(config)

println("Model built:")
println("  Grid size: $(config.grid_size)")
println("  Agents: $(nagents(model))")
println("  F: $(config.F), Q: $(config.Q)")

# Run simulation
println("\nRunning simulation...")
step!(model, 1000)

# Analyze results
region_data = count_regions(model)
println("\nResults after 1000 steps:")
println("  Compliance rate: $(compliance_rate(model))")
println("  Number of regions: $(region_data[:n_regions])")
println("  Largest region: $(region_data[:largest_region])")
println("  Mean region size: $(region_data[:mean_region_size])")
println("  Is absorbed: $(abmproperties(model)[:metadata].is_absorbed)")
