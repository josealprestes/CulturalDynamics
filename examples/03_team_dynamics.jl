# Example 03: Team Dynamics
# This example demonstrates how team composition affects compliance.

using CulturalDynamics

# Create configuration with multiple teams
config = ModelConfig(
    grid_size = (31, 31),
    F = 5,
    Q = 3,
    n_teams = 5,
    team_count = 10,  # 10 agents per team
    social_contagion = WeightedContagion(),
)

# Build model
model = build_model(config)

println("Team dynamics model built:")
println("  Grid size: $(config.grid_size)")
println("  Agents: $(nagents(model))")
println("  Teams: $(config.n_teams)")
println("  Agents per team: $(config.team_count)")

# Run simulation
println("\nRunning simulation...")
step!(model, 300)

# Analyze results
region_data = count_regions(model)
println("\nResults after 300 steps:")
println("  Compliance rate: $(compliance_rate(model))")
println("  Number of regions: $(region_data[:n_regions])")
println("  Mean motivation: $(mean_motivation(model))")
