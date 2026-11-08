# CulturalDynamics — BENCHMARKS (SOTA)

> **Objetivo:** provar que o simulador é **correto, rápido e reprodutível** — em linguagem que convence tanto banca de engenharia quanto diretor não-técnico.

## 1. Métricas (duas leituras)

| Métrica técnica | O que significa para não-engenheiro |
|---|---|
| `ms/step`, `steps/sec` | "Quanto tempo para simular minha organização?" |
| `n_regions`, `largest_share` | "Quantos blocos culturais se formam? Quão concentrado?" |
| `compliance_rate` (global e por dimensão `d`) | "Quanta gente adere de fato à norma?" |
| `steps_to_absorption` (legacy: passos executados), `absorbed_at` (v1.3.1+: passo da absorção, `nothing` se não absorveu), `is_absorbed` | "Quanto tempo até estabilizar?" |
| `effective/attempted_interactions` | "Quantas conversas viram mudança?" |

## 2. Protocolo comum (reprodutibilidade = auditoria)

- RNG: `Xoshiro(seed)` via `abmrng(model)`; `seed = base_seed + rep`.
- Cultura inicial: `seed_culture=true` (uniforme 1..Q) — documentado vs `false` (todos 1).
- Padrão 31×31 961 agentes, `torus=false`, Von Neumann, `WeightedContagion+FixedCompliance`, `mutation=NoMutation`.
- Saída: `results/*.csv` + `results/*.json` com `seed`, `F`, `Q`, `ε`, `topology` por linha.
- CI: `Pkg.test` verde antes de qualquer rodada.

## 3. Três benchmarks

### B1 — Interno: scaling (`benchmark/scaling.jl`)

Varre `N ∈ {31²,61²,101²,201²}` × `F∈{5,10}` × `Q∈{3,5}` × `ε∈{0,0.3}` × `topology∈{Grid,SmallWorld}`.
Exporta `benchmark/results/scaling.csv` com cols `N,F,Q,epsilon,topology,ms_per_step,steps_per_sec`.
Figura: **Fig.8 `ms/step × N`** (log-log) — mostra linearidade e custo de 4.000 agentes.

### B2 — Cruzado: Julia×Python (`benchmark/mesa_axelrod.py`)

Port do mesmo Axelrod-HK para **Mesa** (canônico em 1.2.1; shim compatível com a API 3.x), mesmo `F=5 Q=3 ε=0.3 31×31 300 passos`.
Padrão de alinhamento **distribucional** (Axtell): n≥60/braço, ±1,5% nas médias de `n_regions`.
A tolerância de 5% single-seed foi **aposentada** — era ruído inter-rep, não gate.
Referência: `JuliaDynamics/ABMFrameworksComparison` (CI automático Agents/Mesa/NetLogo/MASON).

### B3 — Correção: Castellano Q_c (`benchmark/castellano.jl` ou nota)

Replica diagrama de fase Castellano et al. 2000: `F=5` fixo, `Q∈{2..20}`, `ε=0`, 20 reps, `n_regions vs Q` e transição crítica `Q_c`.
Valida `count_regions` Union-Find contra NetLogo BehaviorSpace.

## 4. SOTA — tabela de referência

| # | Projeto | Ling. | ★ ~2025 | Lição |
|---|---|---|---|---|
| 1 | Agents.jl | Julia | ~800 | SOTA Julia, 10× Mesa (JOSS Datseris 2021) — nossa base |
| 2 | Mesa 3.5 (4 em dev) | Python | ~2.2k | Baseline Python para B2 |
| 3 | NetLogo | Scala/DSL | — | Axelrod didático; valida B3 |
| 4 | lluis-cr/axelrod-cultural-dissemination | Python | — | Pedagogia sem testes/redes |
| 5 | GAMA/MASON/Repast4Py | Java/Python | 150-550 | GIS/HPC; gap de paralelismo |
| 6 | HK/Deffuant isolados | variado | 10-80 | Nenhum une Axelrod+HK+rede+dual+RL |
| 7 | Sharpanskykh & Haest 2016 | — | — | Pilar compliance; ninguém operacionaliza completo |

Citações: Axelrod 1997; Castellano et al. 2000; Hegselmann & Krause 2002; Sharpanskykh & Haest 2016; Watts & Strogatz 1998; Barabási & Albert 1999; Datseris et al. 2021.

## 5. Critérios de aceite

- `benchmark/scaling.jl` → `benchmark/results/scaling.csv` existe com 4×N e `ms_per_step`.
- `benchmark/mesa_axelrod.py` → `n_regions` dentro de ±1,5% em n=60/braço (distribucional); single-seed 5% não é critério.
- Fig.8 publicada em `results/figures/` e citada no ROADMAP.
- `Pkg.test` verde após cada benchmark.

## 6. Riscos

- Mesa diverge por RNG — por isso o critério é distribucional (n≥60), não pointwise.
- 201×201 40k agentes lento — B1 roda 31²/61² por padrão; 201² só spot-check.

## 7. Run-log F2 (2026-09-17, Julia 1.12.7)

Máquina: Intel i5-3230M (2 núcleos/4 threads), 7 GB RAM, Linux.
Todos os tempos (ms/step, steps/sec, durações) são específicos dela —
para comparar, normalize pelo seu hardware ou reexecute os scripts.

