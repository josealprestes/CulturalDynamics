using Statistics: mean

@testset "Fatigue Shift Turnover" begin
    # Inertes por padrão
    base = ModelConfig(grid_size=(10, 10), F=4, Q=3, seed_culture=true, seed=9, max_steps=50)
    s_base = single_run(base)[:summary]
    s_f = single_run(ModelConfig(grid_size=(10, 10), F=4, Q=3, seed_culture=true, seed=9,
        max_steps=50, fatigue_rate=0.0, shift_length=0, turnover_rate=0.0))[:summary]
    @test s_base == s_f

    # Drift direcional: fadiga derruba aderência MÉDIA (reps; single-seed não
    # vale aqui porque a fadiga consome draws extras e dessincroniza o RNG)
    p0 = [single_run(ModelConfig(grid_size=(15, 15), F=5, Q=3, seed_culture=true, seed=100 + r,
        max_steps=200))[:summary][:final_partial_compliance] for r in 1:6]
    p1 = [single_run(ModelConfig(grid_size=(15, 15), F=5, Q=3, seed_culture=true, seed=100 + r,
        max_steps=200, fatigue_rate=0.01))[:summary][:final_partial_compliance]     for r in 1:6]
    @test mean(p1) < mean(p0) - 0.015

    # Reset de turno: motivações voltam à base exatamente na fronteira
    m = build_model(ModelConfig(grid_size=(6, 6), F=3, Q=3, seed_culture=true, seed=2,
        max_steps=50, shift_length=50))
    step!(m, 50)
    @test all(a.motivation == 1.0 for a in allagents(m))

    # Turnover embaralha (rate 1.0 vs 0, mesmo seed → diverge; média ~0.5)
    t0 = single_run(ModelConfig(grid_size=(10, 10), F=4, Q=3, seed_culture=true, seed=4,
        max_steps=60, shift_length=10, turnover_rate=0.0))[:summary]
    t1 = single_run(ModelConfig(grid_size=(10, 10), F=4, Q=3, seed_culture=true, seed=4,
        max_steps=60, shift_length=10, turnover_rate=1.0))[:summary]
    @test t0 != t1
    @test 0.3 < t1[:final_partial_compliance] < 0.7

    # Determinismo
    t2 = single_run(ModelConfig(grid_size=(10, 10), F=4, Q=3, seed_culture=true, seed=4,
        max_steps=60, shift_length=10, turnover_rate=1.0))[:summary]
    @test t1 == t2
end

@testset "Roles Calibration" begin
    m = build_model(ModelConfig(grid_size=(6, 6), F=3, Q=3, seed_culture=true, seed=1, n_teams=2))
    before = Dict(a.id => (a.motivation, a.openness) for a in allagents(m))
    assign_roles!(m, Dict(1 => Dict(:openness => 0.3, :motivation => 0.9)))
    for a in allagents(m)
        if a.team_id == 1
            @test a.openness == 0.3 && a.motivation == 0.9
        else
            @test (a.motivation, a.openness) == before[a.id]
        end
    end

    # evaluate_moments: chaves + declínio mensurável sob fadiga
    cfg = ModelConfig(grid_size=(10, 10), F=4, Q=3, seed_culture=true, seed=5,
        max_steps=100, fatigue_rate=0.005)
    mm = evaluate_moments(cfg)
    @test all(haskey(mm, k) for k in (:init_partial, :final_partial, :decline, :final_n_regions))
    @test mm[:decline] > 0.0
    @test all(isfinite, values(mm))

    # calibrate smoke: barato, determinístico, encontra finito
    cb = ModelConfig(grid_size=(8, 8), F=3, Q=3, seed_culture=true, seed=1, max_steps=30)
    r1 = calibrate(cb; search=Dict(:fatigue_rate => (0.001, 0.01)), n_samples=3, n_reps=1,
        seed_base=50, targets=Dict(:decline => 0.05))
    r2 = calibrate(cb; search=Dict(:fatigue_rate => (0.001, 0.01)), n_samples=3, n_reps=1,
        seed_base=50, targets=Dict(:decline => 0.05))
    @test haskey(r1, :best_params) && haskey(r1[:best_params], :fatigue_rate)
    @test isfinite(r1[:best_loss])
    @test r1[:best_params] == r2[:best_params] && r1[:best_loss] == r2[:best_loss]
end
