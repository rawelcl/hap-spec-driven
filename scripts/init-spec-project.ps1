<#
.SYNOPSIS
  Inicializa a estrutura .specs/ no repositorio de um squad que adota o
  Framework Spec-Driven Hapvida v0.2.

.DESCRIPTION
  Cria apenas o que e responsabilidade do squad:
    - .specs/project/STATE.md          (OBRIGATORIO - ADR-009)
    - .vscode/mcp.json                 (Local Azure DevOps MCP Server)
    - .github/copilot-instructions.md  (aponta para SKILL.md do framework)
  Opcionais via flag:
    - .specs/project/PROJECT.md        (-WithProject)
    - .specs/project/ROADMAP.md        (-WithRoadmap)
    - .specs/codebase/ + knowledge-base/ (-Brownfield)

  NAO copia artefatos do framework (SKILL.md, prompts, templates, ADRs).
  Esses ficam no repositorio central hapvida-spec-driven.

.PARAMETER SquadName
  Nome do squad/projeto. Usado como titulo no STATE.md.

.PARAMETER Stack
  Stack predominante: PLSQL | Java | DotNet | Mista.

.PARAMETER AdoOrg
  Slug da organizacao no Azure DevOps (default: hapvida).

.PARAMETER AreaAtuacao
  Area de negocio (Comercial, Autorizacao, etc).

.PARAMETER WithProject
  Cria .specs/project/PROJECT.md vazio.

.PARAMETER WithRoadmap
  Cria .specs/project/ROADMAP.md vazio.

.PARAMETER Brownfield
  Cria esqueleto de .specs/codebase/ e .specs/codebase/knowledge-base/.

.PARAMETER FrameworkRepo
  URL do repositorio do framework (default: https://github.com/rawelcl/hap-spec-driven.git).
  Adicionado como git submodule em .specs/framework/ conforme ADR-012.

.PARAMETER FrameworkRef
  Branch ou tag do framework para pinagem inicial (default: main).

.PARAMETER NoSubmodule
  Pula o passo de adicionar o git submodule (uso em testes ou ambientes sem rede).

.PARAMETER Force
  Sobrescreve arquivos existentes. Sem essa flag, arquivos existentes sao
  preservados e o script avisa.

.EXAMPLE
  .\init-spec-project.ps1 -SquadName "Comercial" -Stack PLSQL -AreaAtuacao "Comercial - venda de planos" -Brownfield

.EXAMPLE
  iwr https://raw.githubusercontent.com/rawelcl/hap-spec-driven/main/scripts/init-spec-project.ps1 -OutFile init.ps1
  .\init.ps1 -SquadName "Autorizacao" -Stack Java
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory)] [string] $SquadName,
  [ValidateSet('PLSQL','Java','DotNet','Mista')] [string] $Stack = 'Mista',
  [string] $AdoOrg = 'hapvida',
  [string] $AreaAtuacao = 'Comercial',
  [switch] $WithProject,
  [switch] $WithRoadmap,
  [switch] $Brownfield,
  [string] $FrameworkRepo = 'https://github.com/rawelcl/hap-spec-driven.git',
  [string] $FrameworkRef = 'main',
  [switch] $NoSubmodule,
  [switch] $Force
)

$ErrorActionPreference = 'Stop'
$today = (Get-Date -Format 'yyyy-MM-dd')

function Write-FileSafe {
  param([string]$Path, [string]$Content)
  if ((Test-Path $Path) -and -not $Force) {
    Write-Host "[SKIP] $Path ja existe (use -Force para sobrescrever)" -ForegroundColor Yellow
    return
  }
  $dir = Split-Path -Parent $Path
  if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
  }
  # UTF-8 sem BOM
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  $absPath = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
  [System.IO.File]::WriteAllText($absPath, $Content, $utf8NoBom)
  Write-Host "[OK]   $Path" -ForegroundColor Green
}

# 1. Diretorios base
$dirs = @('.specs/project', '.specs/features', '.vscode', '.github')
foreach ($d in $dirs) {
  if (-not (Test-Path $d)) {
    New-Item -ItemType Directory -Force -Path $d | Out-Null
    Write-Host "[OK]   dir $d" -ForegroundColor Green
  }
}

# 2. STATE.md (esqueleto conforme references/state-management.md)
$stateContent = @"
# State - $SquadName

**Last Updated:** $today
**Current Work:** -

---

## Recent Decisions (ultimos 60 dias)

<!-- Adicionar AD-NNN para cada decisao local relevante. -->
<!-- Promover para ADR corporativa quando o impacto for cross-squad. -->

---

## Active Blockers

<!-- B-NNN com Discovered, Impact, Workaround, Resolution, Owner. -->

---

## Lessons Learned

