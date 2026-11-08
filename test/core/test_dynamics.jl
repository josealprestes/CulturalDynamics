@testset "Interaction Dynamics" begin
    config = ModelConfig(grid_size=(3, 3), F=2, Q=2, seed_culture=false)
    model = build_model(config)

    agent = first(allagents(model))
    partner = select_partner(agent, model, config)

    if !isnothing(partner)
        similarity = compute_similarity(agent, partner, config)
        @test 0.0 <= similarity <= 1.0
        @test compute_similarity(agent, agent, config) == 1.0
    else
        @test true
    end
end
