# Estudo C — Resultados: Varredura F × Q × ε

> Rascunho de seção de Resultados (pt-br). Números primários: **31×31=961 agentes, 500 passos, 30 reps/célula → 540 sims** (`results/study_C_sweep.csv`, `study_C_agg.csv` com IC95). Figuras em `results/figures/`. Rodada 10-rep/180 sims superseded (git history). Timeseries Fig.5: F=5 Q=3, 10 reps/ε (`study_C_timeseries.csv`, 1500 registros).

## Configuração

Grade 31×31 (961 agentes), `torus=false`, Von Neumann, `seed_culture=true`, `max_steps=500`, `recording_interval=500` (otimização sem efeito no CSV: export usa só estado vivo; validado `summary` idêntico, 4.7× mais rápido), `F∈{5,10}`, `Q∈{3,5,10}`, `ε∈{0.0,0.3,0.6}`, 30 reps/célula, `WeightedContagion`+`FixedCompliance`. RNG via `abmrng(model)`, seeds `base(1)+rep` (2..31). `Pkg.test` 102/102 em Julia 1.12.7 antes da rodada. Driver threaded (`run_study_C_threaded.jl`, 4 threads, determinístico por seed).

## Achados principais (31×31, 30 reps)

**1. Mais níveis e mais dimensões → mais fragmentação.** `F=10` média 763,8 regiões vs `F=5` 524,8. `Q=10` 780,0 vs `Q=3` 498,1. `Q^F` combinatório domina. `Q=10` compliance≈0 em todas as 180 sims com Q=10.

**2. Seletividade alta fragmenta e atomiza — com uma inversão real.** `ε=0.6` 806,1 vs `ε=0.0` 533,6 vs `ε=0.3` 593,3. Efeito multiplicativo com Q: F=5 Q=10 443,8 (ε=0,0) → 787,8 (0,3) → 946,1 (0,6). F=10 Q=10 chega a 960,9 com ε=0,6 (praticamente 1 agente por região). **Exceção confirmada (n=60, MW p<1e-6): F5Q5 tem ε=0,0 (390,0) MAIS fragmentado que ε=0,3 (344,2)** — filtro suave de homofilia protege o coarsening contra cross-talk disruptivo em Q intermediário (não-monotonicidade tipo Lorenz, não ruído). O ε alto congela tudo do mesmo jeito.

**3. Ranking preserva escala e reps.** 21×21 → 31×31 e 10 → 30 reps mantiveram ordem e magnitudes próximas (ex.: F5Q3ε0.3 304,4→307,5) — valida lean e estabilidade do IC95.

**4. Compliance estrito quase nulo.** Só traço residual com F=5 Q=3 (média 0,003–0,006). Métrica estrita (todas as F dimensões em Q) exige coordenação improvável com inicialização uniforme 1..Q. Para adesão parcial usar `compliance_rate(model,d)` por dimensão.

**5. Hábito acompanha o fluxo de cópias (cheque de consistência, não descoberta).**
`system1_fraction` varia 0→1 entre células (correlação −0,62 com fragmentação).
Leitura adversarial obrigatória: o decaimento system2 dispara *só* em cópias
bem-sucedidas, logo a métrica é por construção um contador de volume de
cópias — a correlação é esperada, não evidência independente de "hábito".
Vale como sanity check do mecanismo dual (onde há cópia há habituação; onde
congela, deliberação persiste), nada além. `mean_motivation` é 1,0 constante
sob FixedCompliance (coluna morta por construção; só Vroom a move).

## Tabela resumo 31×31, 30 reps (média ± desvio por célula)

| F | Q | ε | n_regions | largest_share | mean_size |
|---|---|---|-----------|---------------|-----------|
| 5 | 3 | 0.0 | 301,6 ±43,0 | 6,1 % | 3,27 |
| 5 | 3 | 0.3 | 307,5 ±25,1 | 5,3 % | 3,15 |
| 5 | 3 | 0.6 | 357,4 ±47,7 | 5,2 % | 2,74 |
| 5 | 5 | 0.0 | 386,3 ±34,8 | 3,6 % | 2,51 |
| 5 | 5 | 0.3 | 346,8 ±35,1 | 4,0 % | 2,80 |
| 5 | 5 | 0.6 | 846,2 ±11,8 | 0,6 % | 1,14 |
| 5 |10 | 0.0 | 443,8 ±21,1 | 2,5 % | 2,17 |
| 5 |10 | 0.3 | 787,8 ±14,9 | 0,9 % | 1,22 |
| 5 |10 | 0.6 | 946,1 ±4,6 | 0,3 % | 1,02 |
|10 | 3 | 0.0 | 624,2 ±24,8 | 1,8 % | 1,54 |
|10 | 3 | 0.3 | 620,6 ±26,1 | 1,8 % | 1,55 |
|10 | 3 | 0.6 | 777,6 ±15,7 | 1,1 % | 1,24 |
|10 | 5 | 0.0 | 705,3 ±16,6 | 1,1 % | 1,36 |
|10 | 5 | 0.3 | 695,6 ±19,2 | 1,3 % | 1,38 |
|10 | 5 | 0.6 | 948,4 ±3,3 | 0,2 % | 1,01 |
|10 |10 | 0.0 | 740,4 ±14,8 | 1,0 % | 1,30 |
|10 |10 | 0.3 | 801,3 ±16,2 | 1,0 % | 1,20 |
|10 |10 | 0.6 | 960,9 ±0,3 | 0,1 % | 1,00 |

Atomização: `F=10 Q=10 ε=0,6` → tamanho médio 1,00, largest 0,1 % (1 agente). IC95 por célula em `study_C_agg.csv` (ex.: F5Q3ε0.3 ±9,0; F10Q10ε0.6 ±0,1).

## Figuras

- **Fig.1** `fig1_regions_vs_epsilon.png` — n_regions vs ε (média sobre Q, 30 reps).
- **Fig.2** `fig2_regions_vs_Q.png` — n_regions vs Q por F/ε (30 reps).
- **Fig.3** `fig3_heatmap.png` — heatmap F×Q×ε de n_regions (30 reps).
- **Fig.4** `fig4_boxplot.png` — boxplot n_regions por ε por F (30 reps/célula).
- **Fig.5** `fig5_timeseries.png` — n_regions(t) médio por ε, F=5 Q=3 31×31 500 passos (timeseries 10 reps/ε).

## Estatística inferencial (Julia `stats_study_C_jl.jl`, n=540; cross-check Python `stats_study_C.py` idêntico)

KW sobre `final_n_regions`: F H=100,58 p=1,1e-23; Q H=171,26 p=6,5e-38; ε H=178,53 p=1,7e-39.
Post-hoc Mann-Whitney + Bonferroni: todos os pares significativos (0,0 vs 0,3 p_bonf=0,0054; demais p_bonf<1e-10).
Spearman ε–n_regions com correção de empates (confere com scipy): F=5 r=0,432 p=1e-13; F=10 r=0,678 p=1,3e-37 (n=270 cada).
Mediana por ε — 0,0: 525,5; 0,3: 661,0; 0,6: 902,0.

## Interpretação

ε como filtro de homofilia: ε alto congela mosaico. Q alto como ruído combinatório Q^F em grade finita. Resultados replicam Axelrod + confiança limitada e validam lean 21×21 como qualitativo.

## Limitações

- IC95 agora estável com 30 reps (critério F1 cumprido); agregado em `study_C_agg.csv`.
- Só baseline (sem SmallWorld/Barriers/Vroom). Ablação em Study D.
- Timeseries Fig.5 com 10 reps/ε (ilustrativa); sweep principal com 30.
