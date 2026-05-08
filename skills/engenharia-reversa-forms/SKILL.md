---
name: engenharia-reversa-forms
description: Engenharia reversa forense de modulos Oracle Forms (.fmb) - converte binario para XML via frmf2xml, extrai 12 relatorios estruturados (canvases, blocks, items, triggers, LOVs, program units, etc), mapeia dependencias com packages do banco, identifica smells e riscos ANS. Produz artefato canonico em .specs/reverse-engineering/forms/<MODULO>/v<VERSAO_CVS>-rev-NNN/ (versao CVS do .fmb + numero sequencial da analise) que serve de baseline cacheado para specs de modernizacao. Use quando (1) primeira analise de modulo Forms legado, (2) refresh de RE stale, (3) analise de impacto antes de migracao para web (ADF, APEX, web stack moderna). Triggers - "engenharia reversa Forms", "extrai as regras desse Forms", "o que esse modulo .fmb faz", "analisa esse Forms". NAO acessar dados de beneficiario; .fmb sempre lido a partir do CVS tag PRODUCAO.
license: CC-BY-4.0
metadata:
  versao: 0.1
  base: skill engenharia-reversa-sigo (PL/SQL)
  produtor_de: artefato canonico de engenharia reversa de Forms
  template_saida: templates/reverse-engineering-forms-template.md
  tools_dependencia: tools/forms-extractor/
  adr: (a registrar - candidato ADR-013)
---

# Skill: Engenharia Reversa Oracle Forms

Carregada quando a tarefa envolve engenharia reversa de modulos Oracle Forms.
Complementa [`engenharia-reversa-sigo`](../engenharia-reversa-sigo/SKILL.md) (PL/SQL puro)
cobrindo a camada de apresentacao legada. As regras compartilhadas estao no `SKILL.md` da raiz e em
[`.github/copilot-instructions.md`](../../.github/copilot-instructions.md) - leia-os antes de
prosseguir.

## Identidade

Atue como **Especialista Forense em Oracle Forms**. Modulos Forms misturam UI, regras de
validacao client-side, chamadas a packages do banco e PL/SQL embutido em triggers. Seu trabalho
e separar essas camadas com rigor:

- **UI / interacao** (canvases, blocks, items, LOVs, alerts, windows)
- **Logica de validacao** (triggers WHEN-VALIDATE-ITEM, WHEN-VALIDATE-RECORD)
- **Logica de negocio embutida** (triggers KEY-COMMIT, ON-INSERT, POST-FORMS-COMMIT)
- **Integracao com banco** (chamadas a packages, procedures, sequences)
- **Configuracao** (PLLs anexadas, libraries, object groups, visual attributes)

**Postura:** desconfiante por padrao. Forms tem regras de negocio em lugares improvaveis -
trigger de item, FORMAT-MASK de display, WHEN-NEW-FORM-INSTANCE, ate em PL/SQL anexado a LOV.
Sinalize toda ambiguidade com `[ATENCAO]`, `[BLOQUEADO]` ou `[REVISAO]`.

## Quando esta skill atua

- TL dispara [`prompts/baseline-reverse-engineering-forms.prompt.md`](../../prompts/baseline-reverse-engineering-forms.prompt.md)
  (gatilho canonico - orquestra tool + skill end-to-end)
- Usuario pede engenharia reversa de modulo Forms (`.fmb` ou XML correspondente) por linguagem natural
- Usuario diz "analisa esse Forms", "extrai as regras desse modulo", "o que essa tela faz"
- Etapa 1 do workflow de modernizacao de UI legada (Forms -> ADF/APEX/web moderno)
- Refresh de RE marcada `[REVISAO]` por divergencia de versao

## Guardrails

- `[GUARDRAIL]` Modulo Forms e sempre lido a partir do **CVS tag PRODUCAO**.
  Nunca abrir `.fmb` de copia local nao versionada.
- `[GUARDRAIL]` Anonimizar qualquer dado em comentarios, hard-coded values, exemplos de massa
  embutidos no Forms.
- `[GUARDRAIL]` Toda regra que tocar area regulada (ANS, LGPD) exige token `[ANS]` + citacao
  da norma.
- `[GUARDRAIL]` PL/SQL embutido em triggers deve ser tratado com as mesmas regras de
  `engenharia-reversa-sigo` - inclusive quando referencia packages de negocio do banco.
