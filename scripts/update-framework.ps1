<#
.SYNOPSIS
  Atualiza o framework Spec-Driven Hapvida vinculado como submodule em .specs/framework/.

.DESCRIPTION
  Conforme ADR-012, o framework e consumido como git submodule. Este script:
    1. Faz fetch + checkout do ref desejado em .specs/framework/
    2. Atualiza .specs/.framework.json com novo commit hash e data
    3. Mostra diff resumido para revisao

  Nao faz commit automatico - voce decide quando commitar (em PR proprio).

.PARAMETER Ref
  Branch ou tag para checkout (default: main).

.PARAMETER Remote
  Atualiza para o HEAD remoto do branch atual do submodule (default: $true).

.EXAMPLE
  .\update-framework.ps1
  .\update-framework.ps1 -Ref v0.3.0

.NOTES
  Apos rodar, faca:
    git add .specs/framework .specs/.framework.json
    git commit -m "WI-XXXX: chore(framework): bump para <ref>"
#>

[CmdletBinding()]
param(
  [string] $Ref = 'main'
)

$ErrorActionPreference = 'Stop'
$today = (Get-Date -Format 'yyyy-MM-dd')

if (-not (Test-Path '.specs/framework')) {
  Write-Host "[ERRO] .specs/framework/ nao existe. Rode init-spec-project.ps1 primeiro." -ForegroundColor Red
  exit 1
}

if (-not (Test-Path '.specs/.framework.json')) {
  Write-Host "[ATENCAO] .specs/.framework.json ausente - sera criado." -ForegroundColor Yellow
}

Write-Host "[..] Atualizando submodule .specs/framework para ref '$Ref'..." -ForegroundColor Cyan

Push-Location .specs/framework
try {
  $oldCommit = (& git rev-parse HEAD).Trim()

  & git fetch origin
  if ($LASTEXITCODE -ne 0) { throw "git fetch falhou" }

  & git checkout $Ref
  if ($LASTEXITCODE -ne 0) { throw "git checkout $Ref falhou" }

  # Se for branch, faz pull para HEAD remoto
  $isBranch = (& git show-ref --verify --quiet "refs/heads/$Ref"; $LASTEXITCODE -eq 0)
  if ($isBranch) {
    & git pull --ff-only origin $Ref
    if ($LASTEXITCODE -ne 0) { throw "git pull falhou" }
  }

  $newCommit = (& git rev-parse HEAD).Trim()
}
finally {
  Pop-Location
}

if ($oldCommit -eq $newCommit) {
  Write-Host "[OK] Framework ja esta no commit mais recente ($newCommit)." -ForegroundColor Green
  exit 0
}

Write-Host "[OK] Framework atualizado:" -ForegroundColor Green
Write-Host "       de  $oldCommit"
Write-Host "       para $newCommit"

# Atualiza manifesto
$repoUrl = (& git -C .specs/framework remote get-url origin).Trim()
$manifestContent = @"
{
  "framework": "hap-spec-driven",
  "repo": "$repoUrl",
  "ref": "$Ref",
  "commit": "$newCommit",
  "pinned_at": "$today",
  "adr": "ADR-012"
}
"@
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$absPath = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) '.specs/.framework.json'))
[System.IO.File]::WriteAllText($absPath, $manifestContent, $utf8NoBom)
Write-Host "[OK] .specs/.framework.json atualizado" -ForegroundColor Green

Write-Host ""
Write-Host "Diff resumido (commits novos):" -ForegroundColor Cyan
& git -C .specs/framework log --oneline "$oldCommit..$newCommit" | Select-Object -First 20

Write-Host ""
Write-Host "Proximos passos:" -ForegroundColor Cyan
Write-Host "  1. Revise mudancas em .specs/framework/ (especialmente prompts/, templates/, adr/)"
Write-Host "  2. Atualize specs/designs/tasks afetados se houver breaking changes"
Write-Host "  3. Commit:"
Write-Host "       git add .specs/framework .specs/.framework.json"
Write-Host "       git commit -m 'WI-XXXX: chore(framework): bump para $Ref ($newCommit)'"
