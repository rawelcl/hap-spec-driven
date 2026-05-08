<#
.SYNOPSIS
    Converte arquivos Oracle Forms .fmb para .xml usando frmf2xml.

.DESCRIPTION
    Localiza o utilitário frmf2xml no ORACLE_HOME e converte um ou mais
    arquivos .fmb para .xml, preservando toda a estrutura do form
    (código PL/SQL, layouts, canvas, janelas, blocos, itens, etc.)

.PARAMETER FmbPath
    Caminho para o arquivo .fmb ou pasta contendo arquivos .fmb.

.PARAMETER OracleHome
    Caminho do ORACLE_HOME. Se não informado, usa a variável de ambiente.

.PARAMETER OutputDir
    Pasta de saída para os XMLs. Se não informado, grava na mesma pasta do .fmb.

.EXAMPLE
    .\Convert-FmbToXml.ps1 -FmbPath "C:\CVS\web_10g\fmb\pln\meu_form.fmb"

.EXAMPLE
    .\Convert-FmbToXml.ps1 -FmbPath "C:\CVS\web_10g\fmb\pln" -OutputDir "C:\temp\forms_xml"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$FmbPath,

    [Parameter(Mandatory = $false)]
    [string]$OracleHome = $env:ORACLE_HOME,

    [Parameter(Mandatory = $false)]
    [string]$OutputDir
)

$ErrorActionPreference = "Stop"

# ???????????????????????????????????????
# 1. Localizar frmf2xml
# ???????????????????????????????????????

$frmf2xmlPath = $null
$useJavaDirect = $false
$oracleHomePath = $null

if ($OracleHome) {
    $oracleHomePath = $OracleHome
    $candidate = Join-Path $OracleHome "bin\frmf2xml.bat"
    if (Test-Path $candidate) {
        $frmf2xmlPath = $candidate
    }
}

if (-not $frmf2xmlPath) {
    # Tentar localizar automaticamente
    Write-Host "[INFO] frmf2xml.bat nao encontrado em bin\. Buscando..." -ForegroundColor Yellow
    $found = Get-ChildItem -Path "C:\Oracle" -Recurse -Filter "frmf2xml.bat" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) {
        $frmf2xmlPath = $found.FullName
        # Deduzir ORACLE_HOME do caminho encontrado (subir até o nível correto)
        if (-not $oracleHomePath) {
            # O bat fica em forms/templates/scripts ou bin - subir até o ORACLE_HOME
            $testHome = $found.DirectoryName
            while ($testHome -and -not (Test-Path (Join-Path $testHome "jlib\frmxmltools.jar"))) {
                $testHome = Split-Path $testHome -Parent
                if (-not $testHome -or $testHome.Length -lt 5) { $testHome = $null; break }
            }
            if ($testHome) { $oracleHomePath = $testHome }
        }
        Write-Host "[OK] Encontrado: $frmf2xmlPath" -ForegroundColor Green
    }
}

# Verificar se podemos usar Java diretamente (mais confiavel em caminhos com espacos)
if ($oracleHomePath) {
    $jarFile = Join-Path $oracleHomePath "jlib\frmxmltools.jar"
    $jarDapi = Join-Path $oracleHomePath "jlib\frmjdapi.jar"
    $jarXml  = Join-Path $oracleHomePath "oracle_common\modules\oracle.xdk\xmlparserv2.jar"

    if ((Test-Path $jarFile) -and (Test-Path $jarDapi) -and (Test-Path $jarXml)) {
        # Localizar Java
        $javaExe = $null
        @(
            (Join-Path $oracleHomePath "oracle_common\jdk\bin\java.exe"),
            "$env:JAVA_HOME\bin\java.exe",
            "java.exe"
        ) | ForEach-Object {
            if (-not $javaExe -and (Test-Path $_ -ErrorAction SilentlyContinue)) {
                $javaExe = $_
            }
        }
        if (-not $javaExe) {
            try { $null = Get-Command java -ErrorAction Stop; $javaExe = "java" } catch {}
        }

        if ($javaExe) {
            $useJavaDirect = $true
            $classpath = "$jarFile;$jarDapi;$jarXml"
            Write-Host "[OK] Modo direto Java: $javaExe" -ForegroundColor Green
            Write-Host "     Classpath: $classpath" -ForegroundColor DarkGray
        }
    }
}

if (-not $frmf2xmlPath -and -not $useJavaDirect) {
    Write-Host @"
[ERRO] frmf2xml nao encontrado e JARs do Oracle Forms nao localizados.

Opcoes:
  1. Instale o Oracle Forms Developer (10g ou superior)
  2. Defina a variavel ORACLE_HOME
  3. Use o parametro -OracleHome
  4. Use o Forms Builder (GUI): File > Convert > XML
"@ -ForegroundColor Red
    exit 1
}

# ???????????????????????????????????????
# 2. Coletar arquivos .fmb
# ???????????????????????????????????????

$fmbFiles = @()

