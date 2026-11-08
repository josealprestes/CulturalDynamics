# Property + golden tests (F7). All deterministic: fixed seeds, no wall-clock.
# - Quantization: ε-gates only change at multiples of 1/F (MED-6, bit-identical).
# - Determinism: same seed => identical trajectories (G9 reproduction).
# - Conservation: ensemble-mean adherence conserved under lateral copying
#   (textbook, FixedCompliance, NoIntervention); per-run NOT conserved, so the
#   property is on the 10-seed ensemble mean within ±0.05 (pilot Δ=0.033).
# - GOLDENs: canonical (15,15) F5Q3 300-step values pinned from pilot
#   (scripts/pilot_goldens.jl, since removed); isapprox atol=1e-12 catches any
#   behavioral drift while tolerating nothing else.
@testset "Properties + Goldens" begin
    feats(m) = sort!([[Tuple(a.pos)..., a.features...] for a in allagents(m)])
    runm(; grid=(6, 6), F=5, Q=3, seed=7, eps=0.3, steps=50) = begin
        c = ModelConfig(grid_size=grid, F=F, Q=Q, seed_culture=true, seed=seed,
                        bounded_confidence_threshold=eps, max_steps=steps)
        m = build_model(c)
        step!(m, steps)
        m
    end

    # Quantization (F=5 => gates at multiples of 0.2)
    @test feats(runm(eps=0.1)) == feats(runm(eps=0.2))
    @test feats(runm(eps=0.3)) == feats(runm(eps=0.4))
    @test feats(runm(eps=0.2)) != feats(runm(eps=0.3)) # guard: test discriminates

    # Determinism + seed sensitivity
    @test feats(runm()) == feats(runm())
    @test feats(runm()) != feats(runm(seed=8))

    # Conservation (ensemble mean, 10 fixed seeds, (9,9), 200 steps)
    p0 = Float64[]
    p1 = Float64[]
    for s in 1:10
        c = ModelConfig(grid_size=(9, 9), F=5, Q=3, seed_culture=true, seed=s,
                        max_steps=200)
        m = build_model(c)
        push!(p0, partial_compliance(m))
        step!(m, 200)
        push!(p1, partial_compliance(m))
    end
    @test abs(sum(p1) / length(p1) - sum(p0) / length(p0)) < 0.05

    # GOLDENs (15,15) F5Q3 300 steps
    gold = Dict(1 => (61, 30, 0.5297777777777778),
                2 => (34, 29, 0.5026666666666667),
                3 => (38, 35, 0.45111111111111113))
    for (s, (nreg, largest, part)) in gold
        m = runm(grid=(15, 15), seed=s, steps=300)
        rd = count_regions(m)
        @test rd[:n_regions] == nreg
        @test rd[:largest_region] == largest
        @test isapprox(partial_compliance(m), part; atol=1e-12)
    end

    # Region invariants (exact)
    m = runm()
    rd = count_regions(m)
    @test sum(rd[:region_sizes]) == length(collect(allagents(m)))
    @test rd[:n_regions] >= 1
    @test 0.0 < rd[:largest_share] <= 1.0
end
