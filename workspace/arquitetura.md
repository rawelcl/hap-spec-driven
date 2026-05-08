# Arquitetura do Framework — Visao para o Dev

Resumo da arquitetura logica do framework. Documento completo em [ARCHITECTURE.md](../ARCHITECTURE.md).

---

## Visao em camadas

```
L0 - GUARDRAILS (cross-cutting)
     [GUARDRAIL] Banco produtivo proibido
     [ANS] / LGPD / sigilo medico
     [ADR-AUSENTE] bloqueia avanco
     Anonimizacao PII obrigatoria

L1 - PROCESSO (Agile Hapvida 2.0 - inalterado)
     Work Items ADO (Epic / Feature / US / Task)
     Estados: In Refinement -> Approved -> Resolved -> Homologation -> Closed

L2 - FRAMEWORK (este repositorio)
     SKILL.md            <- ponto de entrada do agente
     4 fases adaptativas <- Specify / Design / Tasks / Execute
     Templates / Refs / Prompts / ADRs / Glossario / Skills

L3 - ARTEFATOS DO SQUAD (em .specs/ no repo do squad)
     project/            <- PROJECT.md, ROADMAP.md, STATE.md
     codebase/           <- mapeamento brownfield
     features/<f>/       <- spec.md, context.md, design.md, tasks.md
     reverse-engineering/<obj>/ <- RE com estrutura versionada

L4 - AGENTE IA
     GitHub Copilot (Claude Sonnet / Opus)
     Skills internas: engenharia-reversa-sigo, plsql-oracle-expert, engenharia-reversa-forms
     Tools executaveis em tools/ (parsers, extracoes)

L5 - INTEGRACOES (MCP)
     MCP Azure DevOps  <- snapshot ao WI, leitura de metadados
     Context7 MCP      <- docs de libs e frameworks

L6 - SISTEMAS HAPVIDA (sources of truth)
     ADO Repos         <- codigo Java/.NET + .specs
     Wiki Hapvida      <- 96+ ADRs corporativas (RAG primario)
     WinCVS            <- codigo PL/SQL e Oracle Forms (TAG PRODUCAO)
     ADO Work Items    <- rastreabilidade e test cases
```

---

## Como o agente navega

1. Usuario abre GitHub Copilot Chat em modo Agent com `@workspace`
2. Agente le `SKILL.md` (ponto de entrada) — nele estao as instrucoes de comportamento
3. Usuario aciona comando `/hap-sd-*` — cada prompt file carrega instrucoes especificas
4. Agente segue a **Knowledge Verification Chain** (ADR-006):
   - Codebase -> Project docs -> Context7 -> Web -> Flag

---

## Integracao com Azure DevOps (MCP)

```
Usuario aciona /hap-sd-snapshot
  -> Agente le spec.md local
  -> MCP Azure DevOps anexa snapshot ao WI
  -> WI muda estado para Approved (manual ou via MCP)
```

Acoes autorizadas via MCP ADO:
- Leitura de work items, repos, pipelines, wiki
- Criacao de comentarios, links, anexos
- Leitura de dicionario Oracle (`dba_*` read-only, sem `dba_source`)

---

## Integracao com WinCVS (sem MCP — manual)

```
Dev executa no WinCVS:
  cvs log <arquivo>.pls    <- verifica ultima tag de producao
  cvs checkout -r PRODUCAO <package>.pls   <- baixa baseline

Agente recebe o conteudo via paste ou arquivo local
Agente executa /hap-sd-re-plsql sobre o conteudo
```

`[GUARDRAIL]` Nenhuma outra fonte substitui a TAG PRODUCAO do WinCVS como baseline de RE.

---

## ADRs do framework (decisoes registradas)

| ADR | Decisao |
|---|---|
| ADR-001 | Framework spec-driven como camada sobre Agile Hapvida 2.0 |
| ADR-002 | Spec versionada em Git, snapshot no work item |
| ADR-003 | MCP Azure DevOps para snapshot automatizado |
| ADR-004 | Camada fina — processo Agile Hapvida 2.0 inalterado |
| ADR-005 | Conventional Commits com prefixo WI-#### |
| ADR-006 | Knowledge Verification Chain (5 passos) |
| ADR-007 | Guardrail acesso producao (banco proibido, MCP autorizado so dicionario) |
| ADR-008 | Quick Mode fora do escopo do piloto |
| ADR-009 | STATE.md obrigatorio em projetos individuais |
| ADR-010 | Tasks obrigatorias com sync ADO |
| ADR-011 | Engenharia reversa com TAG PRODUCAO WinCVS como baseline |
| ADR-012 | Framework como git submodule no repo do squad |

---

## Skills especializadas

| Skill | Arquivo | Finalidade |
|---|---|---|
| `engenharia-reversa-sigo` | `skills/engenharia-reversa-sigo/SKILL.md` | RE de PL/SQL (procedures, functions, packages) |
| `plsql-oracle-expert` | `skills/plsql-oracle-expert/SKILL.md` | Code review PL/SQL com regras ANS |
| `engenharia-reversa-forms` | `skills/engenharia-reversa-forms/SKILL.md` | RE de Oracle Forms (.fmb) |

---

## Como o framework e adotado pelo squad (ADR-012)

```powershell
# No repo do squad, adicionar o framework como submodule
git submodule add https://github.com/rawelcl/hap-spec-driven.git .specs/framework

# Para atualizar quando o framework evoluir
git submodule update --remote .specs/framework
# ou usar o script do framework:
.specs/framework/scripts/update-framework.ps1
```

O framework fica em `.specs/framework/` no repo do squad.
O VS Code Chat lo carrega automaticamente via `@workspace`.