if (Test-Path $FmbPath -PathType Container) {
    $fmbFiles = Get-ChildItem -Path $FmbPath -Filter "*.fmb" -Recurse
    Write-Host "[INFO] Encontrados $($fmbFiles.Count) arquivos .fmb em $FmbPath" -ForegroundColor Cyan
}
elseif (Test-Path $FmbPath -PathType Leaf) {
    $fmbFiles = @(Get-Item $FmbPath)
}
else {
    Write-Host "[ERRO] Caminho nao encontrado: $FmbPath" -ForegroundColor Red
    exit 1
}

if ($fmbFiles.Count -eq 0) {
    Write-Host "[ERRO] Nenhum arquivo .fmb encontrado." -ForegroundColor Red
    exit 1
}

# ???????????????????????????????????????
# 3. Converter cada .fmb
# ???????????????????????????????????????

$successCount = 0
$errorCount = 0

foreach ($fmb in $fmbFiles) {
    # Forms2XML gera o XML com padrao {nome}_fmb.xml na mesma pasta do .fmb
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fmb.Name)
    $generatedXmlName = "${baseName}_fmb.xml"
    $generatedXmlPath = Join-Path $fmb.DirectoryName $generatedXmlName

    # Destino final desejado
    $finalXmlName = "${baseName}.xml"
    if ($OutputDir) {
        if (-not (Test-Path $OutputDir)) {
            New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
        }
        $finalXmlPath = Join-Path $OutputDir $finalXmlName
    }
    else {
        $finalXmlPath = Join-Path $fmb.DirectoryName $finalXmlName
    }

    Write-Host "`n[CONVERTENDO] $($fmb.Name) -> $finalXmlName" -ForegroundColor Cyan

    try {
        $errFile = "$env:TEMP\frmf2xml_err.txt"
        $outFile = "$env:TEMP\frmf2xml_out.txt"

        if ($useJavaDirect) {
            # Chamar Java diretamente (evita problemas de PATH com espacos no .bat)
            # Forms2XML aceita apenas 1 argumento: o caminho do .fmb
            $javaArgs = @(
                "-classpath", $classpath,
                "oracle.forms.util.xmltools.Forms2XML",
                $fmb.FullName
            )
            Write-Host "  [CMD] java $($javaArgs -join ' ')" -ForegroundColor DarkGray
            $process = Start-Process -FilePath $javaExe `
                -ArgumentList $javaArgs `
                -Wait -PassThru -NoNewWindow `
                -RedirectStandardError $errFile `
                -RedirectStandardOutput $outFile
        }
        else {
            # Chamar via cmd.exe com o .bat (tambem sem segundo argumento)
            $cmdArgs = "/c `"set ORACLE_HOME=$oracleHomePath&& `"$frmf2xmlPath`" `"$($fmb.FullName)`"`""
            $process = Start-Process -FilePath "cmd.exe" `
                -ArgumentList $cmdArgs `
                -Wait -PassThru -NoNewWindow `
                -RedirectStandardError $errFile `
                -RedirectStandardOutput $outFile
        }

        # Forms2XML gera {nome}_fmb.xml na pasta do .fmb
        if (Test-Path $generatedXmlPath) {
            # Mover/renomear para o destino final
            if ($generatedXmlPath -ne $finalXmlPath) {
                Move-Item -Path $generatedXmlPath -Destination $finalXmlPath -Force
            }
            $size = (Get-Item $finalXmlPath).Length / 1KB
            Write-Host "[OK] Gerado: $finalXmlPath ($([math]::Round($size, 1)) KB)" -ForegroundColor Green
            $successCount++
        }
        else {
            $errMsg = Get-Content $errFile -ErrorAction SilentlyContinue
            $outMsg = Get-Content $outFile -ErrorAction SilentlyContinue
            Write-Host "[ERRO] Falha ao converter $($fmb.Name):" -ForegroundColor Red
            if ($outMsg) { Write-Host "  STDOUT: $outMsg" -ForegroundColor Yellow }
            if ($errMsg) { Write-Host "  STDERR: $errMsg" -ForegroundColor Red }
            $errorCount++
        }
    }
    catch {
        Write-Host "[ERRO] Excecao ao converter $($fmb.Name): $_" -ForegroundColor Red
        $errorCount++
    }
}

# ???????????????????????????????????????
# 4. Resumo
# ???????????????????????????????????????

Write-Host "`n????????????????????????????????????" -ForegroundColor White
Write-Host "  RESUMO DA CONVERSAO" -ForegroundColor White
Write-Host "????????????????????????????????????" -ForegroundColor White
Write-Host "  Total:      $($fmbFiles.Count)" -ForegroundColor White
Write-Host "  Sucesso:    $successCount" -ForegroundColor Green
Write-Host "  Erros:      $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "White" })
Write-Host "????????????????????????????????????" -ForegroundColor White

if ($successCount -gt 0) {
    Write-Host "`n[PROXIMO PASSO] Execute o Extract-FormsMetadata.ps1 para extrair relatorio legivel:" -ForegroundColor Yellow
    if ($OutputDir) {
        $outParam = $OutputDir
    } else {
        $baseSample = [System.IO.Path]::GetFileNameWithoutExtension($fmbFiles[0].Name)
        $outParam = Join-Path $fmbFiles[0].DirectoryName "${baseSample}.xml"
    }
    Write-Host "  .\Extract-FormsMetadata.ps1 -XmlPath `"$outParam`" -OutputDir `".\output`"" -ForegroundColor Yellow
}