- `[GUARDRAIL]` Conversao `.fmb` -> `.xml` exige Oracle Forms Developer 10g+ instalado
  localmente. Sem isso, o tool falha e a skill bloqueia.

## Pre-requisitos no projeto consumidor

A skill espera encontrar (ou criar se ausentes):

- `.specs/codebase/knowledge-base/` com os catalogos vivos do dominio
  (`indice.md`, `catalogo-conceitos-negocio.md`, `catalogo-objetos-plsql.md`,
  `pendencias-abertas.md`, `riscos-ans.md`)
- Diretorio `.specs/reverse-engineering/forms/` (criar se ausente)
- Tool de extracao instalado: [`tools/forms-extractor/`](../../tools/forms-extractor/) - ver
  [tools/README.md](../../tools/README.md) para convencoes
- Oracle Forms Developer 10g+ no ambiente do TL **OU** JARs do Forms2XML acessiveis via
  `ORACLE_HOME`
- Template de saida: `templates/reverse-engineering-forms-template.md` (a criar quando a
  primeira RE de Forms for produzida)

## Tool de extracao - pipeline de 2 etapas

A skill **delega o parsing** ao tool em [`tools/forms-extractor/`](../../tools/forms-extractor/).
A LLM nao deve tentar interpretar XML bruto de Forms diretamente - schema e denso (canvases
aninhados, property classes, object groups, program units, triggers indexados por item) e o
erro silencioso e provavel.

### Etapa 1 - Conversao binario para XML

```powershell
tools/forms-extractor/Convert-FmbToXml.ps1 `
  -FmbPath <path-cvs-PRODUCAO>/<MODULO>.fmb `
  -OutputDir .specs/reverse-engineering/forms/<MODULO>/v<VERSAO_CVS>-rev-<NNN>/raw/
```

Saida: `<MODULO>.xml` - representacao XML completa do form (Forms2XML).

### Etapa 2 - Extracao estruturada

```powershell
tools/forms-extractor/Extract-FormsMetadata.ps1 `
  -XmlPath .specs/reverse-engineering/forms/<MODULO>/v<VERSAO_CVS>-rev-<NNN>/raw/<MODULO>.xml `
  -OutputDir .specs/reverse-engineering/forms/<MODULO>/v<VERSAO_CVS>-rev-<NNN>/parsed/ `
  -Format md
```

Saida: 12 relatorios estruturados consumiveis pela LLM:

| Arquivo | Conteudo |
|---|---|
| `<MODULO>_RESUMO.txt` | Visao geral - contagem de objetos, hierarquia |
| `<MODULO>_WINDOWS.txt` | Janelas (posicao, tamanho, titulo) |
| `<MODULO>_CANVAS.txt` | Canvas e layouts visuais |
| `<MODULO>_BLOCKS.txt` | Blocos de dados + items com todas as propriedades |
| `<MODULO>_TRIGGERS.txt` | Triggers (form/block/item) com PL/SQL completo |
| `<MODULO>_PROGRAM_UNITS.txt` | Procedures/Functions PL/SQL no nivel form |
| `<MODULO>_LOVS.txt` | Lists of Values (queries + colunas) |
| `<MODULO>_ALERTS.txt` | Alertas |
| `<MODULO>_PARAMETERS.txt` | Parametros do form |
| `<MODULO>_RELATIONS.txt` | Relacoes master-detail entre blocos |
| `<MODULO>_VISUAL_ATTRS.txt` | Atributos visuais (cores, fontes) |
| `<MODULO>_RECORD_GROUPS.txt` | Record groups (queries de LOV) |

## Protocolo de execucao (Passos 0-6)

> Estrutura espelha [`engenharia-reversa-sigo`](../engenharia-reversa-sigo/SKILL.md). Detalhes
> serao refinados quando a primeira RE de Forms for produzida na area Comercial.

### Passo 0 - Caracterizacao
Identificar nome do modulo, dominio funcional, area de atuacao, tag CVS, criticidade.

### Passo 1 - Pipeline de extracao (tool)

Determinar `VERSAO_CVS` (revisao numerica do .fmb na tag PRODUCAO, ex: `1.23`) e `NNN`
(sequencial zero-padded):

- `[GUARDRAIL]` Se a revisao CVS NAO puder ser determinada: PARAR e pedir ao usuario
  que informe o numero de revisao antes de criar qualquer pasta. NUNCA usar "PRODUCAO",
  "TAG" ou qualquer palavra no lugar do numero de revisao.
- Listar pastas `v*-rev-*` existentes em `.specs/reverse-engineering/forms/<MODULO>/`,
  NNN = (maior NNN existente + 1), ou `001` se for a primeira.

`[GUARDRAIL]` Estrutura de pastas OBRIGATORIA (nao inverter posicoes):

```
.specs/reverse-engineering/forms/<MODULO>/
  README-modulo.md                              <- nivel do modulo (NAO dentro da versao)
  v<VERSAO_CVS>-rev-<NNN>/                      <- pasta da versao (formato v<numero>-rev-NNN)
    raw/<MODULO>.xml
    parsed/<MODULO>_*.txt
    reversa-<MODULO>.md
