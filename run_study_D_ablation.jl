using CulturalDynamics
conds = [
    (NoContagion(), FixedCompliance(), GridTopology(), Dict{Symbol,Any}(), "NoContagion+Fixed+Grid"),
    (WeightedContagion(), FixedCompliance(), GridTopology(), Dict{Symbol,Any}(), "Weighted+Fixed+Grid"),
    (WeightedContagion(), VroomExpectancy(), GridTopology(), Dict{Symbol,Any}(), "Weighted+Vroom+Grid"),
    (NoContagion(), VroomExpectancy(), GridTopology(), Dict{Symbol,Any}(), "NoContagion+Vroom+Grid"),
    (NoContagion(), FixedCompliance(), SmallWorldTopology(), Dict{Symbol,Any}(:k=>6,:beta=>0.3), "NoContagion+Fixed+SmallWorld"),
    (WeightedContagion(), FixedCompliance(), SmallWorldTopology(), Dict{Symbol,Any}(:k=>6,:beta=>0.3), "Weighted+Fixed+SmallWorld"),
]
n_reps=8
grid=(21,21)
steps=300
# F2.5: textbook=false ativa o acoplamento Sharpanskykh (copy_probability);
# em textbook=true os mecanismos seriam inertes por construção (ver teste
# "textbook gate"). Coluna partial_compliance = métrica primária de adesão.
println("Study D ablation (F2.5, textbook=false) $(length(conds)) conds x $n_reps reps => $(length(conds)*n_reps) sims")
mkpath("results")
open("results/study_D_sweep.csv","w") do io
    println(io, "condition,label,replication,final_n_regions,final_largest_share,final_compliance,final_partial_compliance,final_mean_motivation,steps_to_absorption,is_absorbed")
    for (idx,(contagion,motivation,topology,netparams,label)) in enumerate(conds)
        for rep in 1:n_reps
            c = ModelConfig(grid_size=grid, F=5, Q=3, seed_culture=true, seed=rep,
                            social_contagion=contagion, motivation=motivation,
                            topology=topology, network_params=netparams,
                            bounded_confidence_threshold=0.3, max_steps=steps, recording_interval=steps,
                            textbook=false)
            r = single_run(c)
            s = r[:summary]
            println(io, "$(idx),\"$(label)\",$(rep),$(s[:final_n_regions]),$(s[:final_largest_share]),$(s[:final_compliance_rate]),$(s[:final_partial_compliance]),$(s[:final_mean_motivation]),$(s[:steps_to_absorption]),$(s[:is_absorbed])")
        end
        println("done cond $idx $label")
    end
end
println("Done -> results/study_D_sweep.csv")
