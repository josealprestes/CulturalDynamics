# Estudo C — Varredura F × Q × ε

## Plano Experimental

**Pergunta:** Como complexidade (`F`), granularidade (`Q`) e seletividade social (`ε`) afetam fragmentação e compliance?

Operacionalização correta (corrigido em 2026-09-01):
- `initial_features` agora usa `abmrng(model)` e `seed_culture=true` → diversidade real.
- `select_partner` usa `abmrng(model)` → reprodutibilidade.
- `single_run`/`batch_run` usam `abmproperties(model)[:metadata]`.
- `Manifest.toml` ignorado; `Project.toml` com pin exato `Distributions==0.25.120`
  (Agents 6.2.10 não pré-compila acima disso); validado em Julia 1.12
  (matriz CI 1.10–1.12 via push).

## Desenho

- **Grid fixo:** 31×31 = 961 agentes (rápido em horizonte fixo de 500p, sem absorção exigida — ver spot Klemm; evita 61×61 que é 4× mais lento).
- **F:** 5, 10
- **Q:** 3, 5, 10
- **ε:** 0.0, 0.3, 0.6
- **Replicações:** n=10 por célula → 2×3×3×10 = **180 simulações**.
- **Passos:** `max_steps=500`, `seed_culture=true`, `torus=false`, Von Neumann, sem mutação/barreiras, `WeightedContagion`+`FixedCompliance` (baseline).

Variáveis dependentes: `final_compliance_rate`, `final_n_regions`, `final_largest_share`, `final_mean_region_size`, `steps_to_absorption`, `is_absorbed`.

Reprodutibilidade: `seed = base_seed + rep` (1..10 por célula), `Xoshiro(seed)`.

## Execução

```julia
using CulturalDynamics
base = ModelConfig(grid_size=(31,31), F=5, Q=3, seed_culture=true, seed=1,
                   bounded_confidence_threshold=0.3, max_steps=500)
results = parameter_sweep(base; F_values=[5,10], Q_values=[3,5,10],
                                epsilon_values=[0.0,0.3,0.6], n_replications=10)
export_csv(results, "results/study_C_sweep.csv")
export_json(results, "results/study_C_sweep.json")
```

## Análise (a executar)

- Boxplots: compliance e n_regions por F, Q, ε (média ± IC95).
- Heatmap: `mean(n_regions)` em grade F×Q×ε.
- ANOVA / Kruskal-Wallis por fator; correlação ε vs fragmentação.
- Curva de saturação: passos até absorção vs ε.

## Validação

- ε=0 → Axelrod puro (máxima difusão).
- ε=1 → sem interação (fragmentação máxima).
- Q alto → explosão combinatória Q^F → mais regiões (a reportar).
- `Pkg.test` verde antes de rodar (185/185 em Julia 1.12.7 na rodada de 30 reps).

## Entregáveis

- `results/study_C_sweep.csv` + `.json` (180 linhas)
- 3 figuras: (1) n_regions vs ε por F, (2) compliance vs Q por F, (3) heatmap F×Q×ε
- Esta nota + script `run_study_C.jl`
