@testset "build_model" begin
    config = ModelConfig(grid_size=(5, 5), F=3, Q=3)
    model = build_model(config)

    @test nagents(model) == 25  # 5x5 grid
    @test abmproperties(model)[:config] == config

    agent = first(allagents(model))
    @test length(agent.features) == 3
    @test all(1 <= f <= 3 for f in agent.features)
end