<!-- L-NNN com Context, Problem, Solution, Prevents. -->

---

## Quick Tasks Completed

| # | Description | Date | Commit | Status |
|---|---|---|---|---|

> Quick Mode esta fora do escopo do piloto v0.2 (ADR-008).

---

## Deferred Ideas

- [ ] (vazio)

---

## Todos

- [ ] (vazio)

---

## Preferences

**Model Guidance Shown:** never
**Skills SIGO availability:** no
**MCP do ADO configurado:** yes
**Stack:** $Stack
**Area de atuacao:** $AreaAtuacao
"@
Write-FileSafe -Path '.specs/project/STATE.md' -Content $stateContent

# 3. .vscode/mcp.json
$mcpContent = @"
{
  `"servers`": {
    `"azure-devops`": {
      `"command`": `"npx`",
      `"args`": [`"-y`", `"@azure-devops/mcp`", `"$AdoOrg`"]
    }
  }
}
"@
Write-FileSafe -Path '.vscode/mcp.json' -Content $mcpContent

# 4. .github/copilot-instructions.md
$copilotContent = @"
# Copilot Instructions

Este projeto usa o **Framework Spec-Driven Hapvida v0.2**.

## Regra fundamental

Quando criar specs, designs, tasks ou implementar codigo, siga as instrucoes do framework
disponivel em ``.specs/framework/SKILL.md`` (vinculado como git submodule, ver ADR-012).

Se o submodule nao estiver populado, rode: ``git submodule update --init --recursive``.

Versao pinada do framework: ver ``.specs/.framework.json``.

## Contexto do squad

- **Squad:** $SquadName
- **Stack:** $Stack
- **Area de atuacao:** $AreaAtuacao
- **AdoOrg:** $AdoOrg

## Guardrails inegociaveis

- ``[GUARDRAIL]`` NUNCA acessar dados de beneficiario via MCP Oracle - codigo PL/SQL sempre via WinCVS tag PRODUCAO (ADR-007)
- ``[GUARDRAIL]`` MCP Oracle autorizado APENAS para dicionario read-only (``dba_*``, ``dba_source``)
- ``[GUARDRAIL]`` Anonimizacao obrigatoria de PII de beneficiario
- ``[GUARDRAIL]`` Toque em area regulada exige ``[ANS]`` + citacao de norma
- ``[GUARDRAIL]`` ADR aplicavel ausente -> ``[ADR-AUSENTE]`` + bloquear ate proposta de ADR

## Convencoes

- Conventional Commits + WI prefix: ``WI-<id>: <type>(<scope>): <description>``
- Tokens textuais: ``[ATENCAO]``, ``[BLOQUEADO]``, ``[REVISAO]``, ``[ANS]``, ``[REF: ...]``, ``[ADR-AUSENTE]``, ``[GUARDRAIL]`` - sem emojis em artefatos formais
- UTF-8 sem BOM em todos os arquivos gerados
"@
Write-FileSafe -Path '.github/copilot-instructions.md' -Content $copilotContent

# 5. Opcionais
if ($WithProject) {
  $projectContent = @"
# $SquadName

**Vision:** (preencher)
**For:** (publico-alvo)
**Solves:** (problema)

## Goals
- [ ]

## Tech Stack
- $Stack

## Scope
## Constraints
"@
  Write-FileSafe -Path '.specs/project/PROJECT.md' -Content $projectContent
}

if ($WithRoadmap) {
  $roadmapContent = @"
# Roadmap - $SquadName

## Now
## Next
## Later
"@
  Write-FileSafe -Path '.specs/project/ROADMAP.md' -Content $roadmapContent
}

if ($Brownfield) {
  $brownDirs = @('.specs/codebase', '.specs/codebase/knowledge-base')
  foreach ($d in $brownDirs) {
    if (-not (Test-Path $d)) {
      New-Item -ItemType Directory -Force -Path $d | Out-Null
      Write-Host "[OK]   dir $d" -ForegroundColor Green
    }
  }
  Write-Host "[INFO] Brownfield: rode o prompt 'Map codebase' para preencher os 7 docs em .specs/codebase/" -ForegroundColor Cyan
  if ($Stack -eq 'PLSQL') {
    if (-not (Test-Path '.specs/reverse-engineering')) {
      New-Item -ItemType Directory -Force -Path '.specs/reverse-engineering' | Out-Null
      Write-Host "[OK]   dir .specs/reverse-engineering" -ForegroundColor Green
    }
    Write-Host "[INFO] PL/SQL: rode 'baseline-reverse-engineering' antes de criar specs de refatoracao (ADR-011)" -ForegroundColor Cyan
  }
}

