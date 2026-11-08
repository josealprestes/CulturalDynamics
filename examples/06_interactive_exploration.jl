# Example 06: Interactive Exploration (F5)
#
# Ups the interactive Makie app when a backend is available
# (`using GLMakie` for desktop, WGLMakie/JSServe for notebooks);
# otherwise runs the same scenario headless and prints the summary.
#
# Backend NAO e dependencia do pacote. Instale num ambiente de trabalho:
#   julia -e 'using Pkg; Pkg.activate("viz"); Pkg.develop(path="."); Pkg.add("GLMakie")'
# Uso desktop:  julia --project=viz -e 'using GLMakie, CulturalDynamics; include("examples/06_interactive_exploration.jl")'
# Uso headless: julia --project=. examples/06_interactive_exploration.jl

using CulturalDynamics

# Create configuration
config = ModelConfig(
    grid_size = (31, 31),
    F = 5,
    Q = 3,
    bounded_confidence_threshold = 0.3,
)

println("Interactive exploration:")
println("  Grid size: $(config.grid_size)")
println("  F: $(config.F), Q: $(config.Q)")
println("  ε: $(config.bounded_confidence_threshold)")

# A Makie backend (GLMakie/WGLMakie) must be loaded by the caller:
# these examples only *build* figures, backends *render* them.
have_backend = isdefined(Main, :GLMakie) || isdefined(Main, :WGLMakie) || isdefined(Main, :CairoMakie)

if have_backend && isdefined(CulturalDynamics, :interactive_app)
    println("\nControls:")
    println("  - Play/Pause button: Start/stop simulation")
    println("  - Step button: Advance one step")
    println("  - Reset button: Reset simulation")
    println("  - Speed slider: Control simulation speed")
    println("  - F/Q/ε sliders: Adjust parameters")
    fig = interactive_app(config)
    display(fig)
else
    println("\nSem backend Makie carregado (container headless) — rodada equivalente sem figura:")
    println("  desktop: julia -e 'using Pkg; Pkg.activate("viz"); Pkg.develop(path="."); Pkg.add("GLMakie")' && julia --project=viz -e 'using GLMakie, CulturalDynamics; include(\"examples/06_interactive_exploration.jl\")'")
    model = build_model(ModelConfig(grid_size=(31, 31), F=5, Q=3, seed_culture=true,
        seed=1, bounded_confidence_threshold=0.3, max_steps=300, recording_interval=300))
    step!(model, 300)
    rd = count_regions(model)
    println("  n_regions=$(rd[:n_regions]) largest_share=$(round(rd[:largest_share], digits=3)) " *
            "partial=$(round(partial_compliance(model), digits=3))")
end
