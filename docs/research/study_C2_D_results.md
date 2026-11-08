# Sprint 3 — Resultados complementares

## C2 — Transição de fase por ε (F=5 Q=3 21×21 300p 15 reps)

ε 0.00–0.40 ≈142–144 regiões (platô). 0.45 salta para 180. 0.65 salta para 402. 0.85→438 e estabiliza até 1.0. Degraus em 0.40→0.45 e 0.60→0.65 — **são a quantização de ε em múltiplos de 1/F** (com F=5, o gate só muda em 0.2/0.4/0.6…; provado bit-idêntico em `auditoria adversarial (material privado)` round 3). Fig.6 `fig6_phase_epsilon.png`.

## D — Ablação (F=5 Q=3 21×21 300p eps0.3 8 reps por condição)

| condição | n_regions |
|---|---|
| NoContagion+Fixed+Grid | 145,9 |
| Weighted+Fixed+Grid | 145,9 |
| Weighted+Vroom+Grid | 145,9 |
| NoContagion+Vroom+Grid | 145,9 |
| NoContagion+Fixed+SmallWorld | 247,5 |
| Weighted+Fixed+SmallWorld | 247,5 |

Só topologia moveu agulha (+70 % com SmallWorld). Vroom e WeightedContagion não alteraram fragmentação neste ponto do espaço (F pequeno, Q baixo). Fig.7 `fig7_ablation.png`.

> **Errata (resolvida em F2.5, 2026-09-17):** a causa era ausência de acoplamento —
> motivação/contágio atualizavam estado interno sem realimentar a probabilidade
> de cópia. Ver §D-revisado abaixo. Valores acima preservados como baseline stubs.

## D-revisado — Ablação com acoplamento (F2.5, F=5 Q=3 21×21 300p ε0.3, 8 reps, `textbook=false`)

`copy_probability` (`src/core/types.jl`): `textbook=true` → Axelrod puro
(bit-idêntico ao baseline, verificado); `textbook=false` → openness,
motivação Vroom e peso system2 modulam `p_copy`. Métrica nova
`partial_compliance` (aderência média normalizada ∈ [0,1]; `results/study_D_sweep.csv`).

| condição | n_regions | largest_share | partial_compl. | motivação |
|---|---|---|---|---|
| NoContagion+Fixed+Grid | 165,6 ±10,8 | 0,056 | 0,482 | 1,000 |
| Weighted+Fixed+Grid | 165,6 ±10,8 | 0,056 | 0,482 | 1,000 |
| Weighted+Vroom+Grid | 208,8 ±16,1 | 0,028 | 0,492 | 0,415 |
| NoContagion+Vroom+Grid | 200,9 ±12,7 | 0,035 | 0,503 | 0,416 |
| NoContagion+Fixed+SmallWorld | 263,5 ±10,8 | 0,027 | 0,492 | 1,000 |
| Weighted+Fixed+SmallWorld | 263,5 ±10,8 | 0,027 | 0,492 | 1,000 |

- **Vroom fragmenta +21–26 % vs Fixed** (MW p<0.001): motivação baixa → menos
  cópias → menos convergência. Mecanismo morde — errata encerrada.
- **Contágio n.s.**: sob Vroom p=0.20 (n=8); sob Fixed idêntico por construção
  (motivação exógena fixa). Aberto: reps maiores ou acoplamento mais forte.
- **Topologia preservada**: SmallWorld +59 % regiões (p=0.0002).
- **Achado de conservação**: `partial_compliance` ≈ 0,48–0,50 em TODAS as
  condições (p=0.23/0.79). Esperado: cópia lateral é simétrica em média
  (par focal→parceiro equiprovável ao inverso), logo E[aderência] = valor
  inicial 0,5 em qualquer mecanismo. Papel redefinido: constante de
  validação do caráter não-direcional + métrica de *eficácia de intervenção
  direcional* (F4/RL), única força capaz de movê-la. Outcomes estruturais
  (`n_regions`, `largest_share`) seguem primários para difusão espontânea.

## Scale spot (1 rep por grade, F5Q3 eps0.3 vs F10Q3 eps0.6)

- F5Q3 eps0.3: 21×21 132 → 31×31 298 → 61×61 1420
- F10Q3 eps0.6: 21×21 346 → 31×31 740 → 61×61 3015
Ranking preservado ao escalar N: mais N → mais regiões absolutas, largest_share cai (1 % em 61×61).
