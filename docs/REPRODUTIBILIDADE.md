# Reprodutibilidade — CulturalDynamics

> Guia público. O manuscrito e o checker número-a-CSV são mantidos no
> repositório privado; aqui ficam o código, os comandos e os dados
> regeneráveis.

## Ambiente

| Componente | Versão de referência | Observação |
|---|---|---|
| Julia | 1.10.8 local; 1.12.7 corpus | `Project.toml` declara Julia 1.10+ |
| Agents.jl | 6.2.10 | pin intencional |
| Distributions | `=0.25.120` | pin por compatibilidade com Agents 6.2.10 |
| Python | 3.12+ | scipy/pandas/matplotlib para análise |
| Node.js | 20+ | apenas testes da demo (testado 24.13.0) |
| Mesa | 1.2.1 | baseline B2 |

O `Manifest.toml` é lock local e não é versionado. Se houver desalinhamento:

```bash
julia --project=. -e "using Pkg; Pkg.resolve()"
```

Não use `Pkg.update()` cego: o pin de `Distributions` é intencional.

## Determinismo

- Cada modelo usa um único `Xoshiro(seed)` via `abmrng(model)`.
- Nada de `rand()` global no caminho de simulação.
- `seed = base + rep`; a unicidade é o par `(config, seed)`.
- Goldens 15² F5Q3 300p são comparados com `atol=1e-12`.
- A quantização de `ε` em múltiplos de `1/F` é bit-idêntica.

## Comandos canônicos

```bash
# 1. Instalar
julia --project=. -e "using Pkg; Pkg.instantiate()"

# 2. Gates estáticos
py -3 scripts/check_gates.py

# 3. Suíte Julia
julia --project=. -e "using Pkg; Pkg.test()"

# 4. Demo
node --test "apresentacao/test/*.test.mjs"

# 5. Runner local
powershell -ExecutionPolicy Bypass -File scripts/run_checks.ps1
# ou
bash scripts/run_checks.sh
```

## Corpus

O corpus tem 27 CSVs em `results/` (gitignored), descritos em
[`DATASETS.md`](../DATASETS.md). Cada arquivo é regenerável por um script
`run_*.jl`; as seeds estão documentadas no próprio dicionário. O corpus
canônico foi gerado em Julia 1.12.7.

Regeneração completa (horas de CPU): ver Apêndice A do manuscrito, no
repositório privado, e a ordem em `DATASETS.md`.

## Proveniência

O fluxo é:

```
script → seed → CSV → figura → número
```

- `scripts/check_gates.py` — G1–G9 (anti-vacuous, contrato web, seeds,
  contagens, goldens, higiene).
- `scripts/mutation.py` — mutação do core (alvo ≥70% não-equivalentes).
- `scripts/web_contract_live.py` — contrato `/simulate` contra servidor vivo.
- `verificação número-a-CSV (privada)` — verificação número-a-CSV **no repositório
  privado**.

## Artefato

- Código: este repositório (MIT).
- Dados: `results/` não versionado; depósito Zenodo pendente.
- Citação: `CITATION.cff`.
- Figuras: `results/figures/` (gitignored) e cópias no material privado.

## Limites

- O corpus é reproduzível a partir do git, mas não é “propriedade do
  checkout”.
- O horizonte é finito (300–500 passos); não há claim de equilíbrio.
- A calibração usa momentos públicos agregados, não dados proprietários.
- O acordo Julia × Mesa é distribucional (B2), não de velocidade.
- O RL é proof-of-concept em uma grade.
