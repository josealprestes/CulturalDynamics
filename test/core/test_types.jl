@testset "ComplianceAgent" begin
    agent = ComplianceAgent(; id=1, pos=(1, 1), features=zeros(Int, 10),
        motivation=0.5, openness=0.7, expressiveness=0.6,
        system2_weight=1.0, team_id=1, social_rank=0.5)
    @test agent.id == 1
    @test agent.pos == (1, 1)
    @test length(agent.features) == 10
    @test agent.motivation == 0.5
    @test agent.openness == 0.7
    @test agent.expressiveness == 0.6
    @test agent.system2_weight == 1.0
    @test agent.team_id == 1
    @test agent.social_rank == 0.5
end

@testset "ModelConfig" begin
    config = ModelConfig()
    @test config.grid_size == (61, 61)
    @test config.F == 10
    @test config.Q == 3
    @test config.bounded_confidence_threshold == 0.3
    @test config.textbook == true
    
    custom = ModelConfig(grid_size=(10, 10), F=5, Q=5)
    @test custom.grid_size == (10, 10)
    @test custom.F == 5
    @test custom.Q == 5
end

@testset "Strategy Types" begin
    @test VonNeumannNeighborhood() isa NeighborhoodStrategy
    @test MooreNeighborhood() isa NeighborhoodStrategy
    @test NoMutation() isa MutationStrategy
    @test PoissonMutation() isa MutationStrategy
    @test NoBarriers() isa BarrierStrategy
    @test RandomBarriers() isa BarrierStrategy
    @test ManualBarriers() isa BarrierStrategy
    @test GridTopology() isa TopologyStrategy
    @test SmallWorldTopology() isa TopologyStrategy
    @test ScaleFreeTopology() isa TopologyStrategy
    @test FixedCompliance() isa MotivationStrategy
    @test VroomExpectancy() isa MotivationStrategy
    @test NoContagion() isa ContagionStrategy
    @test WeightedContagion() isa ContagionStrategy
end
