# Mesa de momentos — higiene das mãos hospitalar (V1, 2026-09-17)

Alvos quantitativos para calibração (P1–P3) e validação held-out (P4–P5).
Tolerância de ajuste pré-fixada: **RMSE ≤ 5pp** nos momentos P1–P3.
Critério de falha (dito antes de rodar): se o ajuste não couber na
tolerância, a tese falha — sem mover a trave.

## P1 — Nível médio de aderência: 25–40 %
- WHO 2009 (revisão): ~39 % média hospitalar.
- Dai et al. 2014 (J. Applied Psychology; 13,7M oportunidades, 35 hospitais,
  RFID Proventix): média **38 %**.
- Lash et al. 2017/2019 (24,5M eventos porta/dispenser, 19 hospitais, Gojo):
  **~25 %** intra-hospitalar (limite inferior; sensor parcial).
- Alvo: simular ponto de partida ~0,38 e preservar ordem de grandeza.

## P2 — Queda intra-turno: −8,5pp em 12h (Dai et al. 2014)
- Odds de cumprir ×0,97 por hora (≈−32 % em odds, −8,5pp em taxa p/ turno 12h).
- Magnificada por intensidade; pausas longas restauram (mais para quem
  terminou baixo); horas acumuladas na semana moderam.
- Tradução mecanicista (nossa): **fadiga = drift direcional p/ baixo**
  (cortar caminho quando cansado) + decaimento motivacional; reset no turno.
  Taxa calibrada, não assumida.

## P3 — Variância entre unidades/turnos (Lash et al.)
- Identidade do hospital/unidade entre os maiores preditores (efeitos
  facility-specific persistentes); noite e feriados levemente piores;
  gravidade de gripe aumenta aderência.
- Tradução: heterogeneidade de papéis/time + topologia como fonte de
  variância entre unidades. Alvo: replicar *ordem* (unidades diferem
  persistentemente), não valores exatos.

## P4 — Retornos decrescentes do treino (Hornbeck, CSSSA — held-out)
- 20→40 %: grandes ganhos; 80→90 %: pequenos (salvo patógeno extremo).
- Tradução: curva côncava aderência×intensidade de treino. Nossa novidade
  vs. Hornbeck: difusão social + heterogeneidade + shutoff aprendido.

## P5 — Coexistência alto/baixo aderentes (held-out)
- Super-spreaders por grupo ocupacional (BMC Infect. Dis. 2021, RFID 7 dias);
  taxas 5–81 % entre hospitais (média ~40 %).
- Tradução: distribuição com caudas (não só média) + papéis.

## Proveniência e limites
- Todos os momentos são **agregados publicados** (sem trajetórias
  individuais) → calibragem só em momentos/distribuições; declarar.
- Sem dado proprietário; sem calibragem em texto-de-política.
- Se V2 não fechar RMSE ≤5pp em P1–P3: veredito = tese falha. Parar.

## Veredito gate V2 (2026-09-17): PASS

`run_calibrate_V2.jl` (15×15 F3Q3 300p, 16 amostras × 3 reps;
`results/calibration_V2.csv`): melhor `fatigue_rate≈0.0031` com
decline 0,090 vs 0,085 e final 0,418 vs 0,415 → **RMSE 0,004** (teto 0,05,
folga 12×). Round 6: ponto 2× instável entre buscas (0,0031/0,0040/0,0057);
**faixa estável 0,003–0,006 — citar faixa**. Curva dose-resposta monotônica (corr 0,69).

Caveats registrados antes da V3: (1) n_reps=3, grade lean — ajuste grosseiro;
(2) UM parâmetro livre para DOIS alvos quase-colineares (dado init≈0,5) —
barra baixa por construção; (3) a tese vive ou morre na V3 (P4/P5 held-out),
não aqui. Suite 233/233 (histórico 2026-09-17; atual 268/268 — ver F6).
