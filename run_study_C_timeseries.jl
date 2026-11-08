using CulturalDynamics
using Agents: abmproperties

base = ModelConfig(
    grid_size=(31,31), F=5, Q=3, seed_culture=true, seed=1,
    bounded_confidence_threshold=0.3, max_steps=500, recording_interval=10,
)

eps_values = [0.0, 0.3, 0.6]
n_reps = length(ARGS) >= 1 ? parse(Int, ARGS[1]) : 10

println("Time series: F=5 Q=3 31x31 500 steps interval 10, eps=$(eps_values) reps=$n_reps")

mkpath("results")
open("results/study_C_timeseries.csv","w") do io
    println(io, "epsilon,replication,step,n_regions,largest_share,compliance_rate,mean_region_size")
    for eps in eps_values
        for rep in 1:n_reps
            config = ModelConfig(grid_size=(31,31), F=5, Q=3, seed_culture=true, seed=rep,
                                 bounded_confidence_threshold=eps, max_steps=500, recording_interval=10)
            model = build_model(config)
            step!(model, 500)
            meta = abmproperties(model)[:metadata]
            for rec in meta.history
                println(io, "$(eps),$(rep),$(rec[:step]),$(rec[:n_regions]),$(rec[:largest_share]),$(rec[:compliance_rate]),$(rec[:mean_region_size])")
            end
        end
        println("done eps=$eps")
    end
end
println("Done -> results/study_C_timeseries.csv")
