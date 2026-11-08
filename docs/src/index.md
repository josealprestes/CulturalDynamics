# CulturalDynamics.jl

A Julia framework for simulating **compliance/adherence to processes, procedures, and norms** using agent-based modeling with cultural diffusion dynamics.

## Para gestores/juristas (leitura em 2 min)

| Conceito técnico | O que significa na organização |
|---|---|
| `F` dimensões, `Q` níveis, `ε` confiança limitada | Quantas regras, quão granulares, quão seletivo é o grupo ao ouvir quem pensa diferente |
| `n_regions` / `compliance_rate` / `largest_share` | Quantos blocos culturais, quanta gente adere de fato, quão concentrado está o consenso |
| `SmallWorld` vs `Grid` | Rede informal vs hierarquia rígida |
| `Vroom`/`Contágio`/`Dual Process` | Motivação, influência social e hábito — por que treinamento não cola |
| `benchmark/scaling.jl` | Aguenta 4.000 agentes? Quanto custa simular? |

**Glossário:** `F`=nº regras, `Q`=granularidade, `ε`=seletividade, `F5 Q10 ε0,6 → 960 regiões em 961 agentes = cada um faz do seu jeito`.
**FAQ:** (1) Preciso de RL? Não — serve para buscar intervenção mínima. (2) Preciso instalar Julia? Demo web roda no navegador via `julia --project=. src/web_server.jl → http://localhost:8080`.
**Vinhetas:** ver `docs/research/study_C_results.md` para leitura executiva.

## Features

- **Cultural Diffusion**: Axelrod's model with bounded confidence filtering
- **Motivation Theory**: Vroom's expectancy theory for compliance motivation
- **Social Contagion**: Weighted influence based on expressiveness and openness
- **Dual Process**: System 1/2 transition for habit formation
- **RL Integration**: Train RL agents to optimize compliance strategies
- **Web Visualization**: demo web zero-dep (`src/web_server.jl` + `web/index.html`); Makie é backend opcional carregado pelo chamador
- **Batch Experiments**: Parameter sweeps, sensitivity analysis, CSV export

## Quick Start

```julia
using CulturalDynamics

# Create configuration
config = ModelConfig(
    grid_size = (61, 61),
    F = 10,
    Q = 3,
    bounded_confidence_threshold = 0.3,
)

# Build and run model
model = build_model(config)
step!(model, 1000)

# Analyze results
compliance_rate(model)
count_regions(model)
```

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/josealprestes/CulturalDynamics")
```

## License

MIT
