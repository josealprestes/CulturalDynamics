@testset "Dual Process" begin
    config = ModelConfig(grid_size=(5, 5), F=3, Q=3)
    
    # Test that dual process parameters are in config
    @test hasfield(ModelConfig, :bounded_confidence_threshold)
    
    # Test that system2_weight can be initialized
    agent = ComplianceAgent(; id=1, pos=(1, 1), features=zeros(Int, 3),
        motivation=0.5, openness=0.7, expressiveness=0.6,
        system2_weight=1.0, team_id=1, social_rank=0.5)
    @test agent.system2_weight == 1.0
    
    # Test that system2_weight can decrease
    agent.system2_weight = 0.5
    @test agent.system2_weight == 0.5
end
