@testset "Enforcement" begin
    # Inerte por padrão
    base = ModelConfig(grid_size=(10, 10), F=4, Q=3, seed_culture=true, seed=9, max_steps=50)
    s_base = single_run(base)[:summary]
    s_no = single_run(ModelConfig(grid_size=(10, 10), F=4, Q=3, seed_culture=true, seed=9,
        max_steps=50, enforcement=NoEnforcement()))[:summary]
    @test s_base == s_no
    s_zero = single_run(ModelConfig(grid_size=(10, 10), F=4, Q=3, seed_culture=true, seed=9,
        max_steps=50, enforcement=NormSanctions(), monitoring_rate=0.0))[:summary]
    @test s_base == s_zero

    # Unidade determinística: motivação 0 → pune sem cumprir; 1.0 → cumpre
    m = build_model(ModelConfig(grid_size=(3, 3), F=2, Q=3, seed_culture=false, seed=1,
        enforcement=NormSanctions(), monitoring_rate=1.0))
    cfg = abmproperties(m)[:config]
    a = first(allagents(m))
    a.motivation = 0.0
    apply_audit!(a, m, cfg)
    @test all(a.features .== 1) && a.motivation == 0.0
    a.motivation = 1.0
    apply_audit!(a, m, cfg)
    @test sum(a.features) == 3 && all(f -> 1 <= f <= 2, a.features)

    # Direcional: monitoramento eleva aderência (mesmo seed)
    c0 = single_run(ModelConfig(grid_size=(15, 15), F=5, Q=3, seed_culture=true, seed=11,
        max_steps=200))[:summary]
    c1 = single_run(ModelConfig(grid_size=(15, 15), F=5, Q=3, seed_culture=true, seed=11,
        max_steps=200, enforcement=NormSanctions(), monitoring_rate=0.05))[:summary]
    @test c1[:final_partial_compliance] > c0[:final_partial_compliance] + 0.1

    # Determinismo
    c2 = single_run(ModelConfig(grid_size=(15, 15), F=5, Q=3, seed_culture=true, seed=11,
        max_steps=200, enforcement=NormSanctions(), monitoring_rate=0.05))[:summary]
    @test c1 == c2
end
