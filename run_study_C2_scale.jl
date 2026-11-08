using CulturalDynamics
# Spot-check de escala (stdout apenas; sem CSV — não integra o corpus).
# NOTA: seed=1 fixa (n=1 por célula): ilustrativo, sem inferência; o
# ranking com reps vive no sweep canônico (study_C_sweep.csv, 30 reps).
for (grid,steps) in [((21,21),300),((31,31),500),((61,61),500)]
    c = ModelConfig(grid_size=grid, F=5, Q=3, seed_culture=true, seed=1, bounded_confidence_threshold=0.3, max_steps=steps, recording_interval=steps)
    r = single_run(c)
    s = r[:summary]
    println("$(grid) F5 Q3 eps0.3 $(steps): n=$(s[:final_n_regions]) share=$(round(s[:final_largest_share],digits=3))")
end
for (grid,steps) in [((21,21),300),((31,31),500),((61,61),500)]
    c = ModelConfig(grid_size=grid, F=10, Q=3, seed_culture=true, seed=1, bounded_confidence_threshold=0.6, max_steps=steps, recording_interval=steps)
    r = single_run(c)
    s = r[:summary]
    println("$(grid) F10 Q3 eps0.6 $(steps): n=$(s[:final_n_regions]) share=$(round(s[:final_largest_share],digits=3))")
end
