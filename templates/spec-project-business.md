---
spec_id: SPEC-YYYY-<area>-NNNN
titulo: <titulo curto e claro>
work_item_id: <id>
work_item_type: Feature
work_item_url: https://dev.azure.com/<org>/<project>/_workitems/edit/<id>

demand_type: Project
value_area: Business
demand_category: <quando aplicavel>

area_solicitante: <area>
stack_principal: <PL/SQL | dotnet | java | mista>
risco_regulatorio: <alto | medio | baixo>

autor: <nome>
papel_autor: tech-lead
revisores:
  - papel: arquiteto
    nome: <nome>
    decisao_em: <data ISO>
  - papel: compliance
    nome: <nome>
    decisao_em: <data ISO>

estado_spec: in-refinement
datas:
  criacao: YYYY-MM-DD
  refinement_iniciado: YYYY-MM-DD
  approved: <a preencher>

rastreio:
  servicenow_inc: <numero quando aplicavel>
  lecom_id: <numero - geralmente obrigatorio>
  gmud_chg: <numero quando definida>
  baseline_cvs_tag: PRODUCAO
  baseline_arquivos: []
  prd_path: <quando aplicavel>
  ata_teams_path: <quando aplicavel - sempre [REVISAO]>

adrs_referenciadas:
  - ADR-21
  - ADR-22

normas_ans_aplicaveis: []

glossario_termos: []

versao_spec: 0.1
ultima_atualizacao: YYYY-MM-DD
---

# [Nome da Feature] - Especificacao

> **Template:** Project + Business - feature nova com impacto de negocio significativo, geralmente
> liderada por area de negocio com PRD definido.

## 1. Problem Statement

[2-3 sentencas. Qual a dor de negocio? Por que agora?]

## 2. Goals

- [ ] [Goal primario com resultado mensuravel]
- [ ] [Goal secundario com resultado mensuravel]
- [ ] [Goal de usuario]

## 3. Out of Scope

| Feature | Motivo |
|---|---|
| [Feature X] | [Por que excluida deste escopo] |

## 4. Glossario aplicavel

Termos canonicos do dominio (ancorados em `[REF: ADR-21]` Linguagem Onipresente):

- **[Termo 1]**: [definicao canonica]
- **[Termo 2]**: [definicao canonica]

## 5. Regras de negocio

### RN-01: [Nome curto]

- **Gatilho:** [evento]
- **Comportamento:** [o que acontece]
- **Resultado:** [estado final]
- **Fonte:** [REF: ADR / norma / PRD secao X]
- **Marcador:** `[ANS]` se regulatoria

## 6. Requisitos funcionais

[Lista de capacidades]

## 7. Requisitos nao-funcionais

| Categoria | Requisito |
|---|---|
| Performance | |
| Disponibilidade | |
| Seguranca | |
| LGPD | |
| Observabilidade | |

## 8. Restricoes regulatorias [ANS]

[Liste normas aplicaveis com citacao - ou "Nao aplicavel" justificando]

## 9. User Stories

### P1: [Story Title] - MVP

**Como** [role], **quero** [capacidade] **para** [beneficio].

**Why P1:** [Por que critico]

**Acceptance Criteria:**

| ID | Criterio |
|---|---|
| FEAT-01 | WHEN [evento] THEN sistema SHALL [comportamento] |
| FEAT-02 | WHEN [evento] THEN sistema SHALL [comportamento] |

**Independent Test:** [Como verificar essa story sozinha]

### P2: [Story Title]

[mesma estrutura]

### P3: [Story Title]

[mesma estrutura]

## 10. Edge Cases

| ID | Cenario | Comportamento esperado |
|---|---|---|
| EC-01 | | |

## 11. Riscos, premissas e dependencias

**Riscos:**

- [Risco 1 com impacto e mitigacao]

**Premissas:**

- [PREMISSA] [hipotese assumida]

**Dependencias:**

- [Sistema/feature/equipe externa]

**Stakeholders impactados:**

- [Persona + tipo de impacto]

## 12. Plano de implementacao (high-level)

[Resumo de abordagem - detalhe vai para design.md]

## 13. Plano de validacao

Cobertura de cada criterio de aceitacao por `Tests Artifact` co-localizado em
`.specs/features/[feature]/tests/` ([REF: ADR-013](../adr/013-modelo-testes-co-localizado-por-task.md)).
Tasks que satisfazem cada FEAT sao listadas para rastreio forward AC -> task -> artifact.

| Criterio | Tests Approach esperado | Tests Artifact (em `tests/`) | Tasks (T<n>) | Massa de teste |
|---|---|---|---|---|
| FEAT-01 | automated\|manual\|hybrid\|none | `verifica_X.sql` ou `procedimento_X.md` ou `Test*.java` etc. | T1, T3 | |
| FEAT-02 | | | T2 | |

**Approaches em uso nesta feature:**

- [ ] `automated` (script executavel: PL/SQL via MCP, JUnit, xUnit, Vitest, etc. — declarado em TESTING.md por squad)
- [ ] `manual` (procedimento documentado em `.md` com passos numerados)
- [ ] `hybrid` (combinacao)
- [ ] `none` (raro - apenas refactor/doc sem mudanca de comportamento, justificar em Evidence da task)

**Nota:** QA manual end-to-end (homologacao por testador humano) NAO entra em tasks.md - fluxo
proprio do QA, conforme [ADR-010 item 7](../adr/010-tasks-obrigatorias-com-sync-ado.md) e
[ADR-013](../adr/013-modelo-testes-co-localizado-por-task.md). QA reaproveita os artifacts
declarados acima.

## 14. Anexos e rastreio de fontes

| Fonte | Identificador / Link |
|---|---|
| Work item ADO | WI-<id> |
| ServiceNow INC | |
| Lecom ID | |
| GMUD CHG | |
| Baseline CVS tag | PRODUCAO |
| PRD | |
| Ata Teams | [REVISAO] |
| ADRs referenciadas | ADR-21, ADR-22 |

## 15. Requirement Traceability

| ID | Story | Fase | Status |
|---|---|---|---|
| FEAT-01 | P1: [Story] | Design | Pending |
| FEAT-02 | P1: [Story] | Design | Pending |

## 16. Success Criteria

- [ ] [Resultado mensuravel]
- [ ] [Resultado mensuravel]

## 17. Estado e historico

| Versao | Data | Autor | Mudanca |
|---|---|---|---|
| 0.1 | YYYY-MM-DD | <nome> | Versao inicial |
