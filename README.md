# CulturalDynamics — ABM de Difusão Cultural e Adesão a Normas

> **Aviso:** este é um simulador **exploratório** de difusão cultural e adesão
> a normas. Os resultados **não** constituem predição clínica, diagnóstico
> organizacional, parecer jurídico ou recomendação de política pública. Veja
> [Limites metodológicos](#limites-metodologicos).

![License](https://img.shields.io/badge/license-MIT-blue)
![Version](https://img.shields.io/badge/version-1.3.2-blue)
![Tests](https://img.shields.io/badge/tests-268%2F268-brightgreen)
![Gates](https://img.shields.io/badge/gates-9%2F9-brightgreen)
![ORCID](https://img.shields.io/badge/ORCID-0000--0001--8686--5360-green)

---

## Sobre

**CulturalDynamics** é um framework em Julia para simular a difusão de normas
e a adesão a processos em organizações. O núcleo é um modelo tipo **Axelrod**
— agentes com `F` traços culturais, cada um em `Q` níveis — estendido com
**confiança limitada** (`ε`), fadiga, turnos e turnover, papéis, treinamento
gerencial, auditoria normativa e um gestor com **Q-learning tabular**.

O modelo é calibrado em **momentos públicos de higiene das mãos**: aderência
média de aproximadamente **38%** e queda de **8,5 pontos percentuais por
turno** (Dai et al., 2015; WHO, 2009). O horizonte é finito (300–500 passos,
um ciclo de gestão); o objeto é o **transiente**, não o equilíbrio.

O projeto combina três camadas:

1. **Simulador científico** em Julia/Agents.jl, com seeds explícitas e
   goldens determinísticos.
2. **Pipeline de pesquisa** reprodutível: sweeps, calibração, validação
   held-out, benchmarks e auditoria adversarial.
3. **Demo didática standalone** em HTML/JS para apresentação dos mecanismos
   em sala de aula.

O manuscrito e o material de revisão são mantidos separadamente, no
repositório privado do projeto. Este repositório público contém código,
testes, demo, documentação de modelo e instrumentos de reprodutibilidade.

---

## Demo no navegador

A demo `apresentacao/axelrod.html` é **100% standalone**: um único arquivo,
sem build, sem servidor e sem dependências. Abra no navegador e use os quatro
presets:

| Cenário | Parâmetros | O que observar |
|---|---|---|
| **Clássico** | `F5 Q3 ε0.3` | mosaico de centenas de regiões; configuração de referência |
| **Convergente** | `F5 Q3 ε0` | tende à monocultura; em 31² a coesão é lenta |
| **Fragmentado** | `F10 Q10 ε0.3` | ~900 micro-regiões, ainda com cópias raras |
| **Mosaico** | `F5 Q5 ε0.3` | blocos médios, entre consenso e poeira |

O caso extremo `F10 Q10 ε0.6` continua acessível pelo slider de `ε`, mas é
**quase congelado por desenho**: a chance de dois agentes serem similares o
bastante é ~0,01%. A demo explica isso na aba “Cenários”.

```bash
# Testes da demo (Node 20+; sem dependências)
node --test "apresentacao/test/*.test.mjs"
```

São 11 testes: boot/reset, funções puras (`overlap`, `regions`, `adherence`),
cores, smoke dos 4 presets, pausa/retomada e ciclo preset → reset → play.

> O link de artifact usado na aula é privado e expira; a fonte de verdade é
> sempre o arquivo local `apresentacao/axelrod.html`.

---

## Como executar

### Pré-requisitos

- **Julia 1.10+** (referência local: 1.10.8; corpus: 1.12.7)
- **Node.js 20+** apenas para os testes da demo (testado com 24.13.0)
- **Python 3.12+** para análise, figuras e utilitários
- **LaTeX** opcional (o manuscrito não faz parte deste repositório)
- Navegador moderno para a demo

### Instalação

```bash
git clone https://github.com/josealprestes/CulturalDynamics.git
cd CulturalDynamics

julia --project=. -e "using Pkg; Pkg.instantiate()"
```

O `Manifest.toml` é lock local e não é versionado. Se houver desalinhamento
com o `Project.toml`, rode `Pkg.resolve()`; **não** faça `Pkg.update()` cego
(o pin `Distributions = "=0.25.120"` é intencional por compatibilidade com
Agents.jl 6.2.10).

### Simulação rápida

```bash
julia --project=. run.jl           # 31×31, F=5, Q=3, 300 passos, seed 42
julia --project=. run.jl 7 500     # seed 7, 500 passos
```

### Demo didática

Abra `apresentacao/axelrod.html` no navegador. No Windows:

```powershell
Start-Process "apresentacao/axelrod.html"
```

### Servidor web local

```bash
julia --project=. src/web_server.jl
# http://localhost:8080 — escuta só em 127.0.0.1
```

A API não tem autenticação, então o padrão é loopback. Para servir a demo a outra
máquina o opt-in é explícito:

```bash
CD_HOST=0.0.0.0 julia --project=. src/web_server.jl     # ou: ... src/web_server.jl 8080 0.0.0.0
```

---

## Testes e verificação local

A verificação canônica é **local** — o workflow remoto do GitHub foi removido
em 2026-10-20 por billing da conta. O runner único é:

```bash
# Windows
powershell -ExecutionPolicy Bypass -File scripts/run_checks.ps1

# Linux/macOS
bash scripts/run_checks.sh
```

Etapas:

```bash
py -3 scripts/check_gates.py                  # G1–G9, stdlib, segundos
julia --project=. -e "using Pkg; Pkg.test()"  # suíte Julia: 268/268
node --test "apresentacao/test/*.test.mjs"    # demo: 11/11
```

O runner completo (`-Full` / `--full`) também executa a documentação; o
checker de números do manuscrito roda apenas no repositório privado.

A suíte cobre unidade, propriedades/invariantes, metamórfico, goldens
bit-idênticos, integração, contrato web e mutação. Cobertura sozinha **não**
é usada como critério de qualidade.

---

## Reprodutibilidade

- **Determinismo por seed:** cada modelo usa um único `Xoshiro(seed)` via
  `abmrng(model)`; nada de `rand()` global no caminho de simulação.
- **Goldens:** trajetórias 15² F5Q3 300p são comparadas com tolerância
  `1e-12`; qualquer mudança de comportamento em `src/core` exige justificativa.
- **Corpus:** 27 CSVs de resultados (gitignored) descritos em
  [`DATASETS.md`](DATASETS.md); regeneráveis pelos scripts `run_*.jl`.
- **Metadados:** scripts, seeds, configuração, versão de Julia/Python e
  hardware de timing são registrados nos docs de estudo.
- **Artefato:** código + dados + licença + `CITATION.cff` + DOI (FAIR4RS).
  O depósito Zenodo do corpus está pendente.
- **Nunca** “conserte” um número editando CSV; regenere pelo script e
  documente a divergência.

Detalhes operacionais: [`docs/REPRODUTIBILIDADE.md`](docs/REPRODUTIBILIDADE.md).

---

## Como usar a API

```julia
using CulturalDynamics

config = ModelConfig(
    grid_size = (31, 31),
    F = 5, Q = 3,
    seed_culture = true,
    seed = 1,
    max_steps = 300,
    bounded_confidence_threshold = 0.3,
)

model = build_model(config)
step!(model, 300)

count_regions(model)          # fragmentação
partial_compliance(model)     # aderência média normalizada
compliance_rate(model)        # todos os F traços no nível Q
```

Experimentos em lote:

```julia
results = batch_run(config; n_reps = 10)
export_csv(results, "results/demo_batch.csv")

sweep = parameter_sweep(config;
    F_values = [5, 10], Q_values = [3, 5],
    epsilon_values = [0.0, 0.3], n_replications = 3)
```

Exemplos completos em `examples/`:

- `01_textbook_mode.jl` — Axelrod puro
- `02_compliance_basic.jl` — adesão e métricas
- `03_team_dynamics.jl` — papéis e equipes
- `04_management_intervention.jl` — treinamento e auditoria
- `05_rl_training.jl` — gestor Q-learning
- `06_interactive_exploration.jl` — exploração interativa

---

## Como o motor funciona

### Agentes

Cada `ComplianceAgent` tem:

- `features::Vector{Int}` — `F` traços, valores `1..Q`;
- `motivation` — força de motivação (Vroom), `[0,1]`;
- `openness` / `expressiveness` — receptividade e influência;
- `system2_weight` — 1 = deliberado, 0 = habitual (processo dual);
- `team_id` e `social_rank` — estrutura organizacional.

### Passo do agente

1. Auditoria normativa, se `NormSanctions` estiver ativo.
2. Fadiga: motivação decai e, com probabilidade `fatigue_rate`, um traço
   acima de 1 decresce (“cortar cantos”).
3. Atualização de motivação Vroom, se ativo.
4. Sorteio de um vizinho válido (grade, rede ou barreira).
5. Similaridade = fração de traços iguais.
6. Gate de confiança limitada: similaridade `< ε` bloqueia a interação.
7. Cópia de **um** traço divergente com probabilidade `p(s)`.
8. Em cópia: contágio social, mutação e decaimento de `system2_weight`.

### Passo do modelo

1. Treinamento direcional (`DirectedTraining`), se ativo.
2. Fronteira de turno: reset de motivação e turnover, se configurados.
3. Registro de métricas no intervalo definido.
4. Checagem de absorção.

### Mecanismos

| Mecanismo | Efeito | Default |
|---|---|---|
| Axelrod + `ε` | difusão local e polarização | ativo |
| Vroom | motivação modula cópia | inerte |
| Contágio ponderado | influência de expressividade | ativo, mas nulo declarado |
| Processo dual | hábito vs deliberação | inerte |
| Fadiga | queda de aderência ao longo do turno | calibrado |
| Turno/turnover | reset e substituição de agentes | inerte |
| Treinamento | força direcional para `Q` | inerte |
| Auditoria/sanção | norma explícita + monitoramento | inerte |
| Q-learning | gestor escolhe quando treinar | PoC em 1 grade |

**Regra de ouro:** todo mecanismo é inerte por default; qualquer efeito
reportado é atribuível ao mecanismo ligado.

---

## Cenários e métricas

| Métrica | O que é | Leitura |
|---|---|---|
| `F` | número de traços culturais | complexidade da norma |
| `Q` | níveis por traço | granularidade da adesão |
| `ε` | limiar de confiança | seletividade social |
| `n_regions` | componentes conexos de agentes idênticos | fragmentação cultural |
| `largest_share` | fração no maior bloco | dominância |
| `partial_compliance` | média normalizada `(f-1)/(Q-1)` | aderência primária |
| `compliance_rate` | todos os `F` traços em `Q` | adesão estrita (quase sempre 0) |
| `absorbed_at` | primeiro passo de absorção | tempo real de estabilização |

A quantização de `ε` é um fato do modelo: com `F` traços, o gate só muda em
múltiplos de `1/F`. Duas configurações no mesmo múltiplo produzem trajetórias
bit-idênticas.

---

## Para gestores e pesquisadores

O modelo permite explorar perguntas como:

- Treinamento contínuo e auditoria produzem retornos decrescentes?
- Quando o custo de treinar supera o ganho marginal de aderência?
- Que combinações de fadiga, turnover e papéis criam heterogeneidade entre
  unidades?
- A fragmentação cultural é inevitável com muitas dimensões e níveis?
- Qual o efeito de intervenções direcionadas vs. cópia lateral?

Glossário e três vinhetas com números: [`docs/src/manual/managers.md`](docs/src/manual/managers.md).

---

## FAQ

### Qual versão de Julia preciso?
Julia 1.10 ou superior. A referência local é 1.10.8; o corpus foi gerado em
1.12.7. O pin de Agents.jl 6.2.10 é intencional.

### Por que 38% e −8,5 pp/turno?
São momentos públicos de higiene das mãos (WHO 2009; Dai et al. 2015). O
modelo é calibrado nesses **momentos agregados**, não em dados de um hospital
específico.

### O que são `F`, `Q` e `ε`?
`F` é o número de regras/dimensões; `Q` é a granularidade (1 = nunca, `Q` =
sempre); `ε` é o limiar de similaridade para uma interação ocorrer.

### O modelo prevê a adesão do meu hospital?
Não. O escopo é um **laboratório exploratório** calibrado em momentos
públicos. Predição clínica exigiria dados proprietários, calibração
bayesiana e validação externa.

### Posso usar meus próprios dados?
Sim, para pesquisa, mas isso é um novo desenho de calibração/validação, não
uma extensão automática do corpus atual. Veja `docs/research/ODD.md`.

### Por que Julia?
O núcleo numérico e o loop de agentes se beneficiam de tipagem, desempenho e
determinismo. A análise e as figuras usam Python. A decisão está documentada
em `docs/research/STACK_DECISION.md`.

### O projeto precisa de internet?
Não para simular ou abrir a demo. Apenas instalação de dependências e
serviços externos opcionais.

### Como contribuir?
Veja [`CONTRIBUTING.md`](CONTRIBUTING.md). Pull requests são bem-vindos;
mudanças de comportamento exigem teste que falhe antes e passe depois.

---

## Arquitetura

```
CulturalDynamics/
├── src/
│   ├── core/             # tipos, modelo, métricas, regiões, vizinhanças
│   ├── extensions/       # mutação, redes, confiança, contágio, dual, papéis
│   ├── experiments/      # batch, sweeps, export, sensitivity, calibration
│   ├── rl/               # ambiente, rewards, spaces, training
│   └── visualization/    # grid, métricas, web dashboard
├── test/                 # unidade, propriedades, goldens, integração
├── examples/             # 6 exemplos executáveis
├── apresentacao/         # demo HTML standalone + testes Node
├── docs/
│   ├── src/              # Documenter (manual, API, gestores)
│   └── research/         # ODD, TRACE, SOTA, benchmarks, estudos
├── scripts/              # gates, runner local, mutação, contrato web
├── benchmark/            # scaling, Castellano, baseline Mesa
├── web/                  # demo web local (servidor Julia)
├── run_*.jl              # scripts de regeneração dos estudos
├── Project.toml
├── CITATION.cff
└── README.md
```

### Stack

| Camada | Tecnologia | Versão/nota |
|---|---|---|
| Núcleo | Julia | 1.10+; referência 1.10.8 |
| ABM | Agents.jl | 6.2.10 (pin) |
| Distribuições | Distributions | =0.25.120 (pin) |
| Grafos | Graphs.jl | 1.x |
| Análise | Python | 3.12+; scipy/pandas/matplotlib |
| Demo | HTML/JS | standalone, sem build |
| Testes da demo | Node `node:test` | Node 20+ |

---

## Limites metodológicos

- O simulador é **exploratório**: não faz predição de organizações reais nem
  de desfechos clínicos.
- A calibração usa **momentos públicos agregados**, não dados proprietários.
- A validação é **macro** (padrões P1–P5), não dos micro-mecanismos
  individuais, que não foram observados em humanos.
- O horizonte é finito (300–500 passos): os resultados são **transientes**,
  não equilíbrio.
- A sensibilidade global é um **ranking grosseiro** em 3 bins (η²); não é
  magnitude de efeito.
- O RL é **proof-of-concept** em uma grade; não é política implantável.
- O acordo Julia × Mesa é **distribucional** (B2), não claim de velocidade.
- O caso `F10 Q10 ε0.6` é quase congelado; não é falha, é o limite do regime.
- O manuscrito, os pareceres e o material de revisão **não** fazem parte
  deste repositório público.

---

## Validação e robustez

- **Study C:** 540 simulações, 30 replicações por célula, sweep F×Q×ε.
- **Calibração:** fadiga na faixa 0.003–0.006; RMSE 0.004 contra teto
  pré-registrado de 0.05.
- **Held-out:** P1–P5 (ranking de fragmentação, declínio por turno, curva
  côncava de treino, heterogeneidade entre unidades, acordo distribucional).
- **B2:** 60 seeds por braço, Julia × Mesa dentro de ±1,5%; sem claim de
  velocidade.
- **Auditoria adversarial:** 10 rounds de red-team, com errata e nulos
  declarados (contágio, punição, processo dual).
- **Testes:** 268 testes Julia, 11 testes da demo, goldens bit-idênticos,
  mutation testing e 9 gates estáticos.

---

## Contexto acadêmico

Este projeto foi desenvolvido como um dos trabalhos finais da disciplina **IA006J —
Tópicos em Sistemas Inteligentes II, Turma I** (“Aplicações da Ciência e
Engenharia dos Sistemas Dinâmicos de Muitos Agentes”), oferecida pelo
Programa de Pós-Graduação da **Faculdade de Engenharia Elétrica e de
Computação (FEEC) da Unicamp**, cursada como aluno regular de mestrado no
2º semestre de 2026.

A disciplina conecta a trajetória profissional do autor — que percorre
Direito, Tecnologia e Gestão — à pesquisa acadêmica em sistemas complexos e
modelagem baseada em agentes. As perguntas do simulador nascem tanto da
prática profissional quanto da investigação acadêmica sobre adesão a normas,
comportamento organizacional e difusão cultural.

---

## Metodologia de desenvolvimento (vibe coding)

Este projeto foi desenvolvido utilizando **vibe coding**, uma abordagem de
codificação iterativa e dialógica mediada por Inteligência Artificial
Generativa (IA Gen), na qual a IA atua como parceira no processo criativo e
formativo (de Lima Prestes, 2025a). O código foi gerado, revisado e refinado
por meio de interações em linguagem natural com modelos de linguagem, com
supervisão e direção humana em todas as etapas.

Cada funcionalidade seguiu o ciclo definido no **Framework para Letramento
Crítico em IA** (de Lima Prestes, 2025b): **intenção → prompt → geração →
análise crítica → metacognição → autoria → iteração**. O processo busca
reduzir Carga Extrínseca e ampliar Carga Germana (Sweller, 1988; 2010;
Grazioli, 2025), de modo que o uso da IA não substitua o raciocínio, mas o
potencialize.

No plano operacional, o vibe coding foi acompanhado de disciplina de
engenharia: especificações curtas, gates determinísticos (G1–G9), testes de
unidade/propriedade/metamórficos/golden, mutation testing, revisão humana e
proveniência de cada número. A IA acelera a geração e a revisão; a
responsabilidade científica permanece humana.

### Referências da metodologia

> de Lima Prestes, J. A. (2025a). *Vibe Coding e Ensino Humanizado com IA:
> Uma Proposta Inclusiva para a Formação em Engenharia*. COBENGE 2025.
> DOI: [10.37702/2175-957X.COBENGE.2025.6030](https://doi.org/10.37702/2175-957X.COBENGE.2025.6030)

> de Lima Prestes, J. A. (2025b). *Vibe Coding na Educação Superior:
> Framework para Letramento Crítico em IA*. SciELO Preprints.
> DOI: [10.1590/SciELOPreprints.15198](https://doi.org/10.1590/SciELOPreprints.15198)

---

## Licença

MIT License. Copyright (c) 2026 José Augusto de Lima Prestes. Veja
[`LICENSE`](LICENSE).

---

## Citação

```bibtex
@software{prestes2026culturaldynamics,
  author = {Prestes, Jos{\'e} Augusto de Lima},
  title = {CulturalDynamics: Framework Julia para Simula{\c{c}}{\~a}o de
           Ades{\~a}o a Normas e Difus{\~a}o Cultural},
  year = {2026},
  url = {https://github.com/josealprestes/CulturalDynamics},
  note = {Projeto de pesquisa em ABM; disciplina IA006J, FEEC/Unicamp.}
}
```

---

## Links

- **Site:** [joseprestes.com](https://joseprestes.com)
- **ORCID:** [0000-0001-8686-5360](https://orcid.org/0000-0001-8686-5360)
- **Currículo Lattes:** [8295411061159606](http://lattes.cnpq.br/8295411061159606)
- **Changelog:** [CHANGELOG.md](CHANGELOG.md)
- **Contribuição:** [CONTRIBUTING.md](CONTRIBUTING.md)
- **Reprodutibilidade:** [docs/REPRODUTIBILIDADE.md](docs/REPRODUTIBILIDADE.md)
