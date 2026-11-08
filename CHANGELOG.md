# Changelog

Todas as mudanças relevantes deste projeto são registradas aqui. O formato
segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o
versionamento é semântico.

## [1.0.0] - 2026-11-08

Primeira versão publicada: repositório público com código, demo, testes e
documentação de modelo (manuscrito e material de revisão ficam no
repositório privado).

### Added

- **Demo didática standalone** `apresentacao/axelrod.html` (ABM tipo Axelrod
  com confiança limitada, fadiga, papéis, treinamento e gestor Q-learning),
  com quatro presets e narrativa.
- **Modelo científico** em Julia/Agents.jl, com sementes explícitas, goldens
  determinísticos e calibração em momentos públicos de higiene das mãos.
- **Pipeline de pesquisa**: sweeps, calibração, validação held-out,
  benchmarks e auditoria adversarial.
- **Verificação local**: 268 testes Julia, 11 testes da demo e 9 portões
  estáticos; `.zenodo.json` do programa incluído para o depósito com DOI.
