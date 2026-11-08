@testset "Intervention" begin
    # Inerte por padrão: NoIntervention == taxa zero == baseline
    base = ModelConfig(grid_size=(10, 10), F=4, Q=3, seed_culture=true, seed=3, max_steps=50)
    s_base = single_run(base)[:summary]
    s_no = single_run(ModelConfig(grid_size=(10, 10), F=4, Q=3, seed_culture=true, seed=3,
        max_steps=50, intervention=NoIntervention()))[:summary]
    @test s_base == s_no
    s_zero = single_run(ModelConfig(grid_size=(10, 10), F=4, Q=3, seed_culture=true, seed=3,
        max_steps=50, intervention=DirectedTraining(), training_rate=0.0))[:summary]
    @test s_base == s_zero

    # apply_intervention! direto: sobe 1 nível + reseta system2
    m = build_model(ModelConfig(grid_size=(3, 3), F=2, Q=3, seed_culture=false, seed=1,
        intervention=DirectedTraining(), training_rate=1.0))
    for a in allagents(m)
        a.system2_weight = 0.1
    end
    apply_intervention!(m, abmproperties(m)[:config])
    for a in allagents(m)
        # exatamente um traço sobe um nível ([1,1] -> soma F+1), sem teto
        @test sum(a.features) == 3
        @test all(f -> 1 <= f <= 2, a.features)
        @test a.system2_weight == 1.0
    end
    # teto Q respeitado
    for a in allagents(m)
        a.features .= 3
    end
    apply_intervention!(m, abmproperties(m)[:config])
    for a in allagents(m)
        @test all(a.features .== 3)
    end

    # Direcional: treino eleva aderência (mesmo seed)
    c0 = single_run(ModelConfig(grid_size=(15, 15), F=5, Q=3, seed_culture=true, seed=11,
        max_steps=200))[:summary]
    c1 = single_run(ModelConfig(grid_size=(15, 15), F=5, Q=3, seed_culture=true, seed=11,
        max_steps=200, intervention=DirectedTraining(), training_rate=0.05))[:summary]
    @test c1[:final_partial_compliance] > c0[:final_partial_compliance] + 0.2

    # Determinismo
    c2 = single_run(ModelConfig(grid_size=(15, 15), F=5, Q=3, seed_culture=true, seed=11,
        max_steps=200, intervention=DirectedTraining(), training_rate=0.05))[:summary]
    @test c1 == c2
end
