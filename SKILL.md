---
name: hapvida-spec-driven
description: Framework de desenvolvimento spec-driven adaptado ao Hapvida (Azure DevOps, WinCVS, ANS, GitHub Copilot Claude). Quatro fases adaptativas - Specify, Design, Tasks, Execute. Auto-sizing por complexidade. Spec versionada em ADO Repos com snapshot anexado ao work item via MCP do Azure DevOps. Camada fina sobre Agile Hapvida 2.0. Use quando (1) iniciando uma feature/incident/defect/user story standalone que exige spec, (2) trabalhando codigo legado PL/SQL com refatoracao (Improvement+Tunning), (3) implementando feature regulatoria (touche ANS), (4) precisando rastrear decisoes (STATE.md), (5) pausando/retomando trabalho. Triggers - "specify feature", "design feature", "break into tasks", "implement task", "validate feature", "map codebase", "initialize project", "pause work", "resume work". NAO usar para Quick Mode (fora do escopo do piloto). NAO acessar banco produtivo via MCP - sempre WinCVS tag PRODUCAO.
license: CC-BY-4.0
metadata:
  versao: 0.2
  base: TLC Spec-Driven (Tech Lead's Club)
  area_piloto: Comercial - venda de planos
---

# Framework Spec-Driven Hapvida

Adaptacao do framework TLC para o ecossistema Hapvida. Plan and implement com precisao,
ancorado no Azure DevOps, respeitando regulacao ANS e a infraestrutura existente.

```
+----------+    +----------+    +---------+    +---------+
| SPECIFY  | -> |  DESIGN  | -> |  TASKS  | -> | EXECUTE |
+----------+    +----------+    +---------+    +---------+
  obrigatorio    opcional*       opcional*     obrigatorio

* Auto-skip baseado em complexidade
```

## Auto-Sizing - principio central

**A complexidade determina a profundidade, nao um pipeline fixo.** Antes de iniciar
qualquer feature, avalie escopo e aplique apenas o necessario:

| Escopo | Specify | Design | Tasks | Execute |
|---|---|---|---|---|
| **Pequeno** (≤3 arquivos, frase de escopo) | Spec inline (frontmatter + secoes minimas) | Skip | Skip | Implementar + verificar |
| **Medio** (feature clara, <10 tasks) | Spec completa | Skip - design inline | Skip - tasks implicitas | Implementar + verificar |
| **Grande** (multi-componente) | Spec + IDs de traceability | Arquitetura + componentes | Decomposicao + dependencias | Implementar por task + commit atomico |
| **Complexo** (ambiguidade, dominio novo) | Spec + [Discuss](references/discuss.md) | Arquitetura + pesquisa via Knowledge Verification Chain | Decomposicao + paralelismo | Implementar + UAT interativo |

**Regras:**

- Specify e Execute sao **sempre obrigatorios** - precisamos saber O QUE e FAZER.
- Design e Tasks sao **auto-skip** quando a mudanca e direta.
- Discuss e disparado **dentro de Specify** quando ha gray areas em comportamento user-facing.
- UAT interativo e disparado **dentro de Execute** apenas para features user-facing complexas.
- **Quick Mode (atalho TLC) NAO esta no escopo do piloto** - ver [ADR 008](adr/008-quick-mode-fora-do-escopo-piloto.md).

**Valvula de seguranca:** mesmo quando Tasks e pulada, Execute SEMPRE comeca listando passos atomicos
inline (ver [implement.md](references/implement.md)). Se essa listagem revelar >5 passos ou dependencias
complexas, PARE e crie `tasks.md` formal - a fase Tasks foi indevidamente pulada.

## Estrutura de pastas dos projetos

Cada squad usa `.specs/` no proprio repositorio (Java/.NET em ADO Repos) ou em repositorio
paralelo dedicado (PL/SQL CVS - repo em ADO Repos so para specs):

```
.specs/
├── project/
│   ├── PROJECT.md         # Visao do squad
│   ├── ROADMAP.md         # Milestones e features
│   ├── STATE.md           # OBRIGATORIO - memoria persistente do squad
│   └── HANDOFF.md         # Quando aplica - pausa de sessao
├── codebase/              # Brownfield - quando aplicavel
│   ├── STACK.md
│   ├── ARCHITECTURE.md
│   ├── CONVENTIONS.md
│   ├── STRUCTURE.md
│   ├── TESTING.md
│   ├── INTEGRATIONS.md
│   └── CONCERNS.md
└── features/[feature]/
    ├── spec.md            # WHAT - sempre
    ├── context.md         # Decisoes de gray areas - quando Discuss e disparado
    ├── design.md          # HOW - para Grande/Complexo
    └── tasks.md           # Decomposicao - para Grande/Complexo
```

## Fluxos de trabalho

### Novo squad

1. `Initialize project` -> cria `.specs/project/PROJECT.md`, `ROADMAP.md`, `STATE.md`
2. Para cada feature: aplique fluxo adaptativo (Specify -> Design -> Tasks -> Execute)

### Squad com codigo existente (especialmente PL/SQL legado)

1. `Map codebase` -> cria 7 docs em `.specs/codebase/` (brownfield mapping)
2. `Initialize project` -> cria `.specs/project/`
3. Para cada feature: aplique fluxo adaptativo

### Refatoracao PL/SQL (Improvement + Tunning)

1. **Engenharia reversa do baseline** a partir da tag `PRODUCAO` no WinCVS (NUNCA producao)
2. `Specify` com template `spec-improvement-tunning` que carrega Ficha de Tunning
3. `Design` referencia ADRs aplicaveis da wiki Arquitetura-Referencia (ADR 22 Padrao Repositorio, ADR 74 DDD, etc)
4. `Tasks` decomposto em refatoracoes atomicas
5. `Execute` com convencao de cabecalho de procedure citando `WI-####` e `SPEC-####`

## Estrategia de carregamento de contexto

**Carga base (~15k tokens):**

- `PROJECT.md` (se existir)
- `ROADMAP.md` (quando planejando ou trabalhando em features)
- `STATE.md` (memoria persistente - obrigatorio em projeto individual)

**Carga sob demanda:**

- Docs de codebase (em projeto existente)
- `CONCERNS.md` (ao tocar areas frageis ou planejar refatoracao)
- `TESTING.md` (ao criar tasks ou executar)
- `spec.md` (na feature em foco)
- `context.md` (ao designar/implementar a partir das decisoes)
- `design.md` (ao implementar)
- `tasks.md` (ao executar)

**Nunca carregar simultaneamente:**

- Specs de multiplas features
- Multiplos docs de arquitetura
- Documentos arquivados

**Alvo:** <40k tokens carregados (ver [`references/context-limits.md`](references/context-limits.md))

## Knowledge Verification Chain (cadeia de verificacao)

Antes de qualquer decisao tecnica, design ou pesquisa, siga ESTA ORDEM (ver [`references/knowledge-verification.md`](references/knowledge-verification.md)):

```
Passo 1: Codebase
  - PL/SQL: WinCVS tag PRODUCAO (NUNCA banco produtivo)
  - Java/.NET: ADO Repos main
Passo 2: Project docs
  - .specs/codebase/, .specs/features/
  - Wiki Arquitetura-Referencia (ADRs corporativas)
Passo 3: Context7 MCP
  - Para libraries, frameworks, APIs
Passo 4: Web search
  - Documentacao oficial ANS, padroes
Passo 5: Flag uncertain
  - "Nao sei" e SEMPRE preferivel a inventar
```

**Regras inegociaveis:**

- Nunca pular para Step 5 se Steps 1-4 sao acessiveis
- Step 5 e SEMPRE marcado como `[REVISAO]` ou `[BLOQUEADO]` - nunca apresentado como fato
- **NUNCA inventar APIs, padroes, comportamentos.** Se nao encontrar, marque incerteza explicitamente.

## MCP Azure DevOps - autorizado para metadados

| Uso | Autorizado? |
|---|---|
| Acessar/atualizar work items | Sim - via `@azure-devops/mcp` local |
| Anexar spec/design/tasks como snapshot ao work item | Sim - acionado pelo TL via prompt file |
| Ler PRs, commits, builds | Sim |
| Acessar wiki Arquitetura-Referencia | Sim |
| **MCP de banco Oracle produtivo** | **PROIBIDO** - sempre WinCVS tag PRODUCAO |

Configuracao em [`references/mcp-integration.md`](references/mcp-integration.md).

## Comandos de gatilho

### Project-level

| Frase / Comando | Referencia |
|---|---|
| Initialize project, setup project | [`references/project-init.md`](references/project-init.md) |
| Create roadmap, plan features | [`references/roadmap.md`](references/roadmap.md) |
| Map codebase, analyze existing code | [`references/brownfield-mapping.md`](references/brownfield-mapping.md) |
| Document concerns, find tech debt | [`references/concerns.md`](references/concerns.md) |
| Record decision, log blocker, add todo | [`references/state-management.md`](references/state-management.md) |
| Pause work, end session, Resume work | [`references/session-handoff.md`](references/session-handoff.md) |

### Feature-level (auto-sized)

| Frase / Comando | Referencia |
|---|---|
| Specify feature, define requirements | [`references/specify.md`](references/specify.md) |
| Discuss feature, capture context | [`references/discuss.md`](references/discuss.md) |
| Design feature, architecture | [`references/design.md`](references/design.md) |
| Break into tasks, create tasks | [`references/tasks.md`](references/tasks.md) |
| Implement task, build, execute | [`references/implement.md`](references/implement.md) |
| Validate, verify, UAT | [`references/validate.md`](references/validate.md) |
| Publish snapshot to work item | [`prompts/spec-publish-snapshot.prompt.md`](prompts/spec-publish-snapshot.prompt.md) |

## Tipos de spec por matriz Demand Type x Value Area

A spec a aplicar e determinada pela combinacao de campos do work item:

| Demand Type | Value Area | Template |
|---|---|---|
| Project | Business | [`spec-project-business.md`](templates/spec-project-business.md) |
| Improvement | Business | [`spec-improvement-business.md`](templates/spec-improvement-business.md) |
| **Improvement** | **Tunning** | [`spec-improvement-tunning.md`](templates/spec-improvement-tunning.md) **(refatoracao PL/SQL)** |
| Maintenance | Business | [`spec-maintenance-business.md`](templates/spec-maintenance-business.md) |
| Maintenance | Tunning | [`spec-maintenance-tunning.md`](templates/spec-maintenance-tunning.md) |
| Incident criticidade alta/media | (qualquer) | [`spec-incident-fast-track.md`](templates/spec-incident-fast-track.md) |

## Quando spec e obrigatoria

| Tipo de work item | Spec? |
|---|---|
| Feature | **Sim - canonico** |
| Incident criticidade alta/media | **Sim** (fast-track ou completa) |
| Defect criticidade alta/media | **Sim** |
| User Story standalone | **Sim - enxuta** |
| User Story filha de Feature com spec | **Herda** |
| Epic | Nao - PRD/visao |
| Bug, Request, Task, Impediment | Nao |

## Output Behavior

**Orientacao para o agente Copilot:**

- Tom conversacional em portugues, sem emojis em artefatos formais
- Use tokens textuais: `[ATENCAO]`, `[BLOQUEADO]`, `[REVISAO]`, `[ANS]`, `[REF: id]`, `[ADR-AUSENTE]`, `[MIGRACAO]`, `[GUARDRAIL]`, `[OK]`, `[PREMISSA]`
- Encoding UTF-8 sem BOM em todo arquivo gerado
- Para tarefas leves (validacao, handoff), comente uma vez que modelos mais rapidos cumprem bem - registre em STATE.md `Preferences` para nao repetir
- Para tarefas pesadas (brownfield, refatoracao PL/SQL complexa), use Claude Opus

## Code Analysis

Use ferramentas locais com graceful degradation: `ast-grep` > `ripgrep` > `grep`.
Ver [`references/code-analysis.md`](references/code-analysis.md). NUNCA acessar banco produtivo.

## Skill Integrations

Quando disponiveis no ambiente do dev, prefira:

- **`sigo-modernizacao-plsql`** para engenharia reversa de PL/SQL e extracao de regras
- **`sigo-refatoracao-workflow`** para fluxo completo de refatoracao
- **`plsql-oracle-expert`** para code review PL/SQL com regras ANS

Estas skills foram desenvolvidas internamente e ja respeitam os guardrails Hapvida.
