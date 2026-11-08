# Stack decision — Julia é a melhor opção?

> **Data:** 2026-10-26. **Pergunta:** manter Julia/Agents.jl como núcleo do
> CulturalDynamics, migrar para Python/Mesa, ou reescrever em Rust/C++?
>
> **Resposta curta:** **sim, Julia continua sendo a melhor opção para o núcleo
> de simulação deste projeto**, mas **não** é a melhor opção para todo o
> workflow. A decisão defensável é **híbrida**: Julia no motor, Python na
> análise/calibração/figuras. Não reescrever agora.

## 1. Contexto medido (não estimado)

| Item | Valor |
|---|---|
| Código do simulador (`src/*.jl`) | 2.226 linhas |
| Testes (`test/*.jl`) | 668 linhas; **251 testes, 31.9 s** em Julia 1.10.8 |
| Scripts de experimento (`run_*.jl`) | 1.000 linhas |
| Benchmark Julia (`benchmark/*.jl`) | 122 linhas |
| Python (análise/benchmark/scripts) | 758 linhas |
| Web (`web/index.html`) | 592 linhas |
| Corpus | 27 CSVs; 540 sims no Study C; regeneração em horas |
| Dependência crítica | Agents 6.2.10 pinado por Distributions `=0.25.120` |
| B2 (31², 300p, n=60/braço) | Julia 340.6 ±28.2 vs Mesa 336.3 ±24.6 regiões; Δ≈1.5% |
| B2 timing single-seed | Julia 52.0 vs Mesa 40.6 ms/step (Mesa favorecida) |
| B1 (31², F5Q3ε0.3) | 32.5 ms/step na máquina de referência; forma ≈ linear |

**Leitura:** o projeto não tem um problema de performance que justifique
reescrever. O gargalo real é **calibração/UQ** e **reprodutibilidade
operacional**, não a velocidade do loop. O B2 mostra que a vantagem teórica de
Julia não se traduz automaticamente em vantagem prática quando o loop tem
alocação, `collect`, contagem de regiões e I/O.

## 2. Matriz de decisão (juízo, não medição)

Pesos: corretude/reprodutibilidade 20%, ecossistema científico 20%,
performance/escala 15%, velocidade de desenvolvimento/testes 15%,
deploy/produto 10%, talento/manutenção 10%, risco de migração 10%.
Escala 1–5 (5 = melhor).

| Critério | Julia/Agents.jl | Python/Mesa | Rust/Ark.jl | C++ custom | NetLogo | R |
|---|---:|---:|---:|---:|---:|---:|
| Corretude/reprodutibilidade | 5 | 4 | 4 | 4 | 3 | 3 |
| Ecossistema científico | 3 | **5** | 2 | 2 | 2 | 4 |
| Performance/escala | **5** | 2 | **5** | **5** | 1 | 2 |
| Dev velocity/testes | 3 | **5** | 2 | 1 | 4 | 4 |
| Deploy/produto | 2 | **5** | 4 | 4 | 2 | 2 |
| Talento/manutenção | 2 | **5** | 2 | 3 | 3 | 4 |
| Risco de migração (5=baixo) | 3 | 4 | 2 | 2 | 4 | 4 |
| **Total ponderado** | **3.50** | **4.25** | **3.05** | **3.00** | **2.65** | **3.30** |

**Como ler:** Python ganha como **linguagem geral** do workflow; Julia ganha
como **engine de simulação** (performance + determinismo + modelo maduro em
Agents.jl). A matriz não decide sozinha; ela mostra por que a resposta é
híbrida, não “trocar tudo”.

## 3. Evidência externa

### Julia
- **TIOBE out/2026:** Julia #18 (0.88%), Python #1 (19.23%), Rust #10 (1.44%).
  Julia voltou ao top 20; ainda é nicho.
- **Agents.jl v7.1.0** (2026-10-10): `StandardABM`/`EventQueueABM` estáveis;
  `ReinforcementLearningABM` e container SoA **experimentais**. v6.2.10 é a
  pinada atual; v7 tem breaking changes de plotting/OSM/deprecations.
