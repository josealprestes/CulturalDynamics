# TRACE — rastreabilidade claims → código → testes/checks (F8, 2026-10-13)

> claims sem linha nesta tabela não entram no paper. Status: `ok` (checado),
> `soft` (evidência existe, sem check automático), `open` (limite declarado).

| # | Claim | Código | Teste / check | Status |
|---|---|---|---|---|
| T1 | Sweep F×Q×ε 540 sims, ranking preservado | `run_study_C_threaded.jl`, `src/experiments/sweeps.jl` | `verificação número-a-CSV (privada)` células+KW+Spearman; G5 seeds | ok |
| T2 | Quantização ε em 1/F (bit-idêntica) | `src/core/model.jl` (gate ε) | `test_properties.jl` (0.1≡0.2, 0.3≡0.4, 0.2≠0.3); G9 | ok |
| T3 | Determinismo mesma seed | `Xoshiro` + `abmrng` em `src/core/model.jl` | `test_properties.jl`; G9 | ok |
| T4 | Conservação E[aderência] sob cópia lateral | `copy_probability` (textbook) | `test_properties.jl` (média ensemble ±0.05); checker n=978 | ok |
| T5 | Invariantes de região (soma= N, share∈(0,1]) | `src/core/regions.jl` Union-Find | `test_properties.jl`; suite regions | ok |
| T6 | Vroom +21–26% fragmentação | `src/extensions/motivation.jl` | `study_D_sweep.csv` + checker; controle `copy_scale` | ok |
| T7 | Contágio n.s. (n=60, decorativo) | `src/extensions/social_contagion.jl` | `redteam_round3.csv` p=0.32 (erratum 2026-10-13 corrige p=0.72); declarado | ok |
| T8 | Enforcement dose-resposta; punição morta | `apply_audit!` em `src/core/model.jl` | `enforcement_sweep.csv`; round 5 p=0.44–1.0 | ok |
| T9 | Treino curva côncava, teto 0.99 | `apply_intervention!` | `validation_V3.csv` + checker | ok |
| T10 | Papéis P5c sugestivo; P5d estrutural p=0.0009 | `assign_roles!` | `P5_round2.csv` + checker; Holm rebaixa P5c | ok |
| T11 | RL shutoff: 0.858 vs 0.840 (p=0.68), 80% custo | `src/rl/training.jl` | `rl_heldout.csv` + bootstrap; sem heurística (limite) | ok |
| T12 | B2 distribucional ±1.5% (n=60) | `benchmark/mesa_axelrod.py` | `B2_*.csv` + checker; sem claim velocidade | ok |
| T13 | B1 forma ≈linear ms/step (hardware-independent) | `benchmark/scaling_lean.jl` | checker B1 = 4 checks de forma (monotonic+slope+spots); absolutos são ilustração reference-machine | ok |
| T14 | B3 crossover Q≈3–4, sem Qc agudo a 300p | `benchmark/castellano.jl` | checker B3 PASS local | ok |
| T15 | Transiente Klemm (absorção→monocultura) | `PoissonMutation` + `check_absorption!` | `klemm_spot.csv`; horizonte declarado | ok |
| T16 | Calibração faixa 0.003–0.006, RMSE 0.004 | `run_calibrate_V2.jl`, fadiga | `calibration_V2.csv` + checker | ok |
| T17 | Escala 31² n=50 / 61² dentro da banda | `run_scale_transfer.jl`, `run_scale31_topup.jl` | checker contagem+seeds (round 15) | ok |
| T18 | R1: social desnecessário p/ médias, essencial p/ estrutura (7×) | `run_ablation_structure.jl` (textbook 15² F3Q3, seeds 1..10) | `ablation_structure.csv` 29.0 vs 210.8, MW p=0.0002 | ok |
| T19 | Sensibilidade: ε domina (η²=0.79, ranking grosseiro) | `run_sensitivity_F4.jl` | E1 (eps~0.79) + E-rank (eps>F>mut>Q) no checker; adherence MANUAL-by-design (var ~5e-5, draws contínuos não arquivados) | ok |
| T20 | Nulos: contágio MWU p=0.32 e punição p≥0.40 recomputados (N1/N2); dual segue soft | `redteam_round3/4/5.csv` | contágio corrigido por erratum 2026-10-13 (p=0.72 irrecuperável); dual sem recomputação | ok |
| T21 | ODD 7 seções + parâmetro-fonte | `docs/research/ODD.md` | G7 esqueleto; prosa MANUAL | ok |
| T22 | Contrato web `/simulate` aninhado | `src/web_server.jl` + `web/index.html` | G6 estático; visual MANUAL | ok |
| T23 | Suite sem testes vacuos | `test/` | G1 + waivers explícitos | ok |
| T24 | Contagens 74/34/27/268/11pp | docs + paper | G3/G4 | ok |
| T25 | Reprodutibilidade: serial==threaded | `run_study_C.jl` vs threaded | spot documentado; G9 goldens | soft |
| T26 | ABC pilot fadiga: posterior mediana 0.00364 CI [0.0024,0.0065], banda 0.003–0.006 dentro | `scripts/abc_fatigue_pilot.jl` (40 draws×2 reps, 15²) | piloto de método, fora do paper e do corpus | soft |
| T27 | RL pilot F10: policy 15eps perde p/ threshold-0.8 (0.719 vs 0.802, 11²) e degrada em 15² (0.642); confirma escopo PoC | `scripts/rl_baseline_pilot.jl` (6 seeds, 5 braços, 2 grades) | piloto confirma limites declarados; claim NÃO elevada (exit F10: rebaixada por escrito) | soft |
| T28 | UI v2: presets + A/B + auto-run + tabela acessível; contrato vivo verde contra servidor real | `web/index.html`, `scripts/web_contract_live.py` (exit 0) | validação com não-engenheiro segue HUMANO-BLOQUEADA | ok |

Gaps F9 fechados em 2026-10-13/14: T19/T20 recomputados no checker
(contágio MWU p=0.32, punição p≥0.40; aderência-η² e dual seguem MANUAL
declarado); T13 gatado por forma (4 checks hardware-independent);
T25 G9 pleno (goldens na suite). Auditoria adversarial: `auditoria adversarial (material privado)`.
