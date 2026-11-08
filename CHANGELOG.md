# Changelog

Todas as mudanças relevantes deste projeto são registradas aqui. O formato
segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o
versionamento semântico.

## [Unreleased]

### Added

- Demo didática standalone `apresentacao/axelrod.html`, com quatro presets
  (Clássico, Convergente, Fragmentado, Mosaico), métricas ao vivo e narrativa.
- Suíte de 11 testes da demo com `node --test`, sem dependências.
- Runner local `scripts/run_checks.ps1` / `scripts/run_checks.sh` com gates,
  suíte Julia e testes da demo.
- Skill `scientific-software-testing` e nota de SOTA de engenharia de
  software/testes (`docs/research/SOTA_SE_2026-11-06.md`).
- Guia público de reprodutibilidade (`docs/REPRODUTIBILIDADE.md`).

### Fixed

- Demo: `narrate()` referenciava `N` em vez de `P.N`, lançando
  `ReferenceError` no `reset()` e interrompendo o loop no primeiro
  `drawMetrics`.
- Demo: `preset()` e sliders não dependem mais de globais implícitos de
  elementos HTML.
- Demo: cores do grid corrigidas para `(A-1)/(Q-1)`.
- Demo: preset “Fragmentado” passou de `F10 Q10 ε0.6` (quase congelado) para
  `F10 Q10 ε0.3`, mantendo a fragmentação visível; o caso extremo segue
  documentado.
- A1: `RandomBarriers` agora é construído com `abmrng(model)` e testado
  (determinismo + conectividade).
- A2: removidas as duplicatas mortas de `maybe_mutate!`,
  `apply_social_contagion!` e `build_network_overlay!`; o core é o dono único.
- A3: `absorbed_at` registra o primeiro passo de absorção; a coluna legada
  `steps_to_absorption` foi preservada.
- A4: o paper explicita que o alvo de nível é o pós-declínio `0.415`, não o
  P1 de campo `0.38`; o checker ganhou dois checks.
- A5: ordem treino/shift da Tabela 1 alinhada ao código.
- Contagens vivas reconciliadas para **268 testes** e **74 checks**.

### Changed

- README reescrito para a versão pública, com contexto acadêmico IA006J,
  limites metodológicos e seção de vibe coding.
- `DATASETS.md`, `TRACE.md` e documentação viva sincronizados com as
  contagens atuais.
- `CITATION.cff` sem DOI placeholder.

## [1.3.0] — 2026-09-18

### Added

- Manuscrito IEEE TCSS full-length (11pp, 34 referências) no repositório
  privado.
- Corpus de 27 CSVs: Study C, calibração, validação, benchmarks, red-team,
  RL e robustez.
- ODD 2020, TRACE, vODD e trilha de auditoria adversarial.
- Suíte de 251 testes Julia, 72 checks de números e 9 gates estáticos.
- Calibração em momentos públicos de higiene das mãos (38% de aderência;
  −8,5 pp/turno), com banda de fadiga 0.003–0.006.

### Notes

- O workflow remoto de CI foi removido em 2026-10-20 por billing da conta; a
  verificação passou a ser local.
- O corpus e o manuscrito são mantidos no repositório privado; a versão
  pública contém código, demo, testes e documentação de modelo.
