# Demo didática — Axelrod visual

`axelrod.html` é uma demo standalone (um único arquivo, sem build, sem
servidor e sem dependências) para apresentar o núcleo do CulturalDynamics em
sala de aula. A página reimplementa o núcleo Axelrod em JavaScript para
visualização; o modelo científico completo está em `src/` (Julia/Agents.jl).

## Como abrir

Abra `apresentacao/axelrod.html` no navegador. No Windows:

```powershell
Start-Process "apresentacao/axelrod.html"
```

## Cenários

| Botão | Parâmetros | O que observar |
|---|---|---|
| **Clássico** | `F5 Q3 ε0.3` | mosaico de centenas de regiões; referência do estudo |
| **Convergente** | `F5 Q3 ε0` | tende à monocultura; em 31² a coesão é lenta |
| **Fragmentado** | `F10 Q10 ε0.3` | ~900 micro-regiões com cópias raras |
| **Mosaico** | `F5 Q5 ε0.3` | blocos médios, entre consenso e poeira |

O caso extremo `F10 Q10 ε0.6` é **quase congelado por desenho**: a chance de
dois agentes serem similares o bastante é ~0,01%. Ele continua acessível pelo
slider de `ε`; a aba “Cenários” explica o regime.

## Testes

```bash
node --test "apresentacao/test/*.test.mjs"
```

11 testes, sem dependências:

- boot/reset sem exceção;
- `overlap`, `regions`, `adherence`;
- cor do grid (`(A-1)/(Q-1)`);
- `drawMetrics`/`narrate` nos 4 presets;
- smoke dos 4 presets (step avança e loop reagenda);
- pausa/retomada;
- preset → reset → play;
- `advance` incrementa `step`.

## Notas de implementação

- O loop para apenas por ação do usuário (“■ Parar e concluir”) ou por
  convergência real; **não** reintroduza detector de stall por `lastReg` —
  ele confundia o regime quase congelado com convergência.
- `narrate()` deve usar `P.N`, não `N`.
- Sliders e `preset()` usam `document.getElementById(...)`, sem depender de
  globais implícitos de elementos HTML.
- O artifact usado na apresentação é privado e expira; a fonte de verdade é
  este arquivo local.
