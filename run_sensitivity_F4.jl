# F4 sensibilidade: η² de F/Q/ε/mutação sobre fragmentação e aderência.
# Uso: julia --project=. run_sensitivity_F4.jl
# Saída: results/sensitivity_F4_{nregions,partial}.csv (via export_csv)
using CulturalDynamics

base = ModelConfig(
    grid_size=(21, 21), F=5, Q=3,
    seed_culture=true, seed=1,
    bounded_confidence_threshold=0.3,
    max_steps=200, recording_interval=200,
)

for target in (:n_regions, :partial_compliance)
    println("Sensibilidade F4: target=$target")
    sa = sensitivity_analysis(base; n_samples=64, target=target)
    println("  eta2:")
    for (k, v) in sa[:eta2]
        println("    $k => $(round(v, digits=3))")
    end
    mkpath("results")
    export_csv(sa[:results], "results/sensitivity_F4_$(target).csv")
end
println("Done -> results/sensitivity_F4_{nregions,partial}.csv")
