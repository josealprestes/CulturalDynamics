# Example 04: Management Intervention
# This example demonstrates how management intervention affects compliance.

using CulturalDynamics

# Create configuration with high mutation rate (management pressure)
config = ModelConfig(
    grid_size = (31, 31),
    F = 5,
    Q = 3,
    mutation = PoissonMutation(),
    mutation_rate = 0.05,  # 5% chance of random change per feature per step
    social_contagion = WeightedContagion(),
)

# Build model
model = build_model(config)

println("Management intervention model built:")
println("  Grid size: $(config.grid_size)")
println("  Agents: $(nagents(model))")
println("  Mutation rate: $(config.mutation_rate)")

# Run simulation
println("\nRunning simulation...")
step!(model, 500)

# Analyze results
region_data = count_regions(model)
println("\nResults after 500 steps:")
println("  Compliance rate: $(compliance_rate(model))")
println("  Number of regions: $(region_data[:n_regions])")
println("  Mean motivation: $(mean_motivation(model))")
