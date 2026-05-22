# tools/

Utilitarios executaveis usados pelas skills do framework para tarefas que ultrapassam o
que a LLM consegue fazer sozinha (parsing de formatos binarios, extracao estruturada,
normalizacao de XML, etc).

Nao confundir com:

- `scripts/` - bootstrap e manutencao do framework (ex.: `init-spec-project.ps1`,
  `update-framework.ps1`). Sao executados pelo TL no terminal.
- `prompts/` - arquivos `.prompt.md` carregados pelo GitHub Copilot Agent Mode.
- `skills/` - definicoes textuais de skill (`SKILL.md`) que orquestram a LLM.

## Diferenca essencial

| Pasta | Quem invoca | Exemplo |
|---|---|---|
| `scripts/` | TL no terminal (PowerShell) | `init-spec-project.ps1` |
| `tools/` | **Skill** durante sua execucao (LLM dispara o tool) | `forms-extractor` |
| `prompts/` | TL no chat via slash command | `/spec-from-workitem` |
| `skills/` | Carregadas por inferencia ou trigger explicito | `engenharia-reversa-sigo` |

## Convencoes para tools

1. **Stack permitida**: PowerShell (preferencial em Windows) ou Python 3.11+ (quando o
   parsing exige bibliotecas especializadas).
2. **Cada tool tem subdiretorio proprio** com:
   - `<tool-name>/` - codigo
   - `<tool-name>/README-<tool-name>.md` - descricao, parametros, exemplos, dependencias
3. **Sem efeitos colaterais fora da feature em foco**: tools leem entrada, gravam saida em
   path indicado pelo invocador. Nao tocam configuracoes globais.
4. **Sem chamadas de rede nao autorizadas** - mesmas regras de guardrail das skills
   (proibido acessar banco produtivo, dados de beneficiario, etc).
5. **Idempotencia** - re-execucao com mesma entrada produz mesma saida.
6. **UTF-8 sem BOM** em todo arquivo gerado.
7. **Saidas grandes ficam fora do repo** - subpastas tipo `output/` devem ser ignoradas
   no `.gitignore` da raiz; o tool grava onde o invocador especifica via parametro.

## Tools registrados

### `forms-extractor/`

Pipeline de extracao Oracle Forms em 2 etapas. Consumido pela skill
[`engenharia-reversa-forms`](../skills/engenharia-reversa-forms/SKILL.md).

| Etapa | Script | Entrada | Saida |
|---|---|---|---|
| 1 | `Convert-FmbToXml.ps1` | `.fmb` (binario Oracle Forms) | `.xml` (Forms2XML) |
| 2 | `Extract-FormsMetadata.ps1` | `.xml` | 12 relatorios `.txt` ou `.md` (RESUMO, WINDOWS, CANVAS, BLOCKS, TRIGGERS, PROGRAM_UNITS, LOVS, ALERTS, PARAMETERS, RELATIONS, VISUAL_ATTRS, RECORD_GROUPS) |

Pre-requisitos: Oracle Forms Developer 10g+ instalado **OU** acesso aos JARs
`frmxmltools.jar`, `frmjdapi.jar`, `xmlparserv2.jar` em um `ORACLE_HOME` valido.
Detalhes em [`forms-extractor/README-forms-extractor.md`](forms-extractor/README-forms-extractor.md).

### `cvs-fetch-producao/`

Busca um modulo PL/SQL do WinCVS usando a tag `PRODUCAO_*` mais recente.
Etapa obrigatoria (Passo 0) do fluxo de engenharia reversa PL/SQL.
Consumido pelas skills [`engenharia-reversa-sigo`](../skills/engenharia-reversa-sigo/SKILL.md)
e pelo prompt [`hap-sd-re-plsql`](../prompts/hap-sd-re-plsql.prompt.md).

| Parametro | Obrigatorio | Descricao |
|---|---|---|
| `-Module` | Sim | Ex: `HUMASTER/PK_VENDA_JSON.pkb` |
| `-Tag` | Nao | Tag especifica; omitir para resolver automaticamente a mais recente |
| `-OutputDir` | Nao | Default: `.cvs-checkout/<OBJETO>/<TAG>/` |
| `-CvsHost` | Nao | Default: `$env:HAPVIDA_CVS_HOST` |
| `-CvsUser` | Nao | Default: `$env:HAPVIDA_CVS_USER` |

**Saida:** arquivo fonte + `cvs-fetch-evidence.json` (host, tag, SHA-256).

**Setup interativo:** na primeira execucao sem credenciais, o tool solicita host/usuario/senha
iterativamente, executa `cvs login` e oferece persistir host/usuario em `.cvs-env.ps1`
(sem senha; arquivo no `.gitignore`). Ate 3 tentativas antes de emitir `[BLOQUEADO]`.

Pre-requisitos: `cvs.exe` no PATH, conectividade TCP na porta 2401.
Detalhes em [`cvs-fetch-producao/README-cvs-fetch-producao.md`](cvs-fetch-producao/README-cvs-fetch-producao.md).

## Como uma skill invoca um tool

A skill referencia o tool no seu `SKILL.md` na secao **Pre-requisitos** ou **Passos**, com
caminho relativo a partir da raiz do framework. O agente LLM dispara o tool como Bash/PowerShell
durante a execucao, captura stdout/stderr e processa a saida estruturada.

Exemplo de invocacao em uma skill:

```powershell
# Etapa 1
tools/forms-extractor/Convert-FmbToXml.ps1 `
  -FmbPath <path-cvs-PRODUCAO>/<MODULO>.fmb `
  -OutputDir .specs/reverse-engineering/forms/<MODULO>/rev-NNN-<TAG>/raw/

# Etapa 2
tools/forms-extractor/Extract-FormsMetadata.ps1 `
  -XmlPath .specs/reverse-engineering/forms/<MODULO>/rev-NNN-<TAG>/raw/<MODULO>.xml `
  -OutputDir .specs/reverse-engineering/forms/<MODULO>/rev-NNN-<TAG>/parsed/ `
  -Format md
```

A LLM le os 12 arquivos `.txt`/`.md` resultantes para extrair regras, dependencias e smells
durante o protocolo da skill (Passos 0-6).

---

**Versao:** 0.1
**ADR aplicavel:** (a registrar - candidato ADR-013)
