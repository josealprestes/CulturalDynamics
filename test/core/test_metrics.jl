@testset "Metrics Collection" begin
    config = ModelConfig(grid_size=(5, 5), F=3, Q=3, seed_culture=false)
    model = build_model(config)
    
    # Test compliance rate
    rate = compliance_rate(model)
    @test 0.0 <= rate <= 1.0
    
    # Test metrics recording
    record_metrics!(model)
    history = abmproperties(model)[:metadata].history
    @test length(history) == 1
    
    latest = history[end]
    @test haskey(latest, :step)
    @test haskey(latest, :compliance_rate)
    @test haskey(latest, :n_regions)
    @test haskey(latest, :mean_motivation)
end
