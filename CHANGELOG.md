# Changelog

Todas as mudanças relevantes deste projeto são registradas aqui. O formato
segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o
versionamento semântico.

## [Unreleased]

## [1.3.2] — 2026-11-08

### Security

- `src/web_server.jl` escuta em **127.0.0.1** por padrão, com opt-in explícito por
  `CD_HOST` (ou segundo argumento) e aviso no console quando a interface é de rede:
  antes subia em `0.0.0.0` sem autenticação enquanto o README anunciava localhost.
- `POST /simulate` valida o contrato da entrada — grade 5–101, F 1–15, Q 2–10,
  passos 1–2000, épsilon 0–1, mutação 0–1 — e responde 400 com o campo violado;
  corpo acima de 4 KB responde 413. Antes a grade vinha crua do JSON e uma
  requisição pequena pedia uma alocação que derrubava o processo.
- A resposta 500 devolve mensagem genérica; o detalhe da exceção fica no log do
  servidor, em vez de ir no corpo para o cliente.


## [1.3.1] — 2026-11-08

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

### Changed

- Primeira versão publicada: repositório público com código, demo, testes e documentação
  de modelo (manuscrito e material de revisão ficam no repositório privado).
- `.zenodo.json` do software incluído para o depósito com DOI.

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
