@testset "Tabular Q-learning" begin
    @test CulturalDynamics.discretize_state(0.3, 0.05) == 1
    @test CulturalDynamics.discretize_state(0.3, 0.5) == 2
    @test CulturalDynamics.discretize_state(0.7, 0.05) == 3
    @test CulturalDynamics.discretize_state(0.9, 0.5) == 6
    @test length(CulturalDynamics.TRAINING_RATES) == 3

    # Env smoke (pós-fix abmproperties)
    cfg = ModelConfig(grid_size=(6, 6), F=3, Q=3, seed_culture=true, seed=1, max_steps=10)
    env = ComplianceEnv(cfg)
    @test length(CulturalDynamics.state(env)) == 3 * 9 + 2
    @test isfinite(compute_reward(env, 1))
    @test state_space(env).dims == 3 * 9 + 2
    @test action_space(env).n == 9

    # train_rl mínimo: chaves legado + estrutura
    tiny = ModelConfig(grid_size=(5, 5), F=3, Q=3, seed_culture=true, seed=1, max_steps=10)
    r = train_rl(tiny; n_episodes=2)
    @test haskey(r, :final_compliance)
    @test haskey(r, :Q_table) && size(r[:Q_table]) == (6, 3)
    @test length(r[:policy]) == 6 && all(1 .<= r[:policy] .<= 3)
    @test all(isfinite, r[:Q_table])
    # Determinismo
    r2 = train_rl(tiny; n_episodes=2)
    @test r[:Q_table] == r2[:Q_table]

    # Aprende de verdade: 25 eps em 11×11, aderência final ~baseline
    # sempre-treinar (0.85) e política de shutoff por custo
    med = ModelConfig(grid_size=(11, 11), F=3, Q=3, seed_culture=true, seed=1, max_steps=150)
    rl = train_rl(med; n_episodes=25)
    @test rl[:final_partial] > 0.7
    @test rl[:policy][1] != 1  # estado (aderência baixa, fragmentado) → treinar
end
