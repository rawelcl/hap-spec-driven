<#
.SYNOPSIS
  Sincroniza prompts do framework para .claude/commands/ (suporte ao Claude Code).

.DESCRIPTION
  O Claude Code le slash commands de .claude/commands/*.md.
  Este script copia os prompts de /prompts/*.prompt.md para .claude/commands/*.md,
  removendo o sufixo .prompt do nome do arquivo.

  Para projetos consumidores (framework como submodule), aponte -SourceDir para
  .specs/framework/prompts/ e -DestDir para .claude/commands/.

.PARAMETER SourceDir
  Diretorio de origem dos prompts (default: prompts/).

.PARAMETER DestDir
  Diretorio de destino (default: .claude/commands/).

.EXAMPLE
  # No repositorio do framework:
  .\sync-claude-commands.ps1

  # Em um projeto consumidor:
  .\sync-claude-commands.ps1 -SourceDir .specs/framework/prompts -DestDir .claude/commands

.NOTES
  O diretorio .claude/commands/ deve estar no .gitignore do projeto consumidor.
  No repositorio do framework, .claude/commands/ e versionado.
#>

[CmdletBinding()]
param(
  [string] $SourceDir = 'prompts',
  [string] $DestDir   = '.claude/commands'
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
  $destName = ($file.BaseName -replace '\.prompt$', '') + '.md'
  $destPath = Join-Path $DestDir $destName
  $content   = [System.IO.File]::ReadAllText($file.FullName)
  [System.IO.File]::WriteAllText(
    [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $destPath)),
    $content,
    $utf8NoBom
  )
  Write-Host "[OK]   $($file.Name) -> $destPath" -ForegroundColor Green
  $synced++
}

Write-Host ""
Write-Host "[OK] $synced comandos sincronizados em $DestDir" -ForegroundColor Cyan
Write-Host "     Reinicie o Claude Code para carregar os novos slash commands." -ForegroundColor Cyan
