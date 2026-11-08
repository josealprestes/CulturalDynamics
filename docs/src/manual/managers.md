# Para Gestores e Juristas

> Leia este capítulo sem saber programar. Cada conceito técnico vem com a
> tradução organizacional e o número que o sustenta (estudos F1–F4).

## Glossário mínimo

| Símbolo | Nome técnico | Na organização |
|---|---|---|
| `F` | nº de dimensões culturais | **Quantas regras** convivem (ex.: F=5: EPI, registro, 5S, descarte, reporte) |
| `Q` | níveis de adesão | **Granularidade da norma** (Q=3: nunca/às vezes/sempre; Q=10: escala fina) |
| `ε` | confiança limitada | **Seletividade social**: abaixo de ε de similaridade, o grupo nem ouve quem pensa diferente |
| `n_regions` | blocos culturais | **Quantos "jeitos de fazer"** coexistem ao final |
| `largest_share` | fatia do maior bloco | **Quão concentrado** está o consenso (100 % = todos iguais) |
| `partial_compliance` | aderência média | **Nota média de adesão** 0–100 % (0,5 = ponto de partida aleatório) |
| `SmallWorld` | rede mundo-pequeno | **Rede informal**: atalhos entre áreas (café, comitês, chats) |
| Treinamento | intervenção direcional | **Capacitação que empurra rumo à norma** — única força que move a média |

## Vinheta 1 — granularidade demais atomiza (F1)

`F=10, Q=10, ε=0,6` → 960,9 regiões em 961 agentes: **cada pessoa faz do seu
jeito**. Com 10 regras × 10 níveis de interpretação × grupo seletivo, o
consenso é combinatorialmente impossível. Leitura executiva: antes de
reforçar fiscalização, **simplifique a norma** (menos regras, menos níveis).
Dado: tabela completa em `study_C_results.md` (540 sims, KW p<1e-23).

## Vinheta 2 — rede informal concentra… e fragmenta (Study D)

Trocar hierarquia rígida (`Grid`) por rede informal (`SmallWorld`) mudou
fragmentação em **+59 %** (p=0,0002) — atalhos propagam *diferenças* tão bem
quanto consensos. Motivação (Vroom) sem capacitação direcional também
fragmentou (+21–26 %): gente desmotivada copia menos e congela o mosaico.
Leitura executiva: **campanha motivacional sem treinamento dirigido não
cola**; rede informal precisa de pontes *entre* blocos, não só dentro deles.

## Vinheta 3 — o gestor ótimo desliga o treino (F4)

Um gestor-RL com custo de treinamento aprendeu a política **[forte, forte,
nada, forte, nada, nada]**: treinar pesado com aderência baixa/média,
**desligar perto do teto** (custo supera o ganho). Aderência 0,50 → 0,87.
Leitura executiva: capacitação tem **retorno decrescente mensurável** —
dá para calcular quando parar. Detalhes em `study_F4_results.md`.

## FAQ

1. **Preciso instalar Julia para ver?** Não para a demo: `julia --project=. src/web_server.jl`
   → http://localhost:8080 (grade, 4 métricas, mosaico por dimensão).
2. **A simulação prova que minha norma vai pegar?** Não — ela mostra *mecanismos*
   (seletividade × granularidade × rede × treino) e ordena alavancas por efeito.
3. **Qual alavanca mexe primeiro?** ε (seletividade): pontes entre grupos que
   pensam diferente. É a nº 1 na sensibilidade (η²=0,79, F4).
4. **Por que aderência média fica ~50 % sem treino?** Cópia lateral é simétrica:
   ninguém empurra para cima. Só capacitação direcional move a média (F2.5).
5. **E compliance 100 %?** Só com treino sustentado até monocultura no teto
   (F4: 0,44 → 1,0). Sem ele, espere mosaico — gerencie os blocos, não o indivíduo.
6. **Os números são reprodutíveis?** Sim: mesmo seed, mesmo resultado
   (`seed = base + rep`, RNG Xoshiro); 268 testes verdes travam o código.
