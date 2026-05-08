<#
.SYNOPSIS
    Extrai metadados completos de um XML gerado pelo frmf2xml do Oracle Forms.

.DESCRIPTION
    Le o XML de um Oracle Form e gera relatorios organizados com:
    - Resumo geral (contagem de objetos)
    - Janelas (posicao, tamanho, titulo, propriedades)
    - Canvas (tipo, janela, dimensoes)
    - Blocos (tipo, datasource, itens com todas as propriedades visuais)
    - Triggers (evento, escopo, codigo PL/SQL completo)
    - Program Units (procedures/functions PL/SQL)
    - LOVs (query, colunas, dimensoes)
    - Alertas, Parametros, Visual Attributes, Record Groups, Relations

.PARAMETER XmlPath
    Caminho para o arquivo .xml ou pasta contendo arquivos .xml.

.PARAMETER OutputDir
    Pasta de saida para os relatorios. Padrao: .\output

.PARAMETER Format
    Formato de saida: 'txt' (padrao) ou 'md' (Markdown).

.EXAMPLE
    .\Extract-FormsMetadata.ps1 -XmlPath "C:\temp\meu_form.xml"

.EXAMPLE
    .\Extract-FormsMetadata.ps1 -XmlPath "C:\temp\forms_xml" -OutputDir "C:\analise" -Format md
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$XmlPath,

    [Parameter(Mandatory = $false)]
    [string]$OutputDir = ".\output",

    [Parameter(Mandatory = $false)]
    [ValidateSet("txt", "md")]
    [string]$Format = "txt"
)

$ErrorActionPreference = "Stop"

# ???????????????????????????????????????
# Funcoes auxiliares
# ???????????????????????????????????????

function Get-AttrSafe {
    param($node, [string]$attrName, [string]$default = "(nao definido)")
    $val = $node.GetAttribute($attrName)
    if ([string]::IsNullOrWhiteSpace($val)) { return $default }
    return $val
}

function Decode-FormsText {
    # Decodifica entidades HTML/XML usadas pelo Forms2XML no texto PL/SQL
    param([string]$text)
    if ([string]::IsNullOrWhiteSpace($text)) { return $text }
    $text = $text -replace '&#10;', "`n"
    $text = $text -replace '&#13;', "`r"
    $text = $text -replace '&#9;', "`t"
    $text = $text -replace '&amp;#10;', "`n"
    $text = $text -replace '&amp;#13;', "`r"
    $text = $text -replace '&amp;#9;', "`t"
    $text = $text -replace '&amp;', '&'
    $text = $text -replace '&lt;', '<'
    $text = $text -replace '&gt;', '>'
    $text = $text -replace '&quot;', '"'
    $text = $text -replace '&apos;', "'"
    return $text
}

function Write-Section {
    param([System.Text.StringBuilder]$sb, [string]$title)
    $sb.AppendLine("") | Out-Null
    $sb.AppendLine(("=" * 80)) | Out-Null
    $sb.AppendLine("  $title") | Out-Null
    $sb.AppendLine(("=" * 80)) | Out-Null
    $sb.AppendLine("") | Out-Null
}

function Write-SubSection {
    param([System.Text.StringBuilder]$sb, [string]$title)
    $sb.AppendLine("") | Out-Null
    $sb.AppendLine(("-" * 60)) | Out-Null
    $sb.AppendLine("  $title") | Out-Null
    $sb.AppendLine(("-" * 60)) | Out-Null
}

# ???????????????????????????????????????
# Coletar XMLs
# ???????????????????????????????????????

$xmlFiles = @()
if (Test-Path $XmlPath -PathType Container) {
    $xmlFiles = Get-ChildItem -Path $XmlPath -Filter "*.xml" -Recurse
}
elseif (Test-Path $XmlPath -PathType Leaf) {
    $xmlFiles = @(Get-Item $XmlPath)
}
else {
    Write-Host "[ERRO] Caminho nao encontrado: $XmlPath" -ForegroundColor Red
    exit 1
}

if ($xmlFiles.Count -eq 0) {
    Write-Host "[ERRO] Nenhum arquivo .xml encontrado." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $OutputDir)) {
    New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
}

Write-Host "[INFO] Processando $($xmlFiles.Count) arquivo(s) XML..." -ForegroundColor Cyan

# ???????????????????????????????????????
# Processar cada XML
# ???????????????????????????????????????

