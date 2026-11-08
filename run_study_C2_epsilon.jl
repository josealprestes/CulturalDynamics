using CulturalDynamics
F, Q = 5, 3
eps_vals = 0.0:0.05:1.0
n_reps = 15
grid = (21,21)
steps = 300
println("Study C2 phase transition F=$F Q=$Q $(grid) $(steps) eps=$(collect(eps_vals)) reps=$n_reps => $(length(eps_vals)*n_reps) sims")
mkpath("results")
open("results/study_C2_sweep.csv","w") do io
    println(io, "epsilon,replication,final_n_regions,final_largest_share,final_compliance,steps_to_absorption,is_absorbed")
    for eps in eps_vals
        for rep in 1:n_reps
            c = ModelConfig(grid_size=grid, F=F, Q=Q, seed_culture=true, seed=rep, bounded_confidence_threshold=eps, max_steps=steps, recording_interval=steps)
            r = single_run(c)
            s = r[:summary]
            println(io, "$(eps),$(rep),$(s[:final_n_regions]),$(s[:final_largest_share]),$(s[:final_compliance_rate]),$(s[:steps_to_absorption]),$(s[:is_absorbed])")
        end
        println("done eps=$eps")
    end
end
println("Done -> results/study_C2_sweep.csv")