Env: `Project.toml` com `Distributions = "=0.25.120"` (pin exato — Agents 6.2.10
usa `@check_args` estilo antigo em `spaces/walk.jl:361`, que não pré-compila em
Distributions ≥0.25.121). `Pkg.test` 102/102 verde antes das rodadas (histórico 2026-09-17; atual 268/268).
Mesa 1.2.1 com shim de compat 1.x/3.0 em `benchmark/mesa_axelrod.py`.

### B1-lean (`benchmark/scaling_lean.jl` → `benchmark/results/scaling.csv`, Fig.8)

Subconjunto doc-sanctioned (full com `@benchmark` em 201² é inviável em sessão):
N ∈ {21²,31²,61²,101²} F=5 Q=3 ε=0.3 Grid + spots. Min de 3× `@elapsed step!(model,100)`.

| N | config | ms/step | steps/sec |
|---|---|---|---|
| 441 | 21² Grid F5Q3 ε0.3 | 10.82 | 92 |
| 961 | 31² Grid F5Q3 ε0.3 | 32.49 | 31 |
| 3721 | 61² Grid F5Q3 ε0.3 | 144.23 | 7 |
| 10201 | 101² Grid F5Q3 ε0.3 | 370.65 | 3 |
| 961 | 31² SmallWorld F5Q3 ε0.3 | 14.31 | 70 |
| 961 | 31² Grid F10Q3 ε0.3 | 28.15 | 36 |

Leitura: custo ≈ linear em N (2.2×N→3×t; 3.9×N→4.4×t; 2.7×N→2.6×t).
Planta de ~4k agentes ≈ 7 steps/s; 10k ≈ 3 steps/s (300 passos ≈ 2 min).
Spot SmallWorld 2.3× mais rápido que Grid no mesmo N (hipótese: absorção mais
rápida encurta `check_absorption!`; a confirmar).

### B2 (Julia×Mesa, F=5 Q=3 ε=0.3 31×31 300 passos)

Single-seed (seed 42): Julia-fastest 356 vs Mesa 329 (8,2 %, fora dos 5 %).
Hipótese "scheduler explica o gap" foi TESTADA e REFUTADA em multi-seed
(`run_B2_multiseed.jl`, `results/B2_multiseed.csv`):

| lado (n=20) | n_regions |
|---|---|
| Julia-fastest | 348,0 ±29,7 |
| Mesa-RandomActivation | 339,4 ±25,0 |
| Julia-randomly | 331,9 ±32,2 |

MW fastest×Mesa p=0,21 (r=0,23); randomly×Mesa p=0,45; schedulers entre si
p=0,09 — nenhum par se distingue em n=20. Ampliado para n=60
(`run_B2_topup.jl` + 40 seeds Mesa, `B2_mesa.csv` completo):

| lado (n=60) | n_regions |
|---|---|
| Julia-fastest | 340,6 ±28,2 |
| Mesa-RandomActivation | 336,3 ±24,6 |
| Julia-randomly | 337,8 ±29,6 |

MW fastest×Mesa p=0,18 (r=0,14, Δ=+4,3); randomly×Mesa p=0,55 (Δ=+1,4);
schedulers p=0,65 (Δ=+2,9). **Concordância dentro de ±5 regiões (~1,5 %),
nenhum artefato detectado em n=60** — validação cruzada genuína (as
estimativas coincidem, não só "falham em rejeitar"). O efeito scheduler do
piloto n=5 era ruído de amostra pequena. (`B2_mesa.csv` regenerado
nativamente via `MESA_SEED`, bit-idêntico à transcrição anterior.)

### B3 (`benchmark/castellano.jl` → `benchmark/results/castellano.csv`, 190 sims)

F=5, Q 2..20, ε=0, 21×21, 300 passos, 10 reps/Q:

| Q | n_regions (média±dp) | largest_share |
|---|---|---|
| 2 | 100.9±16.2 | 0.13 |
| 3 | 149.6±17.6 | 0.08 |
| 4 | 168.4±10.4 | 0.06 |
| 5+ | platô 169–206 | 0.04–0.07 |

Veredito: **crossover em Q≈3–4, sem Qc agudo**. `count_regions` responde
monotonicamente e satura (validação parcial), mas 300 passos param longe da
absorção (nem Q=2 monocultura) — o protocolo Castellano exige rodar até
absorção. Follow-up: Q 2..8 até absorção com `is_absorbed` exportado.

## 8. Run-log F1 (2026-09-17, 540 sims)

Driver `run_study_C_threaded.jl` (Threads.@threads, 4 threads, seeds `1+rep`
idênticas ao sweep serial; determinismo validado serial==threaded).
`recording_interval=500`: export usa só estado vivo → `summary` bit-idêntico,
4.7× mais rápido (32.8s→7.0s/sim em F5Q10ε0.6).
Saída `results/study_C_sweep.{csv,json}` (540 linhas, 18×30, seeds 2..31) +
`study_C_agg.csv` (IC95) + `study_C_timeseries.csv` (1500 registros) +
Fig.1–5. Stats §study_C_results.md: KW p<1e-23, post-hoc Bonferroni pleno,
Spearman tie-corrected = scipy.
