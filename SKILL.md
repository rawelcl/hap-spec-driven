---
name: hapvida-spec-driven
description: Framework de desenvolvimento spec-driven adaptado ao Hapvida (Azure DevOps, WinCVS, ANS, GitHub Copilot Claude). Quatro fases adaptativas - Specify, Design, Tasks, Execute. Auto-sizing por complexidade. Spec versionada em ADO Repos com snapshot anexado ao work item via MCP do Azure DevOps. Camada fina sobre Agile Hapvida 2.0. Use quando (1) iniciando uma feature/incident/defect/user story standalone que exige spec, (2) trabalhando codigo legado PL/SQL com refatoracao (Improvement+Tunning), (3) implementando feature regulatoria (touche ANS), (4) precisando rastrear decisoes (STATE.md), (5) pausando/retomando trabalho. Triggers - "specify feature", "design feature", "break into tasks", "implement task", "validate feature", "map codebase", "initialize project", "pause work", "resume work". NAO usar para Quick Mode (fora do escopo do piloto). NAO acessar banco produtivo via MCP - sempre WinCVS tag PRODUCAO.
license: CC-BY-4.0
metadata:
  versao: 0.5
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
  obrigatorio    opcional*      obrigatorio**  obrigatorio

*  Auto-skip baseado em complexidade
** Sempre obrigatorio + sync automatico ao Azure DevOps
   ([REF: ADR-010](adr/010-tasks-obrigatorias-com-sync-ado.md))
