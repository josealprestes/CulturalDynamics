@testset "Barriers" begin
    config = ModelConfig(grid_size=(5, 5), F=3, Q=3)
    
    # Test NoBarriers strategy exists
    @test NoBarriers() isa BarrierStrategy
    
    # Test RandomBarriers strategy exists
    @test RandomBarriers() isa BarrierStrategy
    
    # Test ManualBarriers strategy exists
    @test ManualBarriers() isa BarrierStrategy
    
    # Test that barriers can be configured
    no_barrier_config = @set config.barriers = NoBarriers()
    @test no_barrier_config.barriers isa NoBarriers
    
    random_config = @set config.barriers = RandomBarriers()
    @test random_config.barriers isa RandomBarriers
    
    manual_config = @set config.barriers = ManualBarriers()
    @test manual_config.barriers isa ManualBarriers
    
    # Test barrier density parameter
    @test hasfield(ModelConfig, :barrier_density)
    density_config = @set config.barrier_density = 0.1
    @test density_config.barrier_density == 0.1
    
    # Test barrier mask parameter
    @test hasfield(ModelConfig, :barrier_mask)
    mask = ones(Bool, 5, 5)
    mask[1, 1] = false
    mask_config = @set config.barrier_mask = mask
    @test mask_config.barrier_mask == mask
end

@testset "RandomBarriers integration (A1)" begin
    cfg = ModelConfig(grid_size=(8, 8), F=3, Q=3,
        barriers=RandomBarriers(), barrier_density=0.2, seed=7)
    m = build_model(cfg)
    grid = abmproperties(m)[:metadata].barrier_grid
    @test !isnothing(grid)
    @test size(grid) == (8, 8)
    m2 = build_model(cfg)
    grid2 = abmproperties(m2)[:metadata].barrier_grid
    @test grid == grid2
    m3 = build_model(@set cfg.seed = 8)
    grid3 = abmproperties(m3)[:metadata].barrier_grid
    @test grid != grid3
    acc = findall(grid)
    @test !isempty(acc)
    seen = falses(8, 8)
    queue = [first(acc)]
    seen[first(acc)] = true
    while !isempty(queue)
        pos = popfirst!(queue)
        for d in [CartesianIndex(0, 1), CartesianIndex(0, -1),
                  CartesianIndex(1, 0), CartesianIndex(-1, 0)]
            np = pos + d
            if 1 <= np[1] <= 8 && 1 <= np[2] <= 8 && !seen[np] && grid[np]
                seen[np] = true
                push!(queue, np)
            end
        end
    end
    @test all(seen[a] for a in acc)
end

@testset "ManualBarriers integration (A1)" begin
    mask = trues(5, 5)
    mask[3, 3] = false
    cfg = ModelConfig(grid_size=(5, 5), F=3, Q=3,
        barriers=ManualBarriers(), barrier_mask=mask, seed=1)
    m = build_model(cfg)
    meta = abmproperties(m)[:metadata]
    @test meta.barrier_grid == mask
    @test isnothing(agent_by_pos(m, (3, 3)))
end