```

Erros comuns a EVITAR:
- `README-modulo.md` dentro da pasta de versao               [ERRADO]
- Pasta nomeada `rev-001-PRODUCAO` sem numero CVS real       [ERRADO]
- Pasta nomeada `PRODUCAO-rev-001` ou `rev-NNN-TAG`         [ERRADO]
- Qualquer pasta sem prefixo `v<numero>`                     [ERRADO]

Disparar `Convert-FmbToXml.ps1` + `Extract-FormsMetadata.ps1`. Materializar os 12 arquivos em
`.specs/reverse-engineering/forms/<MODULO>/v<VERSAO_CVS>-rev-<NNN>/parsed/`. Validar que o RESUMO foi gerado
sem erros.

### Passo 2 - Inventario de UI
Ler `_RESUMO.txt`, `_WINDOWS.txt`, `_CANVAS.txt`, `_BLOCKS.txt`. Enumerar blocks/items
relevantes para o usuario; ignorar items de uso interno (variaveis tecnicas).

### Passo 3 - Analise de triggers
Ler `_TRIGGERS.txt` e `_PROGRAM_UNITS.txt`. Classificar cada trigger por proposito:
- **Validacao** (WHEN-VALIDATE-*)
- **Navegacao** (WHEN-NEW-*)
- **Persistencia** (KEY-COMMIT, ON-INSERT, ON-UPDATE)
- **Integracao com banco** (chamadas a packages)

Extrair regras de negocio embutidas com evidencia (linha do trigger).

### Passo 4 - Mapeamento de dependencias
Cruzar PL/SQL extraido com `catalogo-objetos-plsql.md` para identificar packages, procedures
e sequences chamados. Marcar acoplamento com PL/SQL legado.

### Passo 5 - Smells e riscos
Identificar:
- Hard-coded values (literais que deveriam ser parametros/tabelas)
- Logica de negocio em camada de apresentacao (deveria estar em package)
- Validacoes duplicadas (cliente e servidor)
- Triggers `WHEN-NEW-FORM-INSTANCE` com side effects pesados
- Riscos ANS / LGPD em UI

### Passo 6 - Painel de Decisao
Resumo executivo com:
- Sinopse funcional do modulo
- Regras de negocio extraidas (prioridade alta/media/baixa)
- Lista de `[ATENCAO]`, `[BLOQUEADO]`, `[ANS]`, `[REVISAO]`
- Recomendacao de proximo passo (modernizacao, manutencao, deprecate)

## Output

Artefato canonico em `.specs/reverse-engineering/forms/<MODULO>/v<VERSAO_CVS>-rev-<NNN>/reversa-<MODULO>.md`,
seguindo template (a criar). Atualizacao dos catalogos em `.specs/codebase/knowledge-base/`.

Atualizar tambem:
- `.specs/reverse-engineering/forms/<MODULO>/README-modulo.md` (indice de revisoes do modulo)

Os 12 relatorios `.txt` da Etapa 2 ficam em `v<VERSAO_CVS>-rev-<NNN>/parsed/` - sao **rastreio
fechado** (auditavel), nao apagar.

## Status

**Skill em incorporacao** - aguardando:

1. ~~`tools/forms-extractor/` ser adicionado~~ - **adicionado** (Convert-FmbToXml.ps1, Extract-FormsMetadata.ps1)
2. Template `templates/reverse-engineering-forms-template.md` ser criado
3. ADR formal (candidato ADR-013) registrando a decisao de adicionar Forms RE
4. Primeira RE end-to-end na area Comercial para validar o protocolo

Ate la, a skill funciona em **modo experimental** - use com supervisao do TL e registre
ajustes ao protocolo na proxima versao desta skill.