foreach ($xmlFile in $xmlFiles) {
    Write-Host "`n[PROCESSANDO] $($xmlFile.Name)" -ForegroundColor Cyan

    [xml]$xml = Get-Content $xmlFile.FullName -Encoding UTF8

    # Configurar namespace manager para Oracle Forms XML
    $nsMgr = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
    $ns = $xml.DocumentElement.NamespaceURI
    if ($ns) {
        $nsMgr.AddNamespace("f", $ns)
        $nsPrefix = "f:"
    } else {
        $nsPrefix = ""
    }

    $module = $xml.SelectSingleNode("//${nsPrefix}Module", $nsMgr)

    if (-not $module) {
        $module = $xml.DocumentElement
        if ($module.LocalName -ne "Module") {
            Write-Host "[AVISO] Estrutura XML nao reconhecida em $($xmlFile.Name). Pulando." -ForegroundColor Yellow
            continue
        }
    }

    $formName = [System.IO.Path]::GetFileNameWithoutExtension($xmlFile.Name)
    $ext = $Format

    # ???????????????????????????????????????
    # RESUMO GERAL
    # ???????????????????????????????????????

    $sbResumo = [System.Text.StringBuilder]::new()
    $sbResumo.AppendLine("RESUMO DO FORM: $formName") | Out-Null
    $sbResumo.AppendLine("Gerado em: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')") | Out-Null
    $sbResumo.AppendLine("Arquivo fonte: $($xmlFile.FullName)") | Out-Null
    Write-Section $sbResumo "CONTAGEM DE OBJETOS"

    $windows    = $module.SelectNodes(".//${nsPrefix}Window", $nsMgr)
    $canvases   = $module.SelectNodes(".//${nsPrefix}Canvas", $nsMgr)
    $blocks     = $module.SelectNodes(".//${nsPrefix}Block", $nsMgr)
    $items      = $module.SelectNodes(".//${nsPrefix}Item", $nsMgr)
    $triggers   = $module.SelectNodes(".//${nsPrefix}Trigger", $nsMgr)
    $progUnits  = $module.SelectNodes(".//${nsPrefix}ProgramUnit", $nsMgr)
    $lovs       = $module.SelectNodes(".//${nsPrefix}LOV", $nsMgr)
    $alerts     = $module.SelectNodes(".//${nsPrefix}Alert", $nsMgr)
    $params     = $module.SelectNodes(".//${nsPrefix}FormParameter", $nsMgr)
    $visAttrs   = $module.SelectNodes(".//${nsPrefix}VisualAttribute", $nsMgr)
    $recGroups  = $module.SelectNodes(".//${nsPrefix}RecordGroup", $nsMgr)
    $relations  = $module.SelectNodes(".//${nsPrefix}Relation", $nsMgr)

    $sbResumo.AppendLine("  Janelas (Windows):       $($windows.Count)") | Out-Null
    $sbResumo.AppendLine("  Canvas:                  $($canvases.Count)") | Out-Null
    $sbResumo.AppendLine("  Blocos (Blocks):         $($blocks.Count)") | Out-Null
    $sbResumo.AppendLine("  Itens (Items):           $($items.Count)") | Out-Null
    $sbResumo.AppendLine("  Triggers:                $($triggers.Count)") | Out-Null
    $sbResumo.AppendLine("  Program Units (PL/SQL):  $($progUnits.Count)") | Out-Null
    $sbResumo.AppendLine("  LOVs:                    $($lovs.Count)") | Out-Null
    $sbResumo.AppendLine("  Alertas:                 $($alerts.Count)") | Out-Null
    $sbResumo.AppendLine("  Parametros:              $($params.Count)") | Out-Null
    $sbResumo.AppendLine("  Visual Attributes:       $($visAttrs.Count)") | Out-Null
    $sbResumo.AppendLine("  Record Groups:           $($recGroups.Count)") | Out-Null
    $sbResumo.AppendLine("  Relations:               $($relations.Count)") | Out-Null

    $resumoFile = Join-Path $OutputDir "${formName}_RESUMO.$ext"
    $sbResumo.ToString() | Out-File $resumoFile -Encoding UTF8
    Write-Host "  [OK] Resumo: $resumoFile" -ForegroundColor Green

    # ???????????????????????????????????????
    # WINDOWS (Janelas)
    # ???????????????????????????????????????

    if ($windows.Count -gt 0) {
        $sbWin = [System.Text.StringBuilder]::new()
        Write-Section $sbWin "JANELAS (WINDOWS) - $formName"

        foreach ($win in $windows) {
            Write-SubSection $sbWin "Window: $(Get-AttrSafe $win 'Name')"
            $sbWin.AppendLine("  Titulo:              $(Get-AttrSafe $win 'Title')") | Out-Null
            $sbWin.AppendLine("  Tipo:                $(Get-AttrSafe $win 'WindowStyle')") | Out-Null
            $sbWin.AppendLine("  Posicao X:           $(Get-AttrSafe $win 'XPosition')") | Out-Null
            $sbWin.AppendLine("  Posicao Y:           $(Get-AttrSafe $win 'YPosition')") | Out-Null
            $sbWin.AppendLine("  Largura:             $(Get-AttrSafe $win 'Width')") | Out-Null
            $sbWin.AppendLine("  Altura:              $(Get-AttrSafe $win 'Height')") | Out-Null
            $sbWin.AppendLine("  Modal:               $(Get-AttrSafe $win 'Modal')") | Out-Null
            $sbWin.AppendLine("  Resize:              $(Get-AttrSafe $win 'ResizeAllowed')") | Out-Null
            $sbWin.AppendLine("  Maximize:            $(Get-AttrSafe $win 'MaximizeAllowed')") | Out-Null
            $sbWin.AppendLine("  Minimize:            $(Get-AttrSafe $win 'MinimizeAllowed')") | Out-Null
            $sbWin.AppendLine("  Move:                $(Get-AttrSafe $win 'MoveAllowed')") | Out-Null
            $sbWin.AppendLine("  Close:               $(Get-AttrSafe $win 'CloseAllowed')") | Out-Null
            $sbWin.AppendLine("  Primary Canvas:      $(Get-AttrSafe $win 'PrimaryCanvas')") | Out-Null
            $sbWin.AppendLine("  Show H-Scrollbar:    $(Get-AttrSafe $win 'ShowHorizontalScrollbar')") | Out-Null
            $sbWin.AppendLine("  Show V-Scrollbar:    $(Get-AttrSafe $win 'ShowVerticalScrollbar')") | Out-Null
            $sbWin.AppendLine("  Visual Attribute:    $(Get-AttrSafe $win 'VisualAttributeName')") | Out-Null
        }

        $winFile = Join-Path $OutputDir "${formName}_WINDOWS.$ext"
        $sbWin.ToString() | Out-File $winFile -Encoding UTF8
        Write-Host "  [OK] Windows: $winFile" -ForegroundColor Green
    }

    # ???????????????????????????????????????
    # CANVAS
    # ???????????????????????????????????????

    if ($canvases.Count -gt 0) {
        $sbCanvas = [System.Text.StringBuilder]::new()
        Write-Section $sbCanvas "CANVAS - $formName"

        foreach ($cvs in $canvases) {
            Write-SubSection $sbCanvas "Canvas: $(Get-AttrSafe $cvs 'Name')"
            $sbCanvas.AppendLine("  Tipo:                $(Get-AttrSafe $cvs 'CanvasType')") | Out-Null
            $sbCanvas.AppendLine("  Janela:              $(Get-AttrSafe $cvs 'WindowName')") | Out-Null
            $sbCanvas.AppendLine("  Largura:             $(Get-AttrSafe $cvs 'Width')") | Out-Null
            $sbCanvas.AppendLine("  Altura:              $(Get-AttrSafe $cvs 'Height')") | Out-Null
            $sbCanvas.AppendLine("  Viewport X:          $(Get-AttrSafe $cvs 'ViewportXPosition')") | Out-Null
            $sbCanvas.AppendLine("  Viewport Y:          $(Get-AttrSafe $cvs 'ViewportYPosition')") | Out-Null
            $sbCanvas.AppendLine("  Viewport Width:      $(Get-AttrSafe $cvs 'ViewportWidth')") | Out-Null
            $sbCanvas.AppendLine("  Viewport Height:     $(Get-AttrSafe $cvs 'ViewportHeight')") | Out-Null
            $sbCanvas.AppendLine("  Tab Page Style:      $(Get-AttrSafe $cvs 'TabPageStyle')") | Out-Null
            $sbCanvas.AppendLine("  Raise on Entry:      $(Get-AttrSafe $cvs 'RaiseOnEntry')") | Out-Null
            $sbCanvas.AppendLine("  Visual Attribute:    $(Get-AttrSafe $cvs 'VisualAttributeName')") | Out-Null
            $sbCanvas.AppendLine("  Background Color:    $(Get-AttrSafe $cvs 'BackColor')") | Out-Null
            $sbCanvas.AppendLine("  Foreground Color:    $(Get-AttrSafe $cvs 'ForegroundColor')") | Out-Null
            $sbCanvas.AppendLine("  Fill Pattern:        $(Get-AttrSafe $cvs 'FillPattern')") | Out-Null

            # Tab Pages (se canvas tipo TAB)
            $tabPages = $cvs.SelectNodes(".//${nsPrefix}TabPage", $nsMgr)
            if ($tabPages.Count -gt 0) {
                $sbCanvas.AppendLine("") | Out-Null
                $sbCanvas.AppendLine("  Tab Pages:") | Out-Null
                foreach ($tab in $tabPages) {
                    $sbCanvas.AppendLine("    - $(Get-AttrSafe $tab 'Name'): Label='$(Get-AttrSafe $tab 'Label')'") | Out-Null
                }
            }

            # Graphics (elementos visuais no canvas)
            $graphics = $cvs.SelectNodes(".//${nsPrefix}Graphics", $nsMgr)
            if ($graphics.Count -gt 0) {
                $sbCanvas.AppendLine("") | Out-Null
                $sbCanvas.AppendLine("  Elementos Graficos: $($graphics.Count)") | Out-Null
                foreach ($gfx in $graphics) {
                    $gfxType = Get-AttrSafe $gfx 'GraphicsType'
                    $gfxName = Get-AttrSafe $gfx 'Name'
                    $sbCanvas.AppendLine("    - [$gfxType] $gfxName ($(Get-AttrSafe $gfx 'Width')x$(Get-AttrSafe $gfx 'Height') @ $(Get-AttrSafe $gfx 'XPosition'),$(Get-AttrSafe $gfx 'YPosition'))") | Out-Null

                    # Texto do grafico (labels visuais)
                    $gfxText = Get-AttrSafe $gfx 'GraphicsText' ''
                    if ($gfxText -and $gfxText -ne '(nao definido)') {
                        $sbCanvas.AppendLine("      Texto: $gfxText") | Out-Null
                    }
                }
            }
        }

        $canvasFile = Join-Path $OutputDir "${formName}_CANVAS.$ext"
        $sbCanvas.ToString() | Out-File $canvasFile -Encoding UTF8
        Write-Host "  [OK] Canvas: $canvasFile" -ForegroundColor Green
    }

    # ???????????????????????????????????????
    # BLOCKS e ITEMS
    # ???????????????????????????????????????

    if ($blocks.Count -gt 0) {
        $sbBlocks = [System.Text.StringBuilder]::new()
        Write-Section $sbBlocks "BLOCOS E ITENS - $formName"

        foreach ($block in $blocks) {
            Write-SubSection $sbBlocks "Bloco: $(Get-AttrSafe $block 'Name')"
            $sbBlocks.AppendLine("  Tipo:                $(Get-AttrSafe $block 'BlockType')") | Out-Null
            $sbBlocks.AppendLine("  Query Data Source:   $(Get-AttrSafe $block 'QueryDataSourceName')") | Out-Null
            $sbBlocks.AppendLine("  Query Data Type:     $(Get-AttrSafe $block 'QueryDataSourceType')") | Out-Null
            $sbBlocks.AppendLine("  DML Data Target:     $(Get-AttrSafe $block 'DMLDataTargetName')") | Out-Null
            $sbBlocks.AppendLine("  DML Data Type:       $(Get-AttrSafe $block 'DMLDataTargetType')") | Out-Null
            $sbBlocks.AppendLine("  Num Records:         $(Get-AttrSafe $block 'NumberOfRecordsDisplayed')") | Out-Null
            $sbBlocks.AppendLine("  Query All Records:   $(Get-AttrSafe $block 'QueryAllRecords')") | Out-Null
            $sbBlocks.AppendLine("  Insert/Update/Delete:$(Get-AttrSafe $block 'InsertAllowed')/$(Get-AttrSafe $block 'UpdateAllowed')/$(Get-AttrSafe $block 'DeleteAllowed')") | Out-Null
            $sbBlocks.AppendLine("  Navigation Style:    $(Get-AttrSafe $block 'NavigationStyle')") | Out-Null
            $sbBlocks.AppendLine("  Record Orientation:  $(Get-AttrSafe $block 'RecordOrientation')") | Out-Null
            $sbBlocks.AppendLine("  Scrollbar:           $(Get-AttrSafe $block 'ShowScrollbar')") | Out-Null
            $sbBlocks.AppendLine("  WHERE Clause:        $(Get-AttrSafe $block 'WhereClause')") | Out-Null
            $sbBlocks.AppendLine("  ORDER BY:            $(Get-AttrSafe $block 'OrderByClause')") | Out-Null

            # Itens do bloco
            $blockItems = $block.SelectNodes("./${nsPrefix}Item", $nsMgr)
            if ($blockItems.Count -gt 0) {
                $sbBlocks.AppendLine("") | Out-Null
                $sbBlocks.AppendLine("  ITENS ($($blockItems.Count)):") | Out-Null
                $sbBlocks.AppendLine("  $("-" * 50)") | Out-Null

                foreach ($item in $blockItems) {
                    $itemName = Get-AttrSafe $item 'Name'
                    $itemType = Get-AttrSafe $item 'ItemType'
                    $sbBlocks.AppendLine("") | Out-Null
                    $sbBlocks.AppendLine("    [$itemType] $itemName") | Out-Null
                    $sbBlocks.AppendLine("      Canvas:          $(Get-AttrSafe $item 'CanvasName')") | Out-Null
                    $sbBlocks.AppendLine("      Tab Page:        $(Get-AttrSafe $item 'TabPageName')") | Out-Null
                    $sbBlocks.AppendLine("      Posicao:         X=$(Get-AttrSafe $item 'XPosition'), Y=$(Get-AttrSafe $item 'YPosition')") | Out-Null
                    $sbBlocks.AppendLine("      Tamanho:         W=$(Get-AttrSafe $item 'Width'), H=$(Get-AttrSafe $item 'Height')") | Out-Null
                    $sbBlocks.AppendLine("      Prompt:          $(Get-AttrSafe $item 'Prompt')") | Out-Null
                    $sbBlocks.AppendLine("      Data Type:       $(Get-AttrSafe $item 'DataType')") | Out-Null
                    $sbBlocks.AppendLine("      Max Length:      $(Get-AttrSafe $item 'MaximumLength')") | Out-Null
                    $sbBlocks.AppendLine("      Required:        $(Get-AttrSafe $item 'Required')") | Out-Null
                    $sbBlocks.AppendLine("      Enabled:         $(Get-AttrSafe $item 'Enabled')") | Out-Null
                    $sbBlocks.AppendLine("      Visible:         $(Get-AttrSafe $item 'Visible')") | Out-Null
                    $sbBlocks.AppendLine("      Insert/Update:   $(Get-AttrSafe $item 'InsertAllowed')/$(Get-AttrSafe $item 'UpdateAllowed')") | Out-Null
                    $sbBlocks.AppendLine("      Database Item:   $(Get-AttrSafe $item 'DatabaseItem')") | Out-Null
                    $sbBlocks.AppendLine("      Column Name:     $(Get-AttrSafe $item 'ColumnName')") | Out-Null
                    $sbBlocks.AppendLine("      Default Value:   $(Get-AttrSafe $item 'DefaultValue')") | Out-Null
                    $sbBlocks.AppendLine("      LOV:             $(Get-AttrSafe $item 'LOVName')") | Out-Null
                    $sbBlocks.AppendLine("      Visual Attr:     $(Get-AttrSafe $item 'VisualAttributeName')") | Out-Null
                    $sbBlocks.AppendLine("      Format Mask:     $(Get-AttrSafe $item 'FormatMask')") | Out-Null
                    $sbBlocks.AppendLine("      Initial Value:   $(Get-AttrSafe $item 'InitialValue')") | Out-Null
                    $sbBlocks.AppendLine("      Tooltip:         $(Get-AttrSafe $item 'Tooltip')") | Out-Null
                    $sbBlocks.AppendLine("      Font:            $(Get-AttrSafe $item 'FontName') $(Get-AttrSafe $item 'FontSize')pt $(Get-AttrSafe $item 'FontWeight')") | Out-Null
                    $sbBlocks.AppendLine("      Colors:          FG=$(Get-AttrSafe $item 'ForegroundColor') BG=$(Get-AttrSafe $item 'BackColor')") | Out-Null

                    # Triggers do item
                    $itemTriggers = $item.SelectNodes("./${nsPrefix}Trigger", $nsMgr)
                    if ($itemTriggers.Count -gt 0) {
                        $sbBlocks.AppendLine("      Triggers:") | Out-Null
                        foreach ($trig in $itemTriggers) {
                            $sbBlocks.AppendLine("        - $(Get-AttrSafe $trig 'Name')") | Out-Null
                        }
                    }
                }
            }

            # Triggers do bloco
            $blockTriggers = $block.SelectNodes("./${nsPrefix}Trigger", $nsMgr)
            if ($blockTriggers.Count -gt 0) {
                $sbBlocks.AppendLine("") | Out-Null
                $sbBlocks.AppendLine("  TRIGGERS DO BLOCO ($($blockTriggers.Count)):") | Out-Null
                foreach ($trig in $blockTriggers) {
                    $sbBlocks.AppendLine("    - $(Get-AttrSafe $trig 'Name')") | Out-Null
                }
            }
        }

        $blocksFile = Join-Path $OutputDir "${formName}_BLOCKS.$ext"
        $sbBlocks.ToString() | Out-File $blocksFile -Encoding UTF8
        Write-Host "  [OK] Blocks: $blocksFile" -ForegroundColor Green
    }

    # ???????????????????????????????????????
    # TRIGGERS (com codigo PL/SQL completo)
    # ???????????????????????????????????????

    if ($triggers.Count -gt 0) {
        $sbTrig = [System.Text.StringBuilder]::new()
        Write-Section $sbTrig "TRIGGERS - $formName (com codigo PL/SQL)"

        foreach ($trig in $triggers) {
            $trigName  = Get-AttrSafe $trig 'Name'
            $trigType  = Get-AttrSafe $trig 'TriggerType'
            $trigScope = $trig.ParentNode.LocalName
            $trigParent = Get-AttrSafe $trig.ParentNode 'Name'

            Write-SubSection $sbTrig "Trigger: $trigName"
            $sbTrig.AppendLine("  Tipo:      $trigType") | Out-Null
            $sbTrig.AppendLine("  Escopo:    $trigScope ($trigParent)") | Out-Null
            $sbTrig.AppendLine("  Fire In:   $(Get-AttrSafe $trig 'FireInEnterQueryMode')") | Out-Null

            $code = Get-AttrSafe $trig 'TriggerText' ''
            if ($code -and $code -ne '(nao definido)') {
                $code = Decode-FormsText $code
                $sbTrig.AppendLine("") | Out-Null
                $sbTrig.AppendLine("  --- CODIGO PL/SQL ---") | Out-Null
                $sbTrig.AppendLine($code) | Out-Null
                $sbTrig.AppendLine("  --- FIM CODIGO ---") | Out-Null
            }
        }

        $trigFile = Join-Path $OutputDir "${formName}_TRIGGERS.$ext"
        $sbTrig.ToString() | Out-File $trigFile -Encoding UTF8
        Write-Host "  [OK] Triggers: $trigFile" -ForegroundColor Green
    }

    # ???????????????????????????????????????
    # PROGRAM UNITS (PL/SQL)
    # ???????????????????????????????????????

    if ($progUnits.Count -gt 0) {
        $sbPU = [System.Text.StringBuilder]::new()
        Write-Section $sbPU "PROGRAM UNITS (PL/SQL) - $formName"

        foreach ($pu in $progUnits) {
            $puName = Get-AttrSafe $pu 'Name'
            $puType = Get-AttrSafe $pu 'ProgramUnitType'

            Write-SubSection $sbPU "${puType}: ${puName}"

            $code = Get-AttrSafe $pu 'ProgramUnitText' ''
            if ($code -and $code -ne '(nao definido)') {
                $code = Decode-FormsText $code
                $sbPU.AppendLine($code) | Out-Null
            }
        }

        $puFile = Join-Path $OutputDir "${formName}_PROGRAM_UNITS.$ext"
        $sbPU.ToString() | Out-File $puFile -Encoding UTF8
        Write-Host "  [OK] Program Units: $puFile" -ForegroundColor Green
    }

    # ???????????????????????????????????????
    # LOVs
    # ???????????????????????????????????????

    if ($lovs.Count -gt 0) {
        $sbLov = [System.Text.StringBuilder]::new()
        Write-Section $sbLov "LOVs (Lists of Values) - $formName"

        foreach ($lov in $lovs) {
            Write-SubSection $sbLov "LOV: $(Get-AttrSafe $lov 'Name')"
            $sbLov.AppendLine("  Record Group:    $(Get-AttrSafe $lov 'RecordGroupName')") | Out-Null
            $sbLov.AppendLine("  Titulo:          $(Get-AttrSafe $lov 'Title')") | Out-Null
            $sbLov.AppendLine("  Posicao:         X=$(Get-AttrSafe $lov 'XPosition'), Y=$(Get-AttrSafe $lov 'YPosition')") | Out-Null
            $sbLov.AppendLine("  Tamanho:         W=$(Get-AttrSafe $lov 'Width'), H=$(Get-AttrSafe $lov 'Height')") | Out-Null
            $sbLov.AppendLine("  Auto Display:    $(Get-AttrSafe $lov 'AutomaticDisplay')") | Out-Null
            $sbLov.AppendLine("  Auto Refresh:    $(Get-AttrSafe $lov 'AutomaticRefresh')") | Out-Null
            $sbLov.AppendLine("  Filter Before:   $(Get-AttrSafe $lov 'FilterBeforeDisplay')") | Out-Null

            # Colunas da LOV
            $lovCols = $lov.SelectNodes("./${nsPrefix}LOVColumnMapping", $nsMgr)
            if ($lovCols.Count -gt 0) {
                $sbLov.AppendLine("  Colunas:") | Out-Null
                foreach ($col in $lovCols) {
                    $sbLov.AppendLine("    - $(Get-AttrSafe $col 'Name'): ReturnItem=$(Get-AttrSafe $col 'ReturnItem'), Display W=$(Get-AttrSafe $col 'DisplayWidth'), Title='$(Get-AttrSafe $col 'Title')'") | Out-Null
                }
            }
        }

        $lovFile = Join-Path $OutputDir "${formName}_LOVS.$ext"
        $sbLov.ToString() | Out-File $lovFile -Encoding UTF8
        Write-Host "  [OK] LOVs: $lovFile" -ForegroundColor Green
    }

    # ???????????????????????????????????????
    # ALERTS
    # ???????????????????????????????????????

    if ($alerts.Count -gt 0) {
        $sbAlert = [System.Text.StringBuilder]::new()
        Write-Section $sbAlert "ALERTAS - $formName"

        foreach ($alert in $alerts) {
            Write-SubSection $sbAlert "Alerta: $(Get-AttrSafe $alert 'Name')"
            $sbAlert.AppendLine("  Titulo:          $(Get-AttrSafe $alert 'Title')") | Out-Null
            $sbAlert.AppendLine("  Mensagem:        $(Get-AttrSafe $alert 'AlertMessage')") | Out-Null
            $sbAlert.AppendLine("  Estilo:          $(Get-AttrSafe $alert 'AlertStyle')") | Out-Null
            $sbAlert.AppendLine("  Botao 1:         $(Get-AttrSafe $alert 'Button1Label')") | Out-Null
            $sbAlert.AppendLine("  Botao 2:         $(Get-AttrSafe $alert 'Button2Label')") | Out-Null
            $sbAlert.AppendLine("  Botao 3:         $(Get-AttrSafe $alert 'Button3Label')") | Out-Null
            $sbAlert.AppendLine("  Default Alert:   $(Get-AttrSafe $alert 'DefaultAlertButton')") | Out-Null
        }

        $alertFile = Join-Path $OutputDir "${formName}_ALERTS.$ext"
        $sbAlert.ToString() | Out-File $alertFile -Encoding UTF8
        Write-Host "  [OK] Alerts: $alertFile" -ForegroundColor Green
    }

    # ???????????????????????????????????????
    # PARAMETERS
    # ???????????????????????????????????????

    if ($params.Count -gt 0) {
        $sbParam = [System.Text.StringBuilder]::new()
        Write-Section $sbParam "PARAMETROS DO FORM - $formName"

        foreach ($param in $params) {
            $sbParam.AppendLine("  $(Get-AttrSafe $param 'Name')") | Out-Null
            $sbParam.AppendLine("    Data Type:     $(Get-AttrSafe $param 'ParameterDataType')") | Out-Null
            $sbParam.AppendLine("    Max Length:     $(Get-AttrSafe $param 'MaximumLength')") | Out-Null
            $sbParam.AppendLine("    Default:        $(Get-AttrSafe $param 'ParameterInitialValue')") | Out-Null
            $sbParam.AppendLine("") | Out-Null
        }

        $paramFile = Join-Path $OutputDir "${formName}_PARAMETERS.$ext"
        $sbParam.ToString() | Out-File $paramFile -Encoding UTF8
        Write-Host "  [OK] Parameters: $paramFile" -ForegroundColor Green
    }

    # ???????????????????????????????????????
    # VISUAL ATTRIBUTES
    # ???????????????????????????????????????

    if ($visAttrs.Count -gt 0) {
        $sbVA = [System.Text.StringBuilder]::new()
        Write-Section $sbVA "VISUAL ATTRIBUTES - $formName"

        foreach ($va in $visAttrs) {
            Write-SubSection $sbVA "Visual Attr: $(Get-AttrSafe $va 'Name')"
            $sbVA.AppendLine("  Foreground:      $(Get-AttrSafe $va 'ForegroundColor')") | Out-Null
            $sbVA.AppendLine("  Background:      $(Get-AttrSafe $va 'BackColor')") | Out-Null
            $sbVA.AppendLine("  Fill Pattern:    $(Get-AttrSafe $va 'FillPattern')") | Out-Null
            $sbVA.AppendLine("  Font Name:       $(Get-AttrSafe $va 'FontName')") | Out-Null
            $sbVA.AppendLine("  Font Size:       $(Get-AttrSafe $va 'FontSize')") | Out-Null
            $sbVA.AppendLine("  Font Weight:     $(Get-AttrSafe $va 'FontWeight')") | Out-Null
            $sbVA.AppendLine("  Font Style:      $(Get-AttrSafe $va 'FontStyle')") | Out-Null
        }

        $vaFile = Join-Path $OutputDir "${formName}_VISUAL_ATTRS.$ext"
        $sbVA.ToString() | Out-File $vaFile -Encoding UTF8
        Write-Host "  [OK] Visual Attrs: $vaFile" -ForegroundColor Green
    }

    # ???????????????????????????????????????
    # RECORD GROUPS
    # ???????????????????????????????????????

    if ($recGroups.Count -gt 0) {
        $sbRG = [System.Text.StringBuilder]::new()
        Write-Section $sbRG "RECORD GROUPS - $formName"

        foreach ($rg in $recGroups) {
            Write-SubSection $sbRG "Record Group: $(Get-AttrSafe $rg 'Name')"
            $sbRG.AppendLine("  Tipo:            $(Get-AttrSafe $rg 'RecordGroupType')") | Out-Null

            $query = Get-AttrSafe $rg 'RecordGroupQuery' ''
            if ($query -and $query -ne '(nao definido)') {
                $sbRG.AppendLine("  Query SQL:") | Out-Null
                $sbRG.AppendLine("    $query") | Out-Null
            }

            $rgCols = $rg.SelectNodes("./${nsPrefix}RecordGroupColumn", $nsMgr)
            if ($rgCols.Count -gt 0) {
                $sbRG.AppendLine("  Colunas:") | Out-Null
                foreach ($col in $rgCols) {
                    $sbRG.AppendLine("    - $(Get-AttrSafe $col 'Name'): Type=$(Get-AttrSafe $col 'ColumnDataType'), MaxLen=$(Get-AttrSafe $col 'MaximumLength')") | Out-Null
                }
            }
        }

        $rgFile = Join-Path $OutputDir "${formName}_RECORD_GROUPS.$ext"
        $sbRG.ToString() | Out-File $rgFile -Encoding UTF8
        Write-Host "  [OK] Record Groups: $rgFile" -ForegroundColor Green
    }

    # ???????????????????????????????????????
    # RELATIONS
    # ???????????????????????????????????????

    if ($relations.Count -gt 0) {
        $sbRel = [System.Text.StringBuilder]::new()
        Write-Section $sbRel "RELATIONS (Master-Detail) - $formName"

        foreach ($rel in $relations) {
            Write-SubSection $sbRel "Relation: $(Get-AttrSafe $rel 'Name')"
            $sbRel.AppendLine("  Detail Block:    $(Get-AttrSafe $rel 'DetailBlock')") | Out-Null
            $sbRel.AppendLine("  Master Block:    $(Get-AttrSafe $rel.ParentNode 'Name')") | Out-Null
            $sbRel.AppendLine("  Join Condition:  $(Get-AttrSafe $rel 'JoinCondition')") | Out-Null
            $sbRel.AppendLine("  Delete Record:   $(Get-AttrSafe $rel 'DeleteRecordBehavior')") | Out-Null
            $sbRel.AppendLine("  Prevent Orphans: $(Get-AttrSafe $rel 'PreventMasterlessOps')") | Out-Null
            $sbRel.AppendLine("  Auto Query:      $(Get-AttrSafe $rel 'AutoQuery')") | Out-Null
        }

        $relFile = Join-Path $OutputDir "${formName}_RELATIONS.$ext"
        $sbRel.ToString() | Out-File $relFile -Encoding UTF8
        Write-Host "  [OK] Relations: $relFile" -ForegroundColor Green
    }

    Write-Host "[CONCLUIDO] $formName - arquivos gerados em $OutputDir" -ForegroundColor Green
}

# ???????????????????????????????????????
# RESUMO FINAL
# ???????????????????????????????????????

Write-Host "`n????????????????????????????????????" -ForegroundColor White
Write-Host "  EXTRACAO CONCLUIDA" -ForegroundColor White
Write-Host "  Arquivos gerados em: $OutputDir" -ForegroundColor Cyan
Write-Host "????????????????????????????????????" -ForegroundColor White
Write-Host "`nAbra os arquivos no VS Code para analise." -ForegroundColor Yellow
