@testset "Network Topology" begin
    config = ModelConfig(grid_size=(5, 5), F=3, Q=3)
    
    # Test GridTopology strategy exists
    @test GridTopology() isa TopologyStrategy
    
    # Test SmallWorldTopology strategy exists
    @test SmallWorldTopology() isa TopologyStrategy
    
    # Test ScaleFreeTopology strategy exists
    @test ScaleFreeTopology() isa TopologyStrategy
    
    # Test that topology can be configured
    grid_config = @set config.topology = GridTopology()
    @test grid_config.topology isa GridTopology
    
    sw_config = @set config.topology = SmallWorldTopology()
    @test sw_config.topology isa SmallWorldTopology
    
    sf_config = @set config.topology = ScaleFreeTopology()
    @test sf_config.topology isa ScaleFreeTopology
    
    # Test network params
    @test hasfield(ModelConfig, :network_params)
    params = Dict{Symbol,Any}(:k => 6, :beta => 0.3)
    params_config = @set config.network_params = params
    @test params_config.network_params == params
end
