using CulturalDynamics
# B3: Validação Castellano Q_c — F=5 fixo, Q 2..20, eps=0, 10 reps por Q
F_fix = 5
Qs = 2:20
n_reps = 10
grid = (21,21)
steps = 300
println("Castellano B3: F=$F_fix Q=$(collect(Qs)) eps=0 21x21 $(steps) x $n_reps reps => $(length(Qs)*n_reps) sims")
mkpath("benchmark/results")
open("benchmark/results/castellano.csv","w") do io
    println(io, "Q,replication,final_n_regions,final_largest_share,final_compliance")
    for Q in Qs
        for rep in 1:n_reps
            c = ModelConfig(grid_size=grid, F=F_fix, Q=Q, seed_culture=true, seed=1000+rep, bounded_confidence_threshold=0.0, max_steps=steps, recording_interval=steps)
            r = single_run(c)
            s = r[:summary]
            println(io, "$(Q),$(rep),$(s[:final_n_regions]),$(s[:final_largest_share]),$(s[:final_compliance_rate])")
        end
        println("done Q=$Q")
    end
end
println("Done -> benchmark/results/castellano.csv")
