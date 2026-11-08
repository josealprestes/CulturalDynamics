using CulturalDynamics
using Agents: allagents, abmproperties

seed = length(ARGS) >= 1 ? parse(Int, ARGS[1]) : 42
steps = length(ARGS) >= 2 ? parse(Int, ARGS[2]) : 300

config = ModelConfig(grid_size=(31, 31), F=5, Q=3, seed=seed)
model = build_model(config)

println("CulturalDynamics — Simulação Axelrod")
println("  Grid:     $(config.grid_size[1])×$(config.grid_size[2]) = $(config.grid_size[1]^2) agentes")
println("  F=$(config.F)  Q=$(config.Q)  ε=$(config.bounded_confidence_threshold)  mut=$(config.mutation_rate)  seed=$seed")
println("  Passos:   $steps")
println()

step!(model, steps)

region_data = count_regions(model)
meta = abmproperties(model)[:metadata]

println("Resultados:")
println("  Agentes:            $(length(allagents(model)))")
println("  Compliance rate:    $(round(compliance_rate(model) * 100, digits=1))%")
println("  Regiões:            $(region_data[:n_regions])  (maior=$(region_data[:largest_region]), média=$(round(region_data[:mean_region_size], digits=1)))")
println("  Maior região share: $(round(region_data[:largest_share]*100, digits=1))%")
println("  Motivação média:    $(round(mean_motivation(model), digits=3))")
println("  System 1:           $(round(system1_fraction(model) * 100, digits=1))%")
println("  Interações:         $(meta.effective_interactions)/$(meta.attempted_interactions) efetivas")
println("  Absorvido:          $(meta.is_absorbed)  (step=$(meta.step_count))")
