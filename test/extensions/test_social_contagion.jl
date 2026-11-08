@testset "Social Contagion" begin
    config = ModelConfig(grid_size=(5, 5), F=3, Q=3)
    
    # Test WeightedContagion strategy exists
    @test WeightedContagion() isa ContagionStrategy
    
    # Test NoContagion strategy exists
    @test NoContagion() isa ContagionStrategy
    
    # Test that social contagion can be configured
    weighted_config = @set config.social_contagion = WeightedContagion()
    @test weighted_config.social_contagion isa WeightedContagion
    
    no_contagion_config = @set config.social_contagion = NoContagion()
    @test no_contagion_config.social_contagion isa NoContagion
end