# 6. .vscode/settings.json - paths fixos para o framework (ADR-012)
$settingsContent = @"
{
  `"chat.promptFiles`": true,
  `"chat.promptFilesLocations`": {
    `".specs/framework/prompts`": true
  },
  `"chat.instructionsFilesLocations`": {
    `".specs/framework/instructions`": true,
    `".github/instructions`": true
  },
  `"files.encoding`": `"utf8`",
  `"files.eol`": `"`\n`"
}
"@
Write-FileSafe -Path '.vscode/settings.json' -Content $settingsContent

# 7. .vscode/extensions.json
$extensionsContent = @"
{
  `"recommendations`": [
    `"github.copilot`",
    `"github.copilot-chat`",
    `"ms-azure-devops.azure-pipelines`",
    `"oracle.sql-developer-for-vscode`"
  ]
}
"@
Write-FileSafe -Path '.vscode/extensions.json' -Content $extensionsContent

# 8. .github/pull_request_template.md
$prTemplate = @"
# WI-<id>: <titulo curto>

## Contexto

<!-- Link para work item ADO e resumo do problema -->

## Mudancas

- [ ] Spec atualizada em ``.specs/features/WI-<id>-<slug>/spec.md``
- [ ] Design atualizado em ``.specs/features/WI-<id>-<slug>/design.md``
- [ ] Tasks marcadas em ``.specs/features/WI-<id>-<slug>/tasks.md``
- [ ] Codigo implementado
- [ ] Testes

## Checklist Spec-Driven

- [ ] Knowledge Verification Chain executada (ADR-006)
- [ ] ADR aplicavel referenciada (ou ``[ADR-AUSENTE]`` registrado)
- [ ] ``[ANS]`` + norma citada se area regulada
- [ ] Anonimizacao de PII de beneficiario verificada
- [ ] Conventional Commits + WI prefix em todos os commits
- [ ] Snapshot da spec anexado ao work item (ADR-002)
- [ ] Versao do framework em ``.specs/.framework.json`` adequada

## Riscos

<!-- Areas reguladas, dados de beneficiario, integracoes criticas -->
"@
Write-FileSafe -Path '.github/pull_request_template.md' -Content $prTemplate

# 9. Git submodule do framework + .framework.json (ADR-012)
if (-not $NoSubmodule) {
  $isGitRepo = (Test-Path '.git') -or ((git rev-parse --is-inside-work-tree 2>$null) -eq 'true')
  if (-not $isGitRepo) {
    Write-Host "[SKIP] Submodule: diretorio nao e repositorio Git. Rode 'git init' antes ou use -NoSubmodule." -ForegroundColor Yellow
  }
  elseif (Test-Path '.specs/framework') {
    Write-Host "[SKIP] .specs/framework ja existe (use -Force para remover e re-adicionar)" -ForegroundColor Yellow
  }
  else {
    Write-Host "[..]   git submodule add $FrameworkRepo .specs/framework" -ForegroundColor Cyan
    & git submodule add -b $FrameworkRef $FrameworkRepo .specs/framework
    if ($LASTEXITCODE -eq 0) {
      & git submodule update --init --recursive .specs/framework | Out-Null
      Write-Host "[OK]   submodule .specs/framework ($FrameworkRef)" -ForegroundColor Green
      Push-Location .specs/framework
      $fwCommit = (& git rev-parse HEAD).Trim()
      Pop-Location
      $manifestContent = @"
{
  `"framework`": `"hap-spec-driven`",
  `"repo`": `"$FrameworkRepo`",
  `"ref`": `"$FrameworkRef`",
  `"commit`": `"$fwCommit`",
  `"pinned_at`": `"$today`",
  `"adr`": `"ADR-012`"
}
"@
      Write-FileSafe -Path '.specs/.framework.json' -Content $manifestContent
    } else {
      Write-Host "[ERRO] git submodule add falhou. Verifique acesso a $FrameworkRepo" -ForegroundColor Red
    }
  }
}
else {
  Write-Host "[INFO] -NoSubmodule definido: framework nao foi vinculado em .specs/framework/" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "[OK] Scaffold criado para squad '$SquadName' (stack=$Stack)" -ForegroundColor Green
Write-Host "Proximos passos:" -ForegroundColor Cyan
Write-Host "  1. Revisar .github/copilot-instructions.md e ajustar contexto"
Write-Host "  2. Validar .vscode/mcp.json - autenticar no Azure DevOps"
Write-Host "  3. Commit inicial: git add .specs .vscode .github .gitmodules; git commit -m 'WI-XXXX: chore(spec-driven): scaffold inicial v0.2 (ADR-012)'"
Write-Host "  4. Para atualizar o framework no futuro: scripts/update-framework.ps1"
Write-Host "  5. Para a primeira feature, use o prompt 'spec-from-workitem'"
