<#
.SYNOPSIS
  Sincroniza prompts do framework para .github/prompts/ (suporte ao VS Code Copilot).

.DESCRIPTION
  O VS Code Copilot descobre slash commands automaticamente em .github/prompts/*.prompt.md.
  Este script copia os prompts de /prompts/*.prompt.md para .github/prompts/,
  preservando o nome do arquivo com sufixo .prompt.md.

  Para projetos consumidores (framework como submodule), aponte -SourceDir para
  .specs/framework/prompts/ e -DestDir para .github/prompts/.

.PARAMETER SourceDir
  Diretorio de origem dos prompts (default: prompts/).

.PARAMETER DestDir
  Diretorio de destino (default: .github/prompts/).

.EXAMPLE
  # No repositorio do framework:
  .\sync-vscode-prompts.ps1

  # Em um projeto consumidor:
  .\sync-vscode-prompts.ps1 -SourceDir .specs/framework/prompts -DestDir .github/prompts

.NOTES
  O diretorio .github/prompts/ pode ser versionado ou adicionado ao .gitignore.
  No repositorio do framework, .github/prompts/ e versionado para facilitar
  a descoberta automatica pelo VS Code Copilot sem configuracao adicional.
#>

[CmdletBinding()]
param(
  [string] $SourceDir = 'prompts',
  [string] $DestDir   = '.github/prompts'
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $SourceDir)) {
  Write-Host "[ERRO] Diretorio de origem nao encontrado: $SourceDir" -ForegroundColor Red
  exit 1
}

$prompts = Get-ChildItem -Path $SourceDir -Filter '*.prompt.md'
if ($prompts.Count -eq 0) {
  Write-Host "[ATENCAO] Nenhum arquivo *.prompt.md encontrado em $SourceDir" -ForegroundColor Yellow
  exit 0
}

if (-not (Test-Path $DestDir)) {
  New-Item -ItemType Directory -Force -Path $DestDir | Out-Null
  Write-Host "[OK]   dir $DestDir" -ForegroundColor Green
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$synced = 0

foreach ($file in $prompts) {
  $destPath = Join-Path $DestDir $file.Name
  $content  = Get-Content -Path $file.FullName -Raw -Encoding UTF8

  [System.IO.File]::WriteAllText(
    (Resolve-Path $DestDir).Path + '\' + $file.Name,
    $content,
    $utf8NoBom
  )

  Write-Host "[OK]   $($file.Name)" -ForegroundColor Green
  $synced++
}

Write-Host ""
Write-Host "[OK] $synced prompt(s) sincronizado(s) em $DestDir" -ForegroundColor Cyan
