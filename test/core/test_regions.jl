@testset "Region Counting" begin
    config = ModelConfig(grid_size=(5, 5), F=2, Q=2, seed_culture=false)
    model = build_model(config)
    
    # Test that region counting works
    region_data = count_regions(model)
    @test haskey(region_data, :n_regions)
    @test haskey(region_data, :largest_region)
    @test haskey(region_data, :largest_share)
    @test haskey(region_data, :mean_region_size)
    @test haskey(region_data, :region_sizes)
    
    # All values should be positive
    @test region_data[:n_regions] > 0
    @test region_data[:largest_region] > 0
    @test region_data[:largest_share] > 0.0
    @test region_data[:mean_region_size] > 0.0
end
