<#
.SYNOPSIS
  Busca um arquivo ou modulo do WinCVS usando a tag PRODUCAO mais recente.

.DESCRIPTION
  Etapa obrigatoria do fluxo de engenharia reversa PL/SQL (skill hap-sd-re-plsql).
  O agente executa este tool diretamente via terminal antes de iniciar qualquer RE.

  Fluxo:
    1. Verifica credenciais (env vars + ~/.cvspass). Se ausentes, inicia setup interativo.
    2. Resolve a tag PRODUCAO_YYYYMMDD mais recente via `cvs rlog -h` (se -Tag omitido).
    3. Faz checkout do modulo com a tag resolvida em -OutputDir.
    4. Grava cvs-fetch-evidence.json com host, tag, SHA-256 dos arquivos obtidos.

.PARAMETER Module
  Caminho do modulo/arquivo no repositorio CVS relativo ao CVSROOT.
  Ex: "HUMASTER/PK_VENDA_JSON.pkb"

.PARAMETER OutputDir
  Diretorio local de saida. Default: .cvs-checkout/<NOME_OBJETO>/<TAG>/

.PARAMETER Tag
  Tag especifica para checkout. Se omitido, busca automaticamente a PRODUCAO_* mais recente.

.PARAMETER CvsHost
  Hostname ou IP do servidor CVS.
  Default: $env:HAPVIDA_CVS_HOST

.PARAMETER CvsRepo
  Caminho do repositorio no servidor.
  Default: /cvs/hapvida

.PARAMETER CvsUser
  Usuario CVS.
  Default: $env:HAPVIDA_CVS_USER

.EXAMPLE
  # Uso tipico (env vars ja definidas, cvs login ja feito):
  .\cvs-fetch-producao.ps1 -Module "HUMASTER/PK_VENDA_JSON.pkb"

.EXAMPLE
  # Tag especifica:
  .\cvs-fetch-producao.ps1 -Module "HUMASTER/PK_VENDA_JSON.pkb" -Tag "PRODUCAO_20260430"

.EXAMPLE
  # Dot-source do arquivo de config (se gerado pelo setup interativo):
  . .\.cvs-env.ps1
  .\cvs-fetch-producao.ps1 -Module "HUMASTER/PK_VENDA_JSON.pkb"

.NOTES
  - NUNCA passe senha como parametro. Use o setup interativo na primeira execucao.
  - O setup interativo grava ~/.cvspass via `cvs login` e oferece persistir host/user
    em .cvs-env.ps1 (sem senha, entra no .gitignore do projeto).
  - Requer cvs.exe no PATH.
  - Conforme ADR-007 emendada: fonte de codigo e exclusivamente WinCVS tag PRODUCAO.
    dba_source via MCP Oracle e proibido como fonte de codigo.
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [string] $Module,

  [string] $OutputDir  = '',
  [string] $Tag        = '',
  [string] $CvsHost    = $env:HAPVIDA_CVS_HOST,
  [string] $CvsRepo    = '/cvs/hapvida',
  [string] $CvsUser    = $env:HAPVIDA_CVS_USER
)

$ErrorActionPreference = 'Stop'
$MaxLoginAttempts = 3

# ---------------------------------------------------------------------------
# Funcoes auxiliares
# ---------------------------------------------------------------------------

function Test-TcpConnection {
  param([string]$Host, [int]$Port = 2401, [int]$TimeoutMs = 3000)
  try {
    $tcp = [System.Net.Sockets.TcpClient]::new()
    $result = $tcp.BeginConnect($Host, $Port, $null, $null)
    $success = $result.AsyncWaitHandle.WaitOne($TimeoutMs)
    $tcp.Close()
    return $success
  } catch {
    return $false
  }
}

function Invoke-CvsLogin {
  param([string]$CVSROOT, [SecureString]$SecurePassword)

  # Converte SecureString para string temporaria apenas para pipe stdin do cvs login
  $bstr     = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
  $plainPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
  [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)

  # cvs login le a senha do stdin quando nao e TTY
  $plainPwd | & cvs -d $CVSROOT login 2>&1
  $exitCode = $LASTEXITCODE

  # Zera a string da memoria o mais rapido possivel
  $plainPwd = $null
  [System.GC]::Collect()

  return $exitCode
}

