# Verificação local do CulturalDynamics (versão pública).
#
# Uso:
#   scripts/run_checks.ps1          # gates + suíte Julia + demo
#   scripts/run_checks.ps1 -Full    # inclui a documentação
#
# O checker número-a-CSV do manuscrito roda apenas no repositório privado.
param([switch]$Full)

$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

$falhas = @()
function Etapa($nome) { Write-Host "`n=== $nome ===" }
function Concluir($nome, $rc) {
  if ($rc -eq 0) { Write-Host "[OK]   $nome" }
  else { Write-Host "[FAIL] $nome (rc=$rc)"; $script:falhas += $nome }
}

Etapa "1/4 Gates públicos G1-G9"
py -3 scripts/check_gates.py
Concluir "gates públicos" $LASTEXITCODE

Etapa "2/4 Suíte Julia (Pkg.test)"
julia --project=. -e "using Pkg; Pkg.test()"
Concluir "suíte Julia" $LASTEXITCODE

Etapa "3/4 Testes da demo (Node, stdlib)"
if (Get-Command node -ErrorAction SilentlyContinue) {
  node --test "apresentacao/test/*.test.mjs"
  Concluir "testes da demo" $LASTEXITCODE
} else {
  Write-Host "[SKIP] node não encontrado"
}

if ($Full) {
  Etapa "4/4 Documentação (Documenter)"
  julia --project=docs/ docs/make.jl
  Concluir "docs" $LASTEXITCODE
} else {
  Write-Host "`n(4/4 pulado - use -Full para a documentação)"
}

Write-Host "`n----------------------------------------"
if ($falhas.Count -eq 0) { Write-Host "TUDO VERDE"; exit 0 }
Write-Host "VERMELHO: $($falhas -join ', ')"
exit 1
