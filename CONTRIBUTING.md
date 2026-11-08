# Contribuindo com o CulturalDynamics

Obrigado pelo interesse. Este é um projeto de pesquisa em modelagem baseada
em agentes; mudanças de comportamento precisam de evidência, teste e
documentação.

## Antes de abrir uma mudança

1. Descreva o problema e o critério de aceitação testável.
2. Diga o que **não** está no escopo.
3. Se for mudança de mecanismo científico, registre a hipótese, a seed e o
   efeito esperado.
4. Se for mudança de API pública, atualize a documentação em `docs/src/`.

## Verificação local

```bash
# Gates estáticos (segundos)
py -3 scripts/check_gates.py

# Suíte Julia (268 testes)
julia --project=. -e "using Pkg; Pkg.test()"

# Demo (11 testes, Node 20+)
node --test "apresentacao/test/*.test.mjs"

# Runner completo
powershell -ExecutionPolicy Bypass -File scripts/run_checks.ps1
# ou
bash scripts/run_checks.sh
```

O runner completo inclui documentação e o checker de números do manuscrito
no repositório privado. A versão pública não inclui o manuscrito.

## Definition of Done

- [ ] Spec curta: problema, comportamento esperado e critério de aceitação.
- [ ] Teste que falha antes e passa depois (ou justificativa explícita).
- [ ] Teste cobre o mecanismo, não apenas a linha: unidade + propriedade/
      invariante + metamórfico + golden/integração quando aplicável.
- [ ] `py -3 scripts/check_gates.py` exit 0.
- [ ] `Pkg.test()` verde quando `src/` ou `test/` mudou.
- [ ] Testes da demo verdes quando `apresentacao/` mudou.
- [ ] Documentação viva atualizada (README, ODD, DATASETS, docs/src).
- [ ] Nenhum artefato de build/resultado no índice git.
- [ ] Waiver, se houver, explícito (`GATE-WAIVER:<motivo>`) e auditável.

## Estilo

- Julia: funções pequenas, tipos estáveis nos caminhos quentes, sem RNG
  global; use `abmrng(model)`.
- Python: funções claras, sem notebook como única implementação.
- JS da demo: um arquivo standalone, sem dependências de build.
- Commits pequenos, no imperativo, sem misturar refactor com mudança de
  comportamento.

## O que não fazer

- Enfraquecer teste/gate para fazer o CI passar.
- Editar CSV de resultado para “corrigir” um número.
- Commitar `results/`, `benchmark/results/`, PDFs/auxiliares ou `Manifest.toml`.
- Adicionar dependência sem justificar versão, licença e manutenção.
- Publicar o manuscrito, pareceres ou material de revisão no repositório
  público.

## Pull requests

PRs são bem-vindos. Para mudanças grandes, abra uma issue primeiro. Inclua no
PR: motivação, o que mudou, como testar e quais limites continuam valendo.
