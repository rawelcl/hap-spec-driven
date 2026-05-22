---
mode: 'agent'
description: 'Mapear codebase existente em 7 documentos em .specs/codebase/ (brownfield mapping)'
---

> **[HAP-SDD]** Hapvida Desenvolvimento Spec-Driven · [`SKILL.md`](../SKILL.md)

# Tarefa

Executar o brownfield mapping do codebase atual, produzindo os 7 documentos canônicos em
`.specs/codebase/` para que o framework opere com contexto real do projeto.

# Input obrigatorio - se ausente, PARE e pergunte ao TL antes de qualquer analise

Antes de executar qualquer passo abaixo, confirme os itens 1-5 em **uma unica mensagem** ao TL e
aguarde resposta. **Nao prossiga com defaults silenciosos** - se o TL nao respondeu ou respondeu
parcialmente, repita a pergunta apenas para os campos faltantes.

| # | Campo | Obrigatorio? | Default permitido |
|---|---|---|---|
| 1 | **Stack predominante** (PLSQL \| Java \| DotNet \| Mista) | Sim | Nenhum - sempre perguntar |
| 2 | **Raiz do codebase** (caminho relativo) | Sim | `.` (workspace atual) - so usar se TL confirmar |
| 3 | **Paths a IGNORAR** alem do `.gitignore` | Sim | Nenhum - mas sugerir `.specs/`, `workspace/`, `examples/`, `templates/`, `prompts/`, `references/` quando o repo for o proprio framework |
| 4 | **Para PL/SQL**: TAG DE PRODUCAO no WinCVS (`cvs log` ou explicita) | Sim se stack=PLSQL/Mista | Nenhum |
| 5 | **Areas de foco** (modulos, packages, servicos prioritarios) | Nao | Vazio = varrer tudo dentro da raiz |

Formato sugerido de pergunta ao TL (envie em uma so mensagem):

> Para rodar o brownfield mapping, preciso confirmar:
> 1. Stack predominante? (PLSQL | Java | DotNet | Mista)
> 2. Raiz do codebase? (padrao `.` - confirma?)
> 3. Paths a ignorar alem do `.gitignore`? (ex: `examples/`, `workspace/`)
> 4. [se PL/SQL] Qual tag PRODUCAO do WinCVS usar como baseline?
> 5. Areas de foco prioritarias? (opcional)

# Passos

1. **Verificar pre-condicoes** (apos receber os inputs)
   - Estamos na raiz de um repositorio Git (ou workspace configurado)? Se nao, alerte.
   - `.specs/codebase/` ja existe com conteudo? Confirme com o TL antes de sobrescrever.
   - Os paths informados em "Raiz" e "Areas de foco" existem no disco? Se nao, alerte e pare.

2. **Analisar o codebase** (graceful degradation: `ast-grep` > `ripgrep` > `grep`)
   - Identifique linguagens, frameworks, estrutura de diretorios, padroes de naming
   - Para PL/SQL: identifique packages, procedures, functions, triggers - **via WinCVS tag PRODUCAO**
   - Para Java/.NET: identifique modulos, servicos, dependencias do build tool
   - **Reducao de `[REVISAO]` via dicionario Oracle**: antes de marcar `[REVISAO]` para
     metadados de banco (lista de packages, dependencias, constraints, indices, jobs),
     tente resolver via MCP Oracle consultando apenas as views autorizadas por
     [ADR-007](../adr/007-guardrail-acesso-producao.md) Excecao 1: `dba_objects`,
     `dba_dependencies`, `dba_constraints`, `dba_indexes`, `dba_scheduler_jobs`,
     `plan_table`. `dba_source` segue PROIBIDO - fonte de codigo eh exclusivamente
     WinCVS tag PRODUCAO. Versao do banco, ambientes, raiz do CVS, encoding e demais
     metadados que NAO estejam cobertos pela Excecao 1 permanecem como `[REVISAO]`
     ate confirmacao com TL/DBA.

