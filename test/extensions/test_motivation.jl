@testset "Vroom's Motivation" begin
    config = ModelConfig(grid_size=(5, 5), F=3, Q=3)
    
    # Test VroomExpectancy strategy exists
    @test VroomExpectancy() isa MotivationStrategy
    
    # Test FixedCompliance strategy exists
    @test FixedCompliance() isa MotivationStrategy
    
    # Test that motivation can be configured
    vroom_config = @set config.motivation = VroomExpectancy()
    @test vroom_config.motivation isa VroomExpectancy
    
    fixed_config = @set config.motivation = FixedCompliance()
    @test fixed_config.motivation isa FixedCompliance
end
