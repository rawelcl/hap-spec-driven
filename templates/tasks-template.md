# [Feature] Tasks

**Design:** `.specs/features/[feature]/design.md` (quando aplicavel)
**Status:** Draft

**Sync ADO** ([REF: ADR-010](../../adr/010-tasks-obrigatorias-com-sync-ado.md)):

- `wi_pai`: <ID da User Story / Feature pai>
- `ado_project`: <projeto ADO>
- `ado_area_path`: <area path do squad>

---

## Plano de execucao

### Fase 1: Fundacao

```
T1 -> T2 -> T3
```

### Fase 2: Implementacao

```
       +-> T4 -+
T3 ----+-> T5 -+--> T8
       +-> T6 -+
```

### Fase 3: Integracao

```
T8 -> T9
```

---

## Detalhamento das tasks

### T1: [titulo]

**O que:** [deliverable]
**Onde:** `path` ou `schema.objeto`
**Depende de:**
**Reutiliza:**
**Requirement:** FEAT-01
**ADO Task ID:** <preenchido apos sync via MCP>

**Ferramentas:**
- MCP:
- Skill:

**Done when:**
- [ ]
- [ ] Tests Artifact criado/atualizado em `.specs/features/[feature]/tests/`
- [ ] Evidence registrada (ver campo abaixo)

**Tests Approach:** automated | manual | hybrid | none
**Tests Artifact:** `.specs/features/[feature]/tests/<arquivo>` (ou `N/A` se Approach=none)
**Evidence:** [comando + output esperado | screenshot path | query de validacao | justificativa se none]
**Gate:** quick | full | build
**Commit:** `WI-<ADO Task ID>: feat(<scope>): <description>`

---

[repetir]

---

## Validacao pre-aprovacao

[4 checks: Granularity, Diagram-Definition Cross-Check, Test Co-location, AC Coverage]

Ver [references/tasks.md](../../references/tasks.md) e
[ADR-013](../../adr/013-modelo-testes-co-localizado-por-task.md) para detalhamento.