3. **Gerar os 7 documentos em `.specs/codebase/`**

   | # | Arquivo | Foco |
   |---|---|---|
   | 1 | `STACK.md` | Linguagens, frameworks, libraries, versoes |
   | 2 | `ARCHITECTURE.md` | Componentes principais, fluxo de dados, dependencias |
   | 3 | `STRUCTURE.md` | Layout de pastas, convencoes de naming |
   | 4 | `CONVENTIONS.md` | Padroes de codigo, estilo, comentarios, idiomas Hapvida |
   | 5 | `TESTING.md` | Tooling por approach + Test Coverage Matrix + Gate Check Commands + Parallelism Assessment (per [ADR-013](../adr/013-modelo-testes-co-localizado-por-task.md)) - ver passo 3.1 |
   | 6 | `INTEGRATIONS.md` | APIs externas, ServiceNow, Lecom, GMUD, SACTI |
   | 7 | `CONCERNS.md` | Tech debt, areas frageis, gaps, ADRs ausentes |

   ### 3.1 - Estrutura obrigatoria do TESTING.md (per ADR-013)

   O arquivo `TESTING.md` DEVE conter os 4 headers H2 abaixo, **nesta ordem**, com o
   vocabulario exato:

   ```
   ## Tooling por approach
   ## Test Coverage Matrix
   ## Gate Check Commands
   ## Parallelism Assessment
   ```

   Schema canonico (nao inventar colunas alternativas):

   - **Tooling por approach**: tabela com Approach (`automated|manual|hybrid|none`) +
     Stack + Tooling sugerido + Default artifact path
   - **Test Coverage Matrix**: tabela com Camada de mudanca + Approach default
     (`automated|manual|hybrid|none`) + Co-located? + Notas
   - **Gate Check Commands**: tabela com Nivel (`Quick|Full|Build`) + Approach + Comando
   - **Parallelism Assessment**: tabela com Approach + escopo + Parallel-Safe (`Yes|No`)

   Ver [references/brownfield-mapping.md](../references/brownfield-mapping.md) secao
   "Schema canonico" (linhas 60-101) para os templates exatos. Eixo `Automatizada/Manual`
   do schema antigo **NAO eh aceito** - usar sempre os 4 valores oficiais.

4. **Para projetos com legado PL/SQL**: criar tambem a knowledge base

   ```
   .specs/codebase/knowledge-base/
     indice.md
     catalogo-conceitos-negocio.md
     catalogo-objetos-plsql.md
     pendencias-abertas.md
     riscos-ans.md
   ```

   E criar o esqueleto de `.specs/reverse-engineering/README.md` com instrucao para
   executar [`/hap-sd-re-plsql`](hap-sd-re-plsql.prompt.md)
   antes de qualquer spec de refatoracao ([ADR-011](../adr/011-engenharia-reversa-como-baseline.md)).

5. **Marcar areas de incerteza** com `[REVISAO]` onde a analise automatica nao for
   conclusiva **apos ter tentado as fontes autorizadas** (passo 2: WinCVS para codigo,
   dicionario Oracle para metadados). Nao invente comportamentos - prefira
   `[REVISAO] confirmar com DBA/Arquiteto`. Toda marcacao `[REVISAO]` deve ter sufixo
   identificando quem precisa confirmar (DBA, TL, Compliance, Arquiteto).

6. **Auto-validacao antes de devolver os arquivos** (checklist obrigatorio)

   Antes do resumo final, percorra esta checklist e corrija o que encontrar. Reporte
   no resumo final qual item foi violado e como foi corrigido (ou justifique se ficou
   marcado como `[REVISAO]`).

   - [ ] Cada componente citado em `ARCHITECTURE.md` tem entrada em
         `catalogo-objetos-plsql.md` (e vice-versa)
   - [ ] Cada link `./reverse-engineering/...` aponta para um arquivo que existe no
         disco (ou esta marcado como `[REVISAO] RE pendente`)
   - [ ] IDs em `pendencias-abertas.md` sao **unicos** (sem `P-XXX` aparecendo duas
         vezes); pendencias resolvidas usam `~~P-XXX~~` consistente
   - [ ] Tag CVS de cada componente segue o mesmo padrao - se UMA tem data
         (`PRODUCAO_DDMMAAAA`), TODAS devem ter; se nao for possivel resolver, marcar
         `[REVISAO] tag CVS sem data - confirmar com DBA`
   - [ ] Riscos ANS em `riscos-ans.md` estao em **uma unica tabela** com colunas fixas
         (`ID + Risco + Norma + Severidade + Status + Acao`)
   - [ ] Nenhuma afirmacao em `catalogo-objetos-plsql.md` contradiz `ARCHITECTURE.md`
         ou `CONCERNS.md` (ex: dizer que rotina X "NAO faz Y" enquanto outro doc
         descreve o guard que decide se Y eh feito)
   - [ ] Cabecalho padronizado presente em **todos os 12 arquivos**:
         `Gerado em: YYYY-MM-DD | Tag CVS baseline: <tag> | Fontes: <REs>`
   - [ ] Tokens `[CRITICO]`, `[ANS]`, `[ADR-AUSENTE]`, `[REVISAO]`, `[GUARDRAIL]`
         usados conforme lista em `CONVENTIONS.md` (sem inventar variantes)
   - [ ] `TESTING.md` contem os 4 headers H2 oficiais do passo 3.1 (nao usar eixo
         `Automatizada/Manual`)

7. **Resumo final ao TL**
   - Liste os 7 arquivos criados e tamanho estimado de cada
   - Destaque os `[CONCERNS]` mais criticos encontrados
   - Reporte itens da checklist de auto-validacao que precisaram correcao
   - Proximos passos: validar com Arquiteto, iniciar specs de feature, ou executar
     `/hap-sd-re-plsql` para rotinas PL/SQL prioritarias
   - Commit sugerido: `WI-XXXX: docs(codebase): brownfield mapping inicial`