function Write-SetupFile {
  param([string]$Host, [string]$User, [string]$Repo)
  $content = @"
# Configuracao CVS Hapvida - gerado por cvs-fetch-producao ($(Get-Date -Format 'yyyy-MM-dd'))
# NAO versionar este arquivo (deve estar no .gitignore).
# NAO contem senha - apenas host e usuario.
`$env:HAPVIDA_CVS_HOST = '$Host'
`$env:HAPVIDA_CVS_USER = '$User'
`$env:HAPVIDA_CVS_REPO = '$Repo'
"@
  $envFile = '.cvs-env.ps1'
  Set-Content $envFile -Value $content -Encoding UTF8NoBOM

  # Adiciona ao .gitignore local se existir
  $gitignore = '.gitignore'
  if (Test-Path $gitignore) {
    $lines = Get-Content $gitignore
    if ($lines -notcontains '.cvs-env.ps1') {
      Add-Content $gitignore "`n# CVS local config (sem senha)`n.cvs-env.ps1"
    }
  }
  Write-Host "[OK] Configuracao gravada em '$envFile'. Use '. .\.cvs-env.ps1' antes de rodar o tool." -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# Etapa 0 - Setup interativo (se credenciais ausentes)
# ---------------------------------------------------------------------------

$needsSetup = (-not $CvsHost) -or (-not $CvsUser) -or (-not (Test-Path (Join-Path $HOME '.cvspass')))

if ($needsSetup) {
  Write-Host ""
  Write-Host "[SETUP CVS] Credenciais nao encontradas. Iniciando configuracao..." -ForegroundColor Yellow
  Write-Host ""

  # 0.1 - Host
  if (-not $CvsHost) {
    do {
      $input = Read-Host "[1/3] Host CVS (HAPVIDA_CVS_HOST) [Enter para 10.1.17.26]"
      if (-not $input) { $input = '10.1.17.26' }
      Write-Host "      Testando conectividade TCP $input`:2401..." -ForegroundColor DarkGray
      if (Test-TcpConnection -Host $input -Port 2401) {
        $CvsHost = $input
        Write-Host "      Conectividade OK." -ForegroundColor Green
      } else {
        Write-Host "      [AVISO] Nao foi possivel conectar em $input`:2401. Verifique a rede." -ForegroundColor Yellow
        $continuar = Read-Host "      Continuar mesmo assim? [S/N]"
        if ($continuar -imatch '^s') { $CvsHost = $input }
      }
    } while (-not $CvsHost)
  }

  # 0.2 - Usuario
  if (-not $CvsUser) {
    $inputUser = Read-Host "[2/3] Usuario CVS (HAPVIDA_CVS_USER) [Enter para $env:USERNAME]"
    $CvsUser = if ($inputUser) { $inputUser } else { $env:USERNAME }
  }

  # 0.3 - Senha e cvs login (ate 3 tentativas)
  $CVSROOT = ":pserver:${CvsUser}@${CvsHost}:${CvsRepo}"
  $loginOk = $false
  $attempt = 0

  while (-not $loginOk -and $attempt -lt $MaxLoginAttempts) {
    $attempt++
    Write-Host "[3/3] Senha CVS (tentativa $attempt de $MaxLoginAttempts - nao sera exibida):" -ForegroundColor Cyan -NoNewline
    Write-Host ""
    $secPwd = Read-Host -AsSecureString "      Senha"

    $exitCode = Invoke-CvsLogin -CVSROOT $CVSROOT -SecurePassword $secPwd
    $secPwd = $null

    if ($exitCode -eq 0) {
      $loginOk = $true
      Write-Host "[OK] Login CVS realizado. Credenciais gravadas em ~/.cvspass pelo cvs." -ForegroundColor Green
    } else {
      Write-Host "[ERRO] cvs login falhou (exit $exitCode)." -ForegroundColor Red
      if ($attempt -lt $MaxLoginAttempts) {
        Write-Host "      Verifique usuario/senha e tente novamente." -ForegroundColor Yellow
      }
    }
  }

  if (-not $loginOk) {
    Write-Host ""
    Write-Host "[BLOQUEADO] Nao foi possivel autenticar no CVS apos $MaxLoginAttempts tentativas." -ForegroundColor Red
    Write-Host "            Verifique: host ($CvsHost), usuario ($CvsUser), senha e conectividade." -ForegroundColor Red
    exit 1
  }

  # 0.4 - Persistir host/user (sem senha)
  Write-Host ""
  $persistir = Read-Host "Deseja salvar host/usuario em '.cvs-env.ps1' para nao precisar informar novamente? [S/N]"
  if ($persistir -imatch '^s') {
    Write-SetupFile -Host $CvsHost -User $CvsUser -Repo $CvsRepo
  }
}

