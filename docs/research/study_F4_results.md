# F4 — Intervenção direcional + sensibilidade + RL (2026-09-17)

## F4a — `DirectedTraining`: a única força direcional

Cópia lateral conserva aderência média (F2.5: E[aderência]=0,5 em todos os
mecanismos). `DirectedTraining` (`src/core/types.jl`): a cada passo, cada
agente é treinado w.p. `training_rate`; treino sobe um traço aleatório
abaixo de Q em um nível e reseta o agente para System 2 (procedimento novo
→ modo deliberado, Sharpanskykh & Haest 2016). Default `NoIntervention`
é inerte (testes de igualdade).

Smoke (15×15 F5Q3 200p seed 11): controle partial 0,435 / 71 regiões →
treino 0,05: **1,0 / 1 região** (monocultura no teto). Direcional confirmado.

## F4b — Sensibilidade η² (Sobol n=64, 21×21 200p; `run_sensitivity_F4.jl`)

| parâmetro | η² (n_regions) | η² (partial_compl.) |
|---|---|---|
| ε (bounded_confidence) | **0,788** | 0,064 |
| F | 0,393 | 0,231 |
| mutation_rate | 0,369 | 0,116 |
| Q | 0,086 | 0,095 |

Leitura: **seletividade social é a alavanca estrutural nº 1** (quase 2× a
segunda); nº de regras e ruído empatam; granularidade Q pesa menos.
Nenhum parâmetro estrutural move aderência (todos η² pequenos) — terceira
corroboração da conservação F2.5. Estimador η² é screening grosseiro
(3 bins); vale o ranking, não a magnitude. Nota metodológica: primeira
rodada deu mutation η²=0,27 espúrio porque a estratégia era `NoMutation`
(taxa inerte); corrigido para `PoissonMutation` quando taxa>0.

**Vinheta:** "Se só posso mexer em 1 alavanca estrutural, mexa na
seletividade (ε): pontes entre grupos que pensam diferente. Granularidade
das regras (Q) é a que menos paga."

## F4c — Q-learning tabular do gestor (`src/rl/training.jl`)

Estado grosseiro 6 (aderência baixa/média/alta × fragmentado/consolidado);
ações = intensidade de treino {0 / 0,005 / 0,02}; reward por bloco de 25
passos = 10×Δaderência − 5×taxa. 11×11 F3Q3 150p, 25 episódios:

- Política aprendida **[3,3,1,3,1,1]**: treino forte com aderência
  baixa/média, **desligado perto do teto** — shutoff por custo, exatamente
  o comportamento ótimo teorizado.
- Aderência final **0,865** na seed default (nunca-treinar 0,494; sempre-0,02 0,849):
  aprende o nível do baseline forte economizando custo no fim. Round 6:
  3 treinos dão 0,64–0,90 com mesma estrutura shutoff — **citar faixa +
  estrutura, nunca só o ponto**.
- `train_rl` legado preservado (chaves `:rewards`, `:final_compliance`).

## Limitações

- Sem esquecimento/decaimento, aderência é catraca (só sobe); shutoff
  aprendido é válido, mas dinâmica mais rica exige decaimento ou mutação
  direcionada (follow-up).
- DQN profundo adiado: tabular resolve o problema do gestor com
  interpretabilidade total; DQN exigiria GPU/cluster sem ganho de tese.
- Contágio segue n.s. (F2.5); intervenção direcional não depende dele.
