# ODD — CulturalDynamics v1.3.0 (Grimm et al. 2020)

> The model description follows the ODD (Overview, Design concepts, Details)
> protocol for describing individual- and agent-based models (Grimm et al.
> 2006), as updated by Grimm et al. (2020).
>
> Descrição formal do modelo para replicabilidade. Números de validação em
> `study_C_results.md`, `BENCHMARKS.md §§7–8`, `auditoria adversarial (material privado)`,
> `moments_hand_hygiene.md`, `validation_V3.md`. Figura-resumo padronizada
> (vODD, Szangolies et al. 2024): `vODD.png` (I=Initialisation,
> S=Submodels, O=Observations). Rastreabilidade claims→código→testes: `TRACE.md`.

## 1. Purpose and patterns
Laboratório de mecanismos de difusão cultural aplicados à adesão
organizacional, **calibrado em momentos públicos de higiene hospitalar**
(V1): ordenar alavancas por efeito sobre fragmentação e aderência em
horizonte fixo, com validade operacional parcial (Sargent). NÃO prediz
organizações individuais (sem dado proprietário; teto = exploratório
quantitativo).
Padrões usados como critério de adequação (POM; testáveis, §5 do paper):
(P1) ranking de fragmentação por F/Q/ε; (P2) declínio de aderência por turno
(−8.5pp, 38% nível); (P3) curva côncava de treino; (P4) heterogeneidade entre
unidades sob regimes estruturais; (P5) acordo distribucional cruzado ±1.5%
(B2, n=60).

## 2. Entities, state variables, scales
- **Agentes** (`ComplianceAgent`): `id`, `pos` (x,y), `features::Vector{Int}`
  (F dims, valores 1..Q), `motivation`, `openness`, `expressiveness`,
  `system2_weight` ∈ [0,1], `team_id`, `social_rank`.
- **Ambiente**: grade W×H (`torus=false` default), opcional `barrier_grid`,
  opcional grafo (`SmallWorld(k,β)` / `ScaleFree(m)`).
- **Coletivos observados**: regiões culturais (componentes conexos de
 features idênticas, Union-Find), sem agência própria.
