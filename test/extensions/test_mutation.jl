@testset "Mutation/Decay" begin
    config = ModelConfig(grid_size=(5, 5), F=3, Q=3)
    
    # Test NoMutation strategy exists
    @test NoMutation() isa MutationStrategy
    
    # Test PoissonMutation strategy exists
    @test PoissonMutation() isa MutationStrategy
    
    # Test that mutation can be configured
    no_mut_config = @set config.mutation = NoMutation()
    @test no_mut_config.mutation isa NoMutation
    
    poisson_config = @set config.mutation = PoissonMutation()
    @test poisson_config.mutation isa PoissonMutation
    
    # Test mutation rate parameter
    @test hasfield(ModelConfig, :mutation_rate)
    rate_config = @set config.mutation_rate = 0.05
    @test rate_config.mutation_rate == 0.05
end