```

## Auto-Sizing - principio central

**A complexidade determina a profundidade, nao um pipeline fixo.** Antes de iniciar
qualquer feature, avalie escopo e aplique apenas o necessario:

| Escopo | Specify | Design | Tasks | Execute |
|---|---|---|---|---|
| **Pequeno** (≤3 arquivos, frase de escopo) | Spec inline (frontmatter + secoes minimas) | Skip | Tasks minimas (1-3 itens, sem diagrama) + sync ADO | Implementar + verificar |
| **Medio** (feature clara, <10 tasks) | Spec completa | Skip - design inline | Tasks padrao (3-10 itens, fases simples) + sync ADO | Implementar + verificar |
| **Grande** (multi-componente) | Spec + IDs de traceability | Arquitetura + componentes | Decomposicao + dependencias + sync ADO | Implementar por task + commit atomico |
| **Complexo** (ambiguidade, dominio novo) | Spec + [Discuss](references/discuss.md) | Arquitetura + pesquisa via Knowledge Verification Chain | Decomposicao + paralelismo + sync ADO | Implementar + UAT interativo |

**Regras:**

- Specify, Tasks e Execute sao **sempre obrigatorios** - precisamos saber O QUE, COMO QUEBRAR e FAZER.
- **Tasks e sempre obrigatorio** - toda mudanca no Hapvida tem Task no Azure DevOps. `tasks.md` e
  sincronizado 1:1 com work items Task no ADO via MCP, vinculados a User Story / Feature pai
  ([REF: ADR-010](adr/010-tasks-obrigatorias-com-sync-ado.md)).
- Design e **auto-skip** quando a mudanca e direta (Pequeno / Medio).
- Discuss e disparado **dentro de Specify** quando ha gray areas em comportamento user-facing.
- UAT interativo e disparado **dentro de Execute** apenas para features user-facing complexas.
- **Quick Mode (atalho TLC) NAO esta no escopo do piloto** - ver [ADR 008](adr/008-quick-mode-fora-do-escopo-piloto.md).

**Valvula de seguranca:** quando Design e pulado, Tasks SEMPRE comeca listando os passos atomicos.
Se a decomposicao revelar >5 passos com dependencias complexas, PARE e crie `design.md` formal -
a fase Design foi indevidamente pulada.

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
│   ├── CONCERNS.md
│   └── knowledge-base/    # Catalogos vivos do dominio (PL/SQL legado)
│       ├── indice.md
│       ├── catalogo-conceitos-negocio.md
│       ├── catalogo-objetos-plsql.md
│       ├── pendencias-abertas.md
│       └── riscos-ans.md
├── reverse-engineering/   # Baselines cacheados (ADR-011) - segregados por tipo
│   ├── README.md          # Convencao de naming + indice
│   ├── plsql/             # procedures, functions, packages, triggers
│   │   └── <NOME_OBJETO>/
│   │       ├── README-rotina.md
│   │       ├── rev-001-<TAG_CVS>/   # numeracao sequencial zero-padded
│   │       │   └── reversa-<NOME_OBJETO>.md
│   │       └── rev-002-<TAG_CVS>/   # nova rev quando tag PRODUCAO divergir
│   │           └── reversa-<NOME_OBJETO>.md
│   └── forms/             # modulos Oracle Forms (.fmb)
│       └── <MODULO>/
│           ├── README-modulo.md
│           └── rev-001-<TAG_CVS>/
│               ├── raw/<MODULO>.xml          # Forms2XML
│               ├── parsed/<MODULO>_*.txt      # 12 relatorios (forms-extractor)
│               └── reversa-<MODULO>.md
└── features/[feature]/
    ├── spec.md            # WHAT - sempre
    ├── context.md         # Decisoes de gray areas - quando Discuss e disparado
    ├── design.md          # HOW - para Grande/Complexo
    └── tasks.md           # Decomposicao - SEMPRE (sync 1:1 com Tasks ADO)
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

1. **Engenharia reversa do baseline** - se a rotina nao tem RE cacheada em
   `.specs/reverse-engineering/plsql/<NOME>/rev-NNN-<TAG>/` ou a tag esta stale, dispare o prompt
   [`baseline-reverse-engineering`](prompts/baseline-reverse-engineering.prompt.md) que invoca
   a skill [`engenharia-reversa-sigo`](skills/engenharia-reversa-sigo/SKILL.md). Ver
   [ADR-011](adr/011-engenharia-reversa-como-baseline.md).
2. `Specify` com template `spec-improvement-tunning` referenciando
   `[REF: .specs/reverse-engineering/plsql/<NOME>/rev-NNN-<TAG>/]` como baseline
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
| **Criar Tasks ADO automaticamente a partir de `tasks.md`** | **Sim - obrigatorio** ([REF: ADR-010](adr/010-tasks-obrigatorias-com-sync-ado.md)), via prompt `tasks-from-design` |
| Anexar spec/design/tasks como snapshot ao work item | Sim - acionado pelo TL via prompt file |
| Ler PRs, commits, builds | Sim |
| Acessar wiki Arquitetura-Referencia | Sim |
| **MCP Oracle - dicionario read-only** (`dba_*`, `dba_source`) | Sim - autorizado apenas para skills `engenharia-reversa-sigo` e `plsql-oracle-expert` ([REF: ADR-007](adr/007-guardrail-acesso-producao.md) emendada por [ADR-011](adr/011-engenharia-reversa-como-baseline.md)) |
| **MCP Oracle - dados de negocio / DML / DDL** | **PROIBIDO** - sempre WinCVS tag PRODUCAO |

Configuracao em [`references/mcp-integration.md`](references/mcp-integration.md).

## Comandos de gatilho

### Project-level

| Frase / Comando | Referencia |
|---|---|
| Initialize project, setup project | [`references/project-init.md`](references/project-init.md) |
| Create roadmap, plan features | [`references/roadmap.md`](references/roadmap.md) |
| Map codebase, analyze existing code | [`references/brownfield-mapping.md`](references/brownfield-mapping.md) |
| Reverse-engineer rotina PL/SQL, baseline RE, refresh RE | [`references/reverse-engineering.md`](references/reverse-engineering.md) / [`prompts/baseline-reverse-engineering.prompt.md`](prompts/baseline-reverse-engineering.prompt.md) |
| Reverse-engineer modulo Oracle Forms (.fmb) | [`prompts/baseline-reverse-engineering-forms.prompt.md`](prompts/baseline-reverse-engineering-forms.prompt.md) (skill `engenharia-reversa-forms` + tool `forms-extractor`) |
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
- `[GUARDRAIL]` Toda mudanca no Hapvida exige Task no Azure DevOps. `tasks.md` -> Tasks ADO sincronizadas 1:1 ([REF: ADR-010](adr/010-tasks-obrigatorias-com-sync-ado.md))
- Encoding UTF-8 sem BOM em todo arquivo gerado
- Para tarefas leves (validacao, handoff), comente uma vez que modelos mais rapidos cumprem bem - registre em STATE.md `Preferences` para nao repetir
- Para tarefas pesadas (brownfield, refatoracao PL/SQL complexa), use Claude Opus

## Code Analysis

Use ferramentas locais com graceful degradation: `ast-grep` > `ripgrep` > `grep`.
Ver [`references/code-analysis.md`](references/code-analysis.md). NUNCA acessar banco produtivo.

## Skill Integrations

O framework agora **carrega skills internas** da pasta [`skills/`](skills/):

- **[`engenharia-reversa-sigo`](skills/engenharia-reversa-sigo/SKILL.md)** - engenharia reversa
  forense de PL/SQL com persistencia em `.specs/reverse-engineering/` (ver ADR-011)
- **[`plsql-oracle-expert`](skills/plsql-oracle-expert/SKILL.md)** - code review PL/SQL com
  regras ANS aplicadas
- **[`engenharia-reversa-forms`](skills/engenharia-reversa-forms/SKILL.md)** - engenharia
  reversa forense de modulos Oracle Forms (.fmb -> XML), produzindo artefato em
  `.specs/reverse-engineering/forms/<MODULO>/rev-NNN-<TAG>/` **(experimental v0.1)**

Skills externas SIGO continuam compativeis quando disponiveis no ambiente do dev:

- `sigo-refatoracao-workflow` - fluxo completo de refatoracao

Todas as skills respeitam os guardrails Hapvida (ADR-007 emendada por ADR-011).

## Tools executaveis

A pasta [`tools/`](tools/) hospeda utilitarios disparados por skills durante sua execucao -
parsing de formatos densos, extracao estruturada, normalizacao. Diferente de `scripts/`
(executados pelo TL no terminal), os tools sao invocados pela LLM durante o protocolo de uma
skill. Ver [`tools/README.md`](tools/README.md) para a convencao.

Tools registrados:

- [`tools/forms-extractor/`](tools/forms-extractor/) - pipeline `.fmb` -> `.xml` -> 12 relatorios
  estruturados; consumido pela skill `engenharia-reversa-forms` (experimental v0.1)
