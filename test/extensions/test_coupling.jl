@testset "F2.5 metric + coupling" begin
    # ── partial_compliance ──
    cfg = ModelConfig(grid_size=(6, 6), F=3, Q=4, seed_culture=false, seed=1)
    m = build_model(cfg)
    @test partial_compliance(m) == 0.0  # todos em 1 → aderência 0
    for a in allagents(m)
        a.features .= 4
    end
    @test partial_compliance(m) == 1.0
    @test compliance_rate(m) == 1.0
    for a in allagents(m)
        a.features .= 2  # (2-1)/(4-1) = 1/3
    end
    @test partial_compliance(m) ≈ 1 / 3

    cfg_r = ModelConfig(grid_size=(6, 6), F=3, Q=3, seed_culture=true, seed=7)
    m_r = build_model(cfg_r)
    p = partial_compliance(m_r)
    @test 0.0 < p < 1.0
    record_metrics!(m_r)
    @test haskey(abmproperties(m_r)[:metadata].history[end], :partial_compliance)

    # summary/export plumbing
    r = single_run(ModelConfig(grid_size=(5, 5), F=3, Q=3, seed_culture=true, seed=1, max_steps=5))
    @test haskey(r[:summary], :final_partial_compliance)
    @test 0.0 <= r[:summary][:final_partial_compliance] <= 1.0

    # ── copy_probability unit ──
    a_cfg = ModelConfig(grid_size=(5, 5), F=3, Q=3, seed_culture=true, seed=1)
    a_m = build_model(a_cfg)
    ag = first(allagents(a_m))
    ag.openness = 1.0; ag.motivation = 1.0; ag.system2_weight = 0.1
    @test copy_probability(ag, 0.5, a_cfg) == 0.5  # textbook: puro Axelrod
    sc_cfg = ModelConfig(grid_size=(5, 5), F=3, Q=3, seed_culture=true, seed=1, copy_scale=0.5)
    @test copy_probability(ag, 0.5, sc_cfg) == 0.25  # knob uniforme (controle red-team)
    # copy_scale=1.0 é inerte: mesmos summaries que o default
    s_def = single_run(ModelConfig(grid_size=(10, 10), F=4, Q=3, seed_culture=true, seed=9,
        max_steps=50))[:summary]
    s_sc1 = single_run(ModelConfig(grid_size=(10, 10), F=4, Q=3, seed_culture=true, seed=9,
        max_steps=50, copy_scale=1.0))[:summary]
    @test s_def == s_sc1

    # scheduler default (:fastest) é o padrão do Agents: igualdade explícita
    s_fw = single_run(ModelConfig(grid_size=(10, 10), F=4, Q=3, seed_culture=true, seed=9,
        max_steps=50, scheduler=:fastest))[:summary]
    @test s_def == s_fw
    # :randomly executa (mesmo seed, ordem de ativação distinta → diverge)
    s_rd = single_run(ModelConfig(grid_size=(15, 15), F=5, Q=3, seed_culture=true, seed=9,
        max_steps=100, scheduler=:randomly))[:summary]
    s_fa = single_run(ModelConfig(grid_size=(15, 15), F=5, Q=3, seed_culture=true, seed=9,
        max_steps=100, scheduler=:fastest))[:summary]
    @test haskey(s_rd, :final_n_regions)
    @test s_rd != s_fa
    nt_cfg = ModelConfig(grid_size=(5, 5), F=3, Q=3, seed_culture=true, seed=1, textbook=false)
    @test copy_probability(ag, 0.5, nt_cfg) ≈ min(1.0, 0.5 * 1.0 * 1.0 * 1.2)
    ag.openness = 0.0
    @test copy_probability(ag, 0.5, nt_cfg) ≈ 0.5 * 0.25 * 1.0 * 1.2
    vr_cfg = ModelConfig(grid_size=(5, 5), F=3, Q=3, seed_culture=true, seed=1,
        textbook=false, motivation=VroomExpectancy())
    ag.openness = 1.0; ag.motivation = 0.0
    @test copy_probability(ag, 0.8, vr_cfg) ≈ 0.8 * 1.0 * 0.25 * 1.2

    # ── textbook gate: Vroom vs Fixed idênticos em textbook ──
    # (dinâmica; só o reporte de motivação difere por construção)
    base_tb = ModelConfig(grid_size=(10, 10), F=4, Q=3, seed_culture=true, seed=3, max_steps=50)
    s_fixed = single_run(base_tb)[:summary]
    s_vroom = single_run(ModelConfig(grid_size=(10, 10), F=4, Q=3, seed_culture=true, seed=3,
        max_steps=50, motivation=VroomExpectancy()))[:summary]
    dyn_keys = filter(k -> k != :final_mean_motivation, keys(s_fixed))
    @test all(s_fixed[k] == s_vroom[k] for k in dyn_keys)
    @test s_fixed[:final_mean_motivation] != s_vroom[:final_mean_motivation]

    # ── non-textbook diverge do textbook (mesmo seed) ──
    s_nt = single_run(ModelConfig(grid_size=(12, 12), F=4, Q=3, seed_culture=true, seed=5,
        max_steps=100, textbook=false, motivation=VroomExpectancy()))[:summary]
    s_tb = single_run(ModelConfig(grid_size=(12, 12), F=4, Q=3, seed_culture=true, seed=5,
        max_steps=100, motivation=VroomExpectancy()))[:summary]
    @test s_nt != s_tb

    # ── openness modula cópias efetivas ──
    function eff_interactions(openv)
        c = ModelConfig(grid_size=(15, 15), F=5, Q=3, seed_culture=true, seed=11,
            max_steps=150, textbook=false)
        mm = build_model(c)
        for aa in allagents(mm)
            aa.openness = openv
        end
        step!(mm, 150)
        return abmproperties(mm)[:metadata].effective_interactions
    end
    @test eff_interactions(1.0) > eff_interactions(0.0)
end

@testset "A2 core ownership (no dead duplicates)" begin
    @test parentmodule(CulturalDynamics.CoreTypes.maybe_mutate!) === CulturalDynamics.CoreTypes
    @test parentmodule(CulturalDynamics.CoreTypes.apply_social_contagion!) === CulturalDynamics.CoreTypes
    @test parentmodule(CulturalDynamics.CoreTypes.build_network_overlay!) === CulturalDynamics.CoreTypes
    @test which(CulturalDynamics.CoreTypes.maybe_mutate!,
        Tuple{ComplianceAgent,Any,ModelConfig}).module === CulturalDynamics.CoreTypes
    cfg = ModelConfig(grid_size=(10, 10), F=4, Q=3, seed_culture=true, seed=9, max_steps=50)
    @test single_run(cfg)[:summary] == single_run(cfg)[:summary]
end

@testset "A3 absorbed_at semantics" begin
    cfg = ModelConfig(grid_size=(5, 5), F=3, Q=3, seed_culture=true, seed=1, max_steps=5)
    s = single_run(cfg)[:summary]
    @test haskey(s, :absorbed_at)
    @test s[:steps_to_absorption] == 5
    m = build_model(ModelConfig(grid_size=(3, 3), F=2, Q=2, seed_culture=false, seed=1))
    abmproperties(m)[:metadata].absorbed_at = nothing
    check_absorption!(m)
    meta = abmproperties(m)[:metadata]
    @test meta.is_absorbed == true
    @test meta.absorbed_at == meta.step_count
end