- **State of Julia for SciML** (arXiv:2410.10908): Julia é rápida e expressiva,
  mas testing/debugging/indústria/interoperabilidade são limitações reais.
- **Compile/startup:** relatos de regressão de precompilação em 1.12 vs 1.10;
  o repo já sofre com pin de Distributions e aviso de Manifest.
- **Pontos fortes:** multiple dispatch, RNG determinístico (`Xoshiro`),
  `Agents.jl` com espaços/grafos, `Graphs.jl`, `Turing`/SciML, benchmarks
  nativos, código curto para ABM.

### Python/Mesa
- **Mesa 3.5 estável; Mesa 4 em desenvolvimento** (docs oficiais). JOSS 2025,
  DOI 10.21105/joss.07668.
- **Ecossistema:** NumPy/pandas/SciPy/statsmodels, scikit-learn, PyTorch/JAX,
  `pyABC`, `SALib`, `sbi`, `emcee`, `matplotlib`, `networkx`, `FastAPI`,
  `Streamlit`/Solara; LLM/agent tooling.
- **Python 3.14 free-threading** reduz parte do problema de GIL, mas não
  transforma código Python puro em C; compatibilidade de pacotes ainda é
  parcial.
- **Performance:** Mesa é mais lenta que Agents.jl nos modelos do benchmark
  oficial (3–159× dependendo do modelo), mas o gap real depende da implementação.
- **Pontos fortes:** contratação, colaboração, deploy, interoperabilidade,
  velocidade de iteração, bibliotecas de calibração.

### Rust/Ark.jl e C++
- **Ark.jl 0.5.1** é mais rápido que Agents.jl em WolfSheep no benchmark
  oficial (0.17–0.36 da razão), mas é jovem, menor ecossistema e exigiria
  reescrita + revalidação.
- **C++ custom** maximiza controle, mas paga em produtividade, testes e
  manutenção; não há justificativa de escala atual.
- **NetLogo** é didático, não é engine de pesquisa reprodutível em CI.
- **R** é ótimo para estatística/figuras, não para o loop.

## 4. Decisão

### 4.1 Manter Julia no núcleo
- O modelo já está implementado, testado (268/268) e calibrado; reescrever
  destrói a continuidade do corpus e o checker.
- A performance é suficiente: 540 sims em horas; 10k agentes ~3 steps/s na
  máquina de referência; o gargalo é calibração, não o loop.
- O determinismo por seed e os goldens são um ativo científico; Python/Mesa
  teria de reconstruí-los.

### 4.2 Adicionar camada Python (não PyCall no core)
- **Contrato:** CSV/Parquet/Arrow; o Julia exporta, o Python lê. Sem acoplar
  o core a `PyCall`.
- **Usos:** calibração (HM/ABC-SMC, `pyABC`, `sbi`), sensibilidade (`SALib`),
  estatística/figuras, eventuais surrogates (GP/RF), análise de sensibilidade.
- **Benefício:** captura o melhor dos dois mundos sem reescrever o simulador.
- **Custo:** 1–2 semanas de agente; baixo risco; não muda o corpus.

### 4.3 Planejar Agents.jl v7.1
- Branch `feat/agents-v7`, atualizar `Project.toml`, resolver Distributions,
  rodar `Pkg.test`, goldens e um subset do corpus; comparar ms/step e
  resultados.
- Migrar se: (a) v7 destravar dependência/Julia 1.12+; (b) `RLABM`/SoA der
  ganho real; (c) v6 ficar sem suporte. Caso contrário, 6.2.10 é dívida
  controlada, documentada.
- **Não** migrar no meio de uma rodada de paper; congelar corpus primeiro.

