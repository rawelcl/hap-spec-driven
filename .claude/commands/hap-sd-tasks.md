---
mode: 'agent'
description: 'Gerar tasks.md a partir de design.md aprovado e criar Tasks ADO automaticamente'
---

> **[HAP-SDD]** Hapvida Desenvolvimento Spec-Driven · [`SKILL.md`](../SKILL.md)

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
2. Ler TESTING.md se existir - obter Test Coverage Matrix hibrida (Approach por camada) e Parallelism Assessment
3. Decompor em tasks atomicas (1 task = 1 deliverable) - **excluir itens de GMUD, deploy e QA manual** (ver Guardrails)
4. Identificar dependencias - construir grafo
5. Marcar tasks paralelas com `[P]` respeitando paralelismo de testes
6. Para cada task: definir Done when, **Tests Approach** (automated|manual|hybrid|none),
   **Tests Artifact** (path em `.specs/features/[feature]/tests/` ou `N/A` se none),
   **Evidence** (comando/screenshot/query/justificativa), Gate, Commit (Conventional Commits +
   WI-#### prefix da Task ADO filha que sera criada no passo 10).
   Ver [ADR-013](../adr/013-modelo-testes-co-localizado-por-task.md).
7. **Rodar 4 checks pre-aprovacao** (hard gates - se algum falha, reestruture):
   - Granularity Check
   - Diagram-Definition Cross-Check
   - Test Co-location Validation (valida Tests Approach/Artifact/Evidence contra TESTING.md)
   - AC Coverage Check (toda FEAT-NN da spec §9 tem >=1 task com Requirement: FEAT-NN)
8. Apresentar tasks com **as quatro** tabelas de validacao ao TL e aguardar aprovacao explicita.
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
- `[GUARDRAIL]` AC Coverage Check e hard gate ([REF: ADR-013](../adr/013-modelo-testes-co-localizado-por-task.md))
  - toda `FEAT-NN` declarada em `spec.md §9` DEVE ter pelo menos uma task em `tasks.md` com
  `Requirement: FEAT-NN`. FEAT orfa = bloqueio hard.
- `[GUARDRAIL]` **Nao prosseguir para Execute sem todos os `ADO Task ID` preenchidos em `tasks.md`**
- `[GUARDRAIL]` Sem `wi_pai` valido na spec, **bloquear** a sincronizacao - nao criar Tasks
  orfas no ADO
- `[GUARDRAIL]` MCP `@azure-devops/mcp` indisponivel: instruir TL a criar Tasks manualmente no
  ADO e preencher os IDs em `tasks.md` antes de iniciar Execute
- `[GUARDRAIL]` **Fora de escopo:** tasks de **GMUD** (RFC, aprovacao CAB, agendamento de janela,
  comunicacao de stakeholders, evidencias de mudanca), **deploy** (build de release, promocao
  entre ambientes DEV/HML/PRD, execucao em PRD, rollback, smoke test pos-deploy) e **QA manual
  end-to-end** (execucao de homologacao por testador humano, abertura de Task ADO type=Testing
  pelo proprio QA) **NAO entram em `tasks.md`** - sao responsabilidade do TL/sustentacao/QA fora
  do fluxo spec-driven. Nao listar, nao decompor, nao sincronizar com ADO. Se o design.md mencionar
  esses passos, ignorar na decomposicao. O dev produz o **test artifact** em
  `.specs/features/[feature]/tests/` (campo `Tests Artifact` da task) — QA reaproveita esse
  artifact em seu fluxo proprio. Ver [ADR-013](../adr/013-modelo-testes-co-localizado-por-task.md).

# Output

- `tasks.md` criado com `Sync ADO` preenchido e `ADO Task ID` em cada task
- Tabelas de validacao + tabela `T<n> <-> ADO Task #<id>`
- Confirmacao de que Status = `Synced`