- **Escalas**: 1 passo = 1 rodada de ativação de todos os agentes (sem
  mapeamento temporal calibrado — horizonte interpretado como "um ciclo
  de gestão", aberto); N = 441–10201 nos estudos.

## 3. Process overview and scheduling
Por passo, para cada agente em ordem do scheduler (`:fastest` default,
configurável; `:randomly` testado em MED-7): (1) tentativa conta `attempted`;
(2) auditoria normativa se `NormSanctions`; (3) fadiga (decaimento motivacional
+ drift p/ baixo) se ativa; (4) atualiza motivação se Vroom; (5) sorteia
parceiro válido; (6) similaridade overlap/F; (7) gate ε — **efetivo só em
múltiplos de 1/F** (quantização); (8) cópia com prob. `p_copy`
(`copy_probability`; textbook = similaridade × `copy_scale`); (9) em cópia:
copia 1 traço divergente, contágio social, mutação, decaimento system2.
Fase de modelo: `step_count+=1`, treino (`DirectedTraining` sse ativo),
reset de turno + turnover na fronteira (`shift_length`), `record_metrics!`
se `step % recording_interval==0`, `check_absorption!`. RNG único
`Xoshiro(seed)` via `abmrng(model)`; seeds `base+rep`.

## 4. Design concepts
- **Emergence**: regiões/consenso emergem; nada macro é imposto.
- **Adaptation**: copiar traço majoritário-vizinho; treino sobe traço a Q.
- **Objectives**: agentes não têm função-objetivo (exceto gestor-RL F4, que
  maximiza aderência−custo); fitness ausente no nível agente.
- **Learning**: habituação system2 (ζ=0.015→0.1); Q-learning tabular só no gestor.
- **Prediction**: nenhuma no nível agente (cópia é retrospectiva); gestor-RL
  usa estado grosseiro corrente, sem modelo preditivo do futuro.
- **Sensing**: similaridade e traços do parceiro; gestor vê estado grosseiro.
- **Interaction**: diádica, mediada por ε e topologia.
- **Stochasticity**: parceiro, cópia, mutação, treino, inicialização — tudo
  via stream única seedada; 30 reps por célula.
- **Collectives/Observation**: regiões, shares, aderências, contadores.

## 5. Initialization
`seed_culture=true`: traços ∼ Uniforme{1..Q}, openness/expressiveness/rank ∼
U[0,1], motivação 1.0 (Fixed) ou 0.5 (Vroom), system2=1.0. `false`: tudo 1.
Opcional: `assign_roles!` sobrescreve motivação/openness/expressividade por
time (arquétipos; ex. médicos vs enfermeiros).

## 6. Input data
Sem série temporal de entrada. Parâmetros por varredura; `fatigue_rate`
calibrado em momentos publicados de higiene hospitalar (V1–V2:
`moments_hand_hygiene.md`); demais parâmetros em valores de protocolo
documentados por estudo.

## 7. Submodels
Axelrod+ε (núcleo); Vroom (`motivation`); contágio ponderado; dual-process;
redes (Watts-Strogatz/Barabási-Albert); `DirectedTraining`; `NormSanctions`
(norma+auditoria+gating motivacional); fadiga (drift + decaimento);
turno/reset + turnover (ruído com justificativa); papéis; Q-learning
(estados 6, ações 3, reward 10Δ−λ·taxa). Equações em `src/{core,extensions,rl}/`.
Limites conhecidos: cópia lateral conserva aderência (F2.5); 300–500 passos =
transiente (Klemm spot); contágio n.s.; punição morta nos parâmetros;
sem decaimento geral (catraca); micro-mecanismos nunca observados em humanos.

## A. Tabela de parâmetros (`ModelConfig`; defaults inertes salvo nota)

| Parâmetro | Default | Fonte |
|---|---|---|
| `grid_size`, `torus` | (61,61), false | protocolo do estudo |
| `F`, `Q`, `seed_culture` | 10, 3, false | protocolo (sweep: F∈{5,10}, Q∈{3,5,10}, seed_culture=true) |
| `neighborhood` | VonNeumann | protocolo |
| `mutation`, `mutation_rate` | NoMutation, 0.0 | protocolo (Klemm spot usa Poisson r∈{1e-4,1e-3}) |
| `barriers`, `barrier_density` | NoBarriers, 0.0 | protocolo |
| `topology`, `network_params` | Grid, {} | protocolo (SW k=6 β=0.3; SF m=3) |
| `motivation` | FixedCompliance | protocolo (Vroom nos estudos D/controle) |
| `social_contagion` | WeightedContagion | protocolo (n.s. declarado) |
| `bounded_confidence_threshold` (ε) | 0.3 | protocolo ({0.0,0.3,0.6}; gates efetivos em 1/F) |
| `intervention`, `training_rate` | NoIntervention, 0.0 | protocolo (F4: treino direcional) |
| `enforcement`, `monitoring_rate`, `sanction_cost` | NoEnforcement, 0.0, 0.1 | protocolo (P3) |
| `fatigue_rate` | 0.0 | **calibrado V2: faixa 0.003–0.006** (ponto 0.0031 instável) |
| `shift_length`, `turnover_rate` | 0, 0.0 | protocolo V2 |
| `team_count`, `n_teams` | 10, 5 | protocolo (papéis P5) |
| `max_steps`, `recording_interval` | 10000, 1 | protocolo (estudos usam 300–500) |
| `seed`, `textbook` | 42, true | `base+rep` por estudo; textbook = Axelrod puro |
| `copy_scale` | 1.0 | controle de identificação (Vroom control) |
| `scheduler` | :fastest | protocolo (:randomly em MED-7) |
