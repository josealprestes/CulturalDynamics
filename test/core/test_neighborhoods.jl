@testset "Von Neumann Neighborhood" begin
    config = ModelConfig(grid_size=(5, 5), neighborhood=VonNeumannNeighborhood())
    model = build_model(config)
    
    # Test center agent has 4 neighbors
    center_agent = agent_by_pos(model, (3, 3))
    if !isnothing(center_agent)
        neighbors = get_valid_neighbors(center_agent, model, config)
        @test length(neighbors) == 4
    end
end

@testset "Moore Neighborhood" begin
    config = ModelConfig(grid_size=(5, 5), neighborhood=MooreNeighborhood())
    model = build_model(config)
    
    # Test center agent has 8 neighbors
    center_agent = agent_by_pos(model, (3, 3))
    if !isnothing(center_agent)
        neighbors = get_valid_neighbors(center_agent, model, config)
        @test length(neighbors) == 8
    end
end

@testset "Edge Cases" begin
    config = ModelConfig(grid_size=(3, 3), neighborhood=VonNeumannNeighborhood())
    model = build_model(config)
    
    # Corner agent should have 2 neighbors
    corner_agent = agent_by_pos(model, (1, 1))
    if !isnothing(corner_agent)
        neighbors = get_valid_neighbors(corner_agent, model, config)
        @test length(neighbors) == 2
    end
    
    # Edge agent should have 3 neighbors
    edge_agent = agent_by_pos(model, (1, 2))
    if !isnothing(edge_agent)
        neighbors = get_valid_neighbors(edge_agent, model, config)
        @test length(neighbors) == 3
    end
end