### 4.4 Não reescrever em Rust/C++/Mesa agora
- O custo de port + revalidação (2.2k LOC + 668 LOC de teste + 1k LOC de
  scripts + 540 sims + checker + paper) é de **ordem de 4–8 semanas de
  pessoa**, com risco alto de perder bit-identidade e atrasar submissão.
- Reavaliar apenas se um gatilho objetivo aparecer (§5).

## 5. Gatilhos de revisão (reevaluar a decisão)

Reabra a decisão se **qualquer** item abaixo for verdadeiro:

1. **Escala:** necessidade de >10^5 agentes por run ou tempo real/digital twin.
2. **Equipe:** colaboradores/estudantes não usam Julia e o onboarding vira
   gargalo recorrente.
3. **Produto:** necessidade de web app multiusuário, auth, cloud, LLM agents,
   ou dashboard em tempo real.
4. **Calibração:** o método escolhido (HM/ABC-SMC/SBI) só existe em Python e o
   CSV não basta.
5. **Dependência:** Agents.jl 6.2.10 quebra em Julia futura ou Distributions
   não puder ser resolvido.
6. **Performance:** o corpus passa de horas para dias e o profiling mostra que
   o loop Julia (não I/O) é o gargalo.
7. **Validação:** parceria hospitalar exigir integração com dados/API em
   Python/SQL.

## 6. Plano de migração (se um gatilho disparar)

### Fase A — camada Python (baixo risco, recomendada já)
1. Definir schema CSV/Parquet versionado.
2. `analysis/` Python: leitura, checagem de schema, estatística, figuras.
3. `calibration/` Python: HM/ABC-SMC com mapeamento pré-computado; rodar o
   Julia em batch e inferir offline.
4. Testes de contrato: schema, contagens, seeds, hash do CSV.

### Fase B — Agents.jl v7 (médio risco)
1. Branch + `Pkg.resolve()`; rodar suite e goldens.
2. Adaptar `ABM(...)` para `StandardABM` se necessário; medir.
3. Comparar B1/B2 e 10 seeds do Study C; só então decidir.

### Fase C — port completo (alto risco, evitar)
1. Portar `core` + `extensions` + `rl` para Python/Mesa ou Rust/Ark.
2. Reimplementar testes de propriedade/goldens e o checker.
3. Regenerar corpus e comparar com o canônico; divergência = parar.
4. Só faz sentido se o produto/equipe justificar o custo.

## 7. Riscos e mitigação

| Risco | Prob. | Impacto | Mitigação |
|---|---|---|---|
| Churn Agents.jl v7 | média | alto | pin, branch, benchmark, não migrar no escuro |
| Compile time/Manifest | alta | médio | `Pkg.resolve`, cache, CI local, documentar |
| Ecossistema ML/LLM | alta | médio | camada Python; não forçar Julia |
| Performance superestimada | média | médio | benchmark do workload real, não microbenchmark |
| Mão de obra | alta | médio | docs/skills, onboarding, Python para análise |
| Perda de bit-identidade | média | alto | goldens, seeds, checker, regeneração controlada |

## 8. Veredito

**Julia é a melhor opção para o núcleo deste projeto hoje.** Não porque seja a
linguagem mais popular ou a mais rápida em todos os benchmarks, mas porque o
modelo já está nela, o determinismo e os testes estão calibrados, e a
performance é adequada ao workload. **Python é a melhor opção para o workflow
ao redor** (calibração, estatística, figuras, deploy, LLM). A arquitetura
recomendada é **Julia core + Python analysis**, com migração v7 planejada e
gatilhos objetivos para reavaliar.

## 9. Referências
- `docs/research/SOTA_2026.md` §7 e §9.
- `benchmark/results/scaling.csv`, `results/B2_multiseed.csv`,
  `results/B2_mesa.csv`.
- `docs/research/BENCHMARKS.md` §B1/B2.
- Agents.jl releases; Mesa docs/JOSS 2025; ABMFrameworksComparison.
- TIOBE out/2026; arXiv:2410.10908; FAIR4RS DOI 10.15497/RDA00068.
