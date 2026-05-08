# Oracle Forms Extractor

Pipeline de extracao para analise de modulos Oracle Forms (`.fmb`) em VS Code, consumido pela
skill [`engenharia-reversa-forms`](../../skills/engenharia-reversa-forms/SKILL.md).

## Objetivo

Converter modulos Oracle Forms binarios em representacao estruturada (XML + 12 relatorios em
texto/markdown) para extracao de:

- **Codigo PL/SQL** embutido em triggers e program units
- **Configuracoes visuais**: layouts, janelas, canvas, blocks, items, LOVs, alertas
- **Estrutura de dados**: relations master-detail, record groups
- **Atributos**: cores, fontes, propriedades de display

---

## Pre-requisitos

### Opcao A - Usando `frmf2xml` (extracao automatica)

- Oracle Forms Developer 10g ou superior instalado
- Variavel `ORACLE_HOME` configurada
- Caminho tipico: `%ORACLE_HOME%\bin\frmf2xml.bat`
- Alternativa: invocacao direta dos JARs `frmxmltools.jar`, `frmjdapi.jar`, `xmlparserv2.jar`
  (o script tenta esse modo automaticamente quando o `.bat` nao funciona)

### Opcao B - Usando Oracle Forms Builder (GUI)

- Abrir o `.fmb` no Forms Builder
- Exportar manualmente via **File > Convert > XML**

### Opcao C - Usando JDeveloper (Oracle ADF)

- JDeveloper 12c pode abrir `.fmb` e exportar para XML

---

## Scripts disponiveis

| Script | Descricao |
|--------|-----------|
| `Convert-FmbToXml.ps1` | Converte `.fmb` -> `.xml` usando `frmf2xml` ou Java direto |
| `Extract-FormsMetadata.ps1` | Le o XML gerado e extrai 12 relatorios organizados |

---

## Uso

### Passo 1 - Converter `.fmb` para `.xml`

```powershell
.\Convert-FmbToXml.ps1 -FmbPath "C:\CVS\web_10g\fmb\pln\meu_form.fmb"
```

Parametros:

| Parametro | Default | Descricao |
|---|---|---|
| `-FmbPath` | (obrigatorio) | Caminho do `.fmb` ou pasta com `.fmb`s (recursivo) |
| `-OracleHome` | `$env:ORACLE_HOME` | Caminho do ORACLE_HOME |
| `-OutputDir` | mesma pasta do `.fmb` | Onde gravar o `.xml` resultante |

### Passo 2 - Extrair metadados do XML

```powershell
.\Extract-FormsMetadata.ps1 `
  -XmlPath "C:\CVS\web_10g\fmb\pln\meu_form.xml" `
  -OutputDir ".\output" `
  -Format md
```

Parametros:

| Parametro | Default | Descricao |
|---|---|---|
| `-XmlPath` | (obrigatorio) | Caminho do `.xml` ou pasta com `.xml`s |
| `-OutputDir` | `.\output` | Onde gravar os 12 relatorios |
| `-Format` | `txt` | `txt` ou `md` (Markdown) |

### Saida gerada (12 arquivos por modulo)

```
output/
  meu_form_RESUMO.txt           # Visao geral de todos os objetos
  meu_form_WINDOWS.txt          # Configuracoes de janelas
  meu_form_CANVAS.txt           # Canvas e layouts
  meu_form_BLOCKS.txt           # Blocos e items (com propriedades)
  meu_form_TRIGGERS.txt         # Todos os triggers com codigo PL/SQL
  meu_form_PROGRAM_UNITS.txt    # Procedures/Functions PL/SQL
  meu_form_LOVS.txt             # Lists of Values
  meu_form_ALERTS.txt           # Alertas
  meu_form_PARAMETERS.txt       # Parametros do form
  meu_form_RELATIONS.txt        # Relacoes master-detail entre blocos
  meu_form_VISUAL_ATTRS.txt     # Atributos visuais (cores, fontes)
  meu_form_RECORD_GROUPS.txt    # Record groups (queries de LOV)
```

---

## Estrutura do XML gerado pelo `frmf2xml`

O XML do Oracle Forms contem a hierarquia:

```
<Module>
  +-- <FormParameter>          # Parametros de entrada
  +-- <Alert>                  # Alertas
  +-- <Block>                  # Blocos de dados
  |   +-- <Item>               # Campos/Items (tipo, posicao, tamanho)
  |   +-- <Trigger>            # Triggers do bloco
  |   +-- <Relation>           # Relacoes master-detail
  +-- <Canvas>                 # Canvas (layout visual)
  |   +-- <Graphics>           # Elementos graficos
  +-- <Coordinate>             # Sistema de coordenadas
  +-- <Editor>                 # Editores
  +-- <LOV>                    # Lists of Values
  +-- <ObjectGroup>            # Grupos de objetos
  +-- <ProgramUnit>            # Procedures/Functions PL/SQL
  +-- <PropertyClass>          # Classes de propriedade
  +-- <RecordGroup>            # Record groups (queries)
  +-- <Trigger>                # Triggers do form (nivel modulo)
  +-- <VisualAttribute>        # Atributos visuais
  +-- <Window>                 # Janelas
```

---

## Integracao com a skill `engenharia-reversa-forms`

A skill dispara este pipeline durante o **Passo 1 (Pipeline de extracao)** do seu protocolo.
A LLM nao deve ler o XML bruto - sempre consumir os 12 relatorios `.txt`/`.md` gerados pela
Etapa 2.

Caminho de saida recomendado dentro do projeto consumidor:

```
.specs/reverse-engineering/forms/<MODULO>/rev-NNN-<TAG_CVS>/
  raw/                          # XML bruto da Etapa 1
    <MODULO>.xml
  parsed/                       # 12 relatorios da Etapa 2
    <MODULO>_RESUMO.txt
    <MODULO>_WINDOWS.txt
    ...
  reversa-<MODULO>.md           # Artefato canonico produzido pela skill (Passo 6)
```

---

## Pasta `output/` deste tool

Esta pasta contem **dados de exemplo** gerados durante o desenvolvimento do tool (forms da
area Comercial: t02pr, t229b, t22zs, t3026, taffix). E excluida do versionamento Git via
`.gitignore` da raiz do framework para evitar inflar o repo. Em uso normal pela skill, a
saida vai para `.specs/reverse-engineering/forms/...` no projeto consumidor.

---

## Guardrails

- `[GUARDRAIL]` `.fmb` deve vir do **CVS tag PRODUCAO**, nunca de copia local nao versionada
- `[GUARDRAIL]` Anonimizar dados em hard-coded values, comentarios, exemplos de massa
- `[GUARDRAIL]` Tool nao acessa banco produtivo - apenas leitura de arquivos `.fmb`/`.xml`
