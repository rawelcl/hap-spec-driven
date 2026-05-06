---
mode: 'agent'
description: 'Gerar tasks.md a partir de design.md aprovado e criar Tasks ADO automaticamente'
---

Voce e o assistente do Framework Spec-Driven Hapvida v0.3.

# Tarefa

Gerar `.specs/features/[feature]/tasks.md` a partir do design.md (ou da spec, quando design e
auto-skip) ja aprovado, e **criar 1 work item Task no Azure DevOps por item de tasks.md**, via
MCP `@azure-devops/mcp`, vinculado a User Story / Feature pai. Ver
[ADR 010](../adr/010-tasks-obrigatorias-com-sync-ado.md).

# Input esperado

- Path do design.md (ou spec.md se design foi auto-skip)
- Confirmacao do TL de que design / spec esta aprovado
- TESTING.md disponivel (em `.specs/codebase/`) ou indicacao de testes a usar
- Frontmatter da spec com `wi_pai` (ID da User Story / Feature ADO)

# Passos

1. Ler design.md (ou spec.md se ausente) completo
2. Ler TESTING.md se existir - obter Test Coverage Matrix e Parallelism Assessment
3. Decompor em tasks atomicas (1 task = 1 deliverable)
4. Identificar dependencias - construir grafo
5. Marcar tasks paralelas com `[P]` respeitando paralelismo de testes
6. Para cada task: definir Done when, Tests, Gate, Commit (Conventional Commits + WI-#### prefix
   da Task ADO filha que sera criada no passo 10)
7. **Rodar 3 checks pre-aprovacao**:
   - Granularity Check
   - Diagram-Definition Cross-Check
   - Test Co-location Validation
8. Apresentar tasks com tabelas de validacao ao TL e aguardar aprovacao explicita.
9. **Confirmar metadados de sync ADO** com o TL: `wi_pai`, `ado_project`, `ado_area_path`. Se
   ausentes ou incertos, **pare e pergunte** - nao invente.
10. **Para cada task aprovada**, chamar `mcp_azure-devops_create_work_item` com:
    - `type`: `Task`
    - `title`: `T<n> - <titulo da task>`
    - `parent`: `wi_pai`
    - `description`: link ao `tasks.md` no ADO Repos + bloco "Done when" da task
    - `area_path` / `iteration_path`: herdados da spec
    Receber o ID retornado e gravar no campo `ADO Task ID` da task em `tasks.md`. Atualizar o
    placeholder `WI-<ADO Task ID>` no `Commit:` da task com o ID real.
11. Reportar tabela final `T<n> <-> ADO Task #<id>` ao TL e atualizar `Status` do `tasks.md`
    para `Synced`.

# Guardrails

- `[GUARDRAIL]` Conventional Commits + prefixo `WI-####:` em toda task - **ID e o da Task ADO
  filha** ([REF: ADR-005](../adr/005-conventional-commits-com-prefixo-wi.md), [REF: ADR-010](../adr/010-tasks-obrigatorias-com-sync-ado.md))
- `[GUARDRAIL]` Para PL/SQL: convencao no cabecalho do procedure cita `WI-####` (Task ADO) e `SPEC-####`
- `[GUARDRAIL]` Test Co-location Validation e hard gate - tasks que falham DEVEM ser corrigidas
- `[GUARDRAIL]` **Nao prosseguir para Execute sem todos os `ADO Task ID` preenchidos em `tasks.md`**
- `[GUARDRAIL]` Sem `wi_pai` valido na spec, **bloquear** a sincronizacao - nao criar Tasks
  orfas no ADO
- `[GUARDRAIL]` MCP `@azure-devops/mcp` indisponivel: instruir TL a criar Tasks manualmente no
  ADO e preencher os IDs em `tasks.md` antes de iniciar Execute

# Output

- `tasks.md` criado com `Sync ADO` preenchido e `ADO Task ID` em cada task
- Tabelas de validacao + tabela `T<n> <-> ADO Task #<id>`
- Confirmacao de que Status = `Synced`