# ---------------------------------------------------------------------------
# Etapa 1 - Montar CVSROOT e verificar cvs.exe
# ---------------------------------------------------------------------------

if (-not (Get-Command 'cvs' -ErrorAction SilentlyContinue)) {
  Write-Host "[BLOQUEADO] cvs.exe nao encontrado no PATH." -ForegroundColor Red
  Write-Host "            Instale o cliente CVS e adicione ao PATH antes de continuar." -ForegroundColor Red
  exit 1
}

$CVSROOT = ":pserver:${CvsUser}@${CvsHost}:${CvsRepo}"
$env:CVSROOT = $CVSROOT

Write-Host ""
Write-Host "[..] CVSROOT: $(':pserver:' + $CvsUser + '@' + $CvsHost + ':' + $CvsRepo)" -ForegroundColor DarkGray

# ---------------------------------------------------------------------------
# Etapa 2 - Resolver tag PRODUCAO mais recente (se -Tag omitido)
# ---------------------------------------------------------------------------

if (-not $Tag) {
  Write-Host "[..] Listando tags PRODUCAO_* para '$Module'..." -ForegroundColor Cyan

  $logOutput = & cvs -d $CVSROOT rlog -h $Module 2>&1
  if ($LASTEXITCODE -ne 0) {
    Write-Host "[BLOQUEADO] cvs rlog falhou para '$Module'. Saida:" -ForegroundColor Red
    $logOutput | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkRed }
    exit 1
  }

  $dates = $logOutput |
    Select-String 'PRODUCAO_(\d{8})' |
    ForEach-Object { $_.Matches[0].Groups[1].Value } |
    Sort-Object -Descending |
    Select-Object -Unique

  if (-not $dates) {
    Write-Host "[BLOQUEADO] Nenhuma tag PRODUCAO_YYYYMMDD encontrada para '$Module'." -ForegroundColor Red
    Write-Host "            Verifique o modulo informado e o repositorio CVS." -ForegroundColor Red
    exit 1
  }

  $Tag = "PRODUCAO_$($dates[0])"
  Write-Host "[OK] Tag mais recente: $Tag" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# Etapa 3 - Checkout
# ---------------------------------------------------------------------------

$objectName = [System.IO.Path]::GetFileNameWithoutExtension($Module.Split('/')[-1])
if (-not $OutputDir) {
  $OutputDir = ".cvs-checkout/$objectName/$Tag"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$absOutputDir = (Resolve-Path $OutputDir).Path

Write-Host "[..] Checkout de '$Module' @ '$Tag' para '$absOutputDir'..." -ForegroundColor Cyan

Push-Location $absOutputDir
try {
  & cvs -d $CVSROOT checkout -r $Tag $Module 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
  if ($LASTEXITCODE -ne 0) { throw "cvs checkout falhou (exit $LASTEXITCODE)" }
} finally {
  Pop-Location
}

# ---------------------------------------------------------------------------
# Etapa 4 - Gravar evidence.json
# ---------------------------------------------------------------------------

$files = Get-ChildItem -Recurse -File $absOutputDir | Where-Object { $_.Name -ne 'cvs-fetch-evidence.json' }

$evidence = [ordered]@{
  fetched_at   = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ss')
  cvsroot_host = $CvsHost
  cvs_repo     = $CvsRepo
  module       = $Module
  tag          = $Tag
  output_dir   = $absOutputDir
  files        = @($files | ForEach-Object {
    [ordered]@{
      path   = $_.FullName
      sha256 = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
    }
  })
}

$evidencePath = Join-Path $absOutputDir 'cvs-fetch-evidence.json'
$evidence | ConvertTo-Json -Depth 5 | Set-Content $evidencePath -Encoding UTF8NoBOM

Write-Host ""
Write-Host "[OK] Checkout concluido." -ForegroundColor Green
Write-Host "     Tag    : $Tag"
Write-Host "     Saida  : $absOutputDir"
Write-Host "     Arquivos: $($files.Count)"
Write-Host "     Evidence: $evidencePath"
Write-Host ""
Write-Host "Proximo passo: execute a skill hap-sd-re-plsql com os arquivos em '$absOutputDir'."
