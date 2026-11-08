#!/usr/bin/env bash
# Verificação local do CulturalDynamics (versão pública).
#
# Uso:
#   scripts/run_checks.sh          # gates + suíte Julia + demo
#   scripts/run_checks.sh --full   # inclui a documentação
#
# O checker número-a-CSV do manuscrito roda apenas no repositório privado.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

JULIA="${JULIA:-$HOME/.juliaup/bin/julia}"
command -v "$JULIA" >/dev/null 2>&1 || JULIA="julia"
FULL=0
[ "${1:-}" = "--full" ] && FULL=1

falhas=()
etapa() { printf '\n=== %s ===\n' "$1"; }
concluir() {
  if [ "$2" -eq 0 ]; then printf '[OK]   %s\n' "$1"
  else printf '[FAIL] %s (rc=%s)\n' "$1" "$2"; falhas+=("$1"); fi
}

etapa "1/4 Gates públicos G1-G9"
python3 scripts/check_gates.py
concluir "gates públicos" $?

etapa "2/4 Suíte Julia (Pkg.test)"
"$JULIA" --project=. -e 'using Pkg; Pkg.test()'
concluir "suíte Julia" $?

etapa "3/4 Testes da demo (Node, stdlib)"
if command -v node >/dev/null 2>&1; then
  node --test "apresentacao/test/*.test.mjs"
  concluir "testes da demo" $?
else
  printf '[SKIP] node não encontrado\n'
fi

if [ "$FULL" -eq 1 ]; then
  etapa "4/4 Documentação (Documenter)"
  "$JULIA" --project=docs/ docs/make.jl
  concluir "docs" $?
else
  printf '\n(4/4 pulado - use --full para a documentação)\n'
fi

printf '\n----------------------------------------\n'
if [ "${#falhas[@]}" -eq 0 ]; then
  printf 'TUDO VERDE\n'
  exit 0
fi
printf 'VERMELHO: %s\n' "${falhas[*]}"
exit 1
