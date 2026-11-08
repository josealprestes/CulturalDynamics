@testset "Bounded Confidence" begin
    config = ModelConfig(grid_size=(5, 5), F=3, Q=3)
    
    # Test ε=0 (always interact)
    config_no_filter = @set config.bounded_confidence_threshold = 0.0
    @test config_no_filter.bounded_confidence_threshold == 0.0
    
    # Test ε=1 (never interact)
    config_full_filter = @set config.bounded_confidence_threshold = 1.0
    @test config_full_filter.bounded_confidence_threshold == 1.0
    
    # Test intermediate value
    config_partial = @set config.bounded_confidence_threshold = 0.5
    @test config_partial.bounded_confidence_threshold == 0.5
end
