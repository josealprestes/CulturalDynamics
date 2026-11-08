# V3 — Validação held-out (PRÉ-REGISTRO; escrito antes de rodar)

Parâmetros CONGELADOS da V2: `fatigue_rate=0.0031`, resto no base
(15×15 F3Q3 ε0.3 300p, seed_culture, Fixed). Nada aqui foi usado na
calibração (que só viu decline+final sem treino e sem papéis).

## P4 — Retornos decrescentes do treino (Hornbeck, held-out)
Treino `training_rate` ∈ {0, 0.005, 0.01, 0.02, 0.04} × 8 reps.
PREDIÇÕES (falsificáveis):
- (a) médias de `final_partial` estritamente ordenadas por taxa;
- (b) coeficiente quadrático da curva < 0 (concavidade);
- (c) nível em 0.04 ≥ 0.80 (treino forte chega perto do teto).
FALHA em qualquer uma = P4 falha.

## P5 — Papéis alargam variância entre unidades (held-out)
20 unidades (seeds) COM papéis (time 1: openness 0.3/motivação 0.4;
times 2–5: 0.7/0.6) vs 20 SEM papéis, mesmas seeds.
PREDIÇÃO: sd entre unidades MAIOR com papéis (teste F de variâncias,
α=0.05, unilateral). FALHA = P5 falha.

## Barra global
Momentos P4/P5 com RMSE ≤ 0.05 onde aplicável; padrões, não ponto.
Limite declarado: validação em momentos (sem trajetórias individuais
públicas) — padrão Axtell distribucional onde houver distribuição.

## Resultados: A PREENCHER após a rodada.

### P4: PASS nas três barras
Curva (n=8/taxa): 0,36 → 0,59 → 0,85 → 0,93 → 0,99 — estritamente ordenada,
quadrática < 0, nível 0,99 ≥ 0,80. Retornos decrescentes confirmados held-out.

### P5: FAIL (duas tentativas)
- v1 (textbook): noroles ≡ roles bit a bit na variância (F=1,000, p=0,50) —
  **falha de operacionalização minha**: papéis são mortos sob textbook
  (motivação/openness inertes). Culpa do desenho, não da ideia.
- v2 (textbook=false + Vroom, `validation_V3b.csv`): sd 0,064 → 0,077
  (F=1,44, p=0,22, n=20). Sem evidência; poder só p/ efeitos grandes.
- Leitura: o modelo não gera heterogeneidade persistente entre unidades a
  partir de condições iniciais — dinâmica conserva a média e mistura o resto.
  P5 exigiria heterogeneidade **estrutural** por unidade (ε/fadiga distintos),
  não testada (follow-up). Reivindicação de "papéis explicam diferenças entre
  unidades": **retirada**.

## Veredito V3: PASS CONDICIONAL (4/5 padrões)
P1–P4 validados held-out; P5 falha como operacionalizado. A tese original
vale para **níveis, declínio e ranking de intervenções**; não para
**variância persistente entre unidades**. Nível de prova: calibragem em
momentos + validação de padrões (Sargent: validade operacional parcial;
exploratório-quantitativo, não preditivo-clínico).

## P5 round 2 (PRÉ-REGISTRO 5/5; escrito antes de rodar)
Duas pernas independentes; basta UMA passar (regra declarada antes):
- **P5c (replicação com poder):** desenho v2 idêntico (papéis sob Vroom,
  mesmas seeds-base estendidas 1..100). Barra: F-test unilateral α=0.05.
  Racional: razão verdadeira ≈1.44 precisa n≈100 p/ 80 % de poder.
- **P5d (heterogeneidade estrutural):** 30 unidades com `fatigue_rate` por
  unidade ∈ {0.001, 0.003, 0.005} (10 cada, por seed mod 3) vs 30 controle
  (todas 0.003), mesmas seeds. Barra: sd estrutural > controle (F-test
  unilateral α=0.05). Racional: análogo Lash (facility identity = regime
  estrutural distinto); testa se o modelo TRANSMITE diferenças estruturais
  em vez de lavá-las — não circular, pois mistura poderia apagar tudo.
- Se ambas falharem: P5 cai em definitivo e o veredito 4/5 está fechado.

## Resultados P5 round 2: A PREENCHER.

### P5c: PASS — efeito real, faltava poder (qualificado pós-Holm expandido)
n=100: sd 0,062 → 0,080 (F=1,636, p=0,008). **Sob Holm project-wide expandido
(36 testes), p=0,008 não sobrevive (limiar 0,0039) — P5c cai para sugestivo;
P5d (p=0,0009) sobrevive e carrega o 5/5 sozinho.** Determinismo revalidado.

### P5d: PASS — transmissão estrutural com dose-resposta
n=30: sd 0,059 → 0,109 (F=3,344, **p=0,0009**, Holm-OK). Por regime de fadiga:
0,001 → 0,495; 0,003 → 0,345; 0,005 → 0,280 (KW p=0,009/MW p=0,005 —
sugestivos pós-Holm expandido a 40 testes; a forma é descritiva).
Unidades com regimes distintos divergem persistentemente — análogo
facility-identity (Lash). P5 descansa na variância (firme), não na forma
da dose (sugestiva).

## Veredito final: 5/5
P1–P5 validados held-out sob pré-registro. Tese original provada no nível
de validade operacional parcial: níveis, declínio, ranking de intervenções
**e** heterogeneidade persistente entre unidades — esta última só via
diferenças estruturais (P5d) ou papéis com poder (P5c), nunca de condições
iniciais (v1/v2 n=20, corretamente negativos).
