# Specify

**Goal:** Capturar O QUE construir com requisitos testaveis e rastreaveis.

Se a feature tem **gray areas** (multiplos caminhos validos para comportamento user-facing), o agente
disparara automaticamente o processo [Discuss](discuss.md) dentro desta fase. Para features claras e
bem-definidas, segue direto para a proxima fase.

## Adaptacoes Hapvida em relacao ao TLC original

| Item | TLC | Hapvida |
|---|---|---|
| Local da spec | `.specs/[feature]/spec.md` | Idem (versionada em ADO Repos Git) |
| Snapshot ao work item | Nao se aplica | `[ADAPTACAO]` Snapshot anexado ao work item via MCP no estado `Approved` |
| Frontmatter | Simples | `[ADAPTACAO]` Carrega `work_item_id`, `demand_type`, `value_area`, `area_solicitante`, rastreio Lecom/ServiceNow/GMUD |
| Linguagem | Inglesa nos templates | `[ADAPTACAO]` Portugues |
| Marcadores | TLC tem `[CRITICAL]`, `[INFO]` em alguns lugares | `[ADAPTACAO]` Tokens textuais Hapvida (`[ANS]`, `[MIGRACAO]`, `[ADR-AUSENTE]`, etc) |
| Glossario / Linguagem ubiqua | Implicito | `[ADAPTACAO]` Secao explicita ancorada na ADR 21 (Linguagem Onipresente) da wiki |
| Restricoes regulatorias | Nao tem | `[ADAPTACAO]` Secao explicita com `[ANS]` + Lei 9.656/98 + RNs aplicaveis |
| Anexos / rastreio de fontes | Nao tem | `[ADAPTACAO]` Secao com Lecom, ServiceNow (INC), GMUD (CHG), baseline CVS, PRD, ata Teams |

## Process

### 1. Clarificar Requisitos

Voce e parceiro de pensamento, nao entrevistador. Comece aberto - deixe o usuario despejar o
modelo mental dele. Siga a energia: o que ele enfatiza, va fundo.

Pergunte conversacionalmente (nao como checklist):

- "Qual problema voce esta resolvendo?"
- "Quem e o usuario e qual a dor dele?"
- "Como e o sucesso?"

Quando precisar:

- "Quais sao as restricoes (tempo, tecnico, recursos)?"
- "O que esta explicitamente fora de escopo?"

**Desafie vagueza.** Nunca aceite respostas difusas. "Bom" significa o que? "Usuarios" significa quem?
"Simples" significa como? Concretize: "Me conta como voce usaria isso." "Como e na pratica?"

**Saiba quando parar.** Quando voce entende o que esta sendo construido, por que, para quem e como
e o "feito" - oferece prosseguir.

### 2. Capturar User Stories com Prioridades

**P1 = MVP** (deve ir para producao), **P2** (deveria ter), **P3** (seria bom ter)

Cada story DEVE ser **independentemente testavel** - voce consegue implementar e demonstrar so essa
story.

### 3. Escrever Acceptance Criteria

Use formato **WHEN/THEN/SHALL** - e preciso e testavel:

- WHEN [evento/acao] THEN [sistema] SHALL [resposta/comportamento]

Cada criterio sincroniza com o campo nativo `Acceptance Criteria` do work item ADO e mapeia 1:n para
Test Cases ADO.

### 4. Identificar Demand Type x Value Area

A combinacao desses campos do work item determina o template aplicavel:

| Demand Type | Value Area | Template |
|---|---|---|
| Project | Business | [`spec-project-business.md`](../templates/spec-project-business.md) |
| Improvement | Business | [`spec-improvement-business.md`](../templates/spec-improvement-business.md) |
| **Improvement** | **Tunning** | [`spec-improvement-tunning.md`](../templates/spec-improvement-tunning.md) **(refatoracao PL/SQL)** |
| Maintenance | Business | [`spec-maintenance-business.md`](../templates/spec-maintenance-business.md) |
| Maintenance | Tunning | [`spec-maintenance-tunning.md`](../templates/spec-maintenance-tunning.md) |
| Incident criticidade alta/media | (qualquer) | [`spec-incident-fast-track.md`](../templates/spec-incident-fast-track.md) |

### 5. Identificar Risco Regulatorio

| Risco | Criterio | Revisao exigida |
|---|---|---|
| Alto | `[ANS]` em qualquer secao + Demand Type Project | TL + Arquiteto + Compliance/Juridico/Atuarial |
| Medio | Project sem `[ANS]`, OU Improvement com `[ANS]` | TL + Arquiteto |
| Baixo | Maintenance sem `[ANS]`, Improvement sem `[ANS]` | TL |

### 6. Garantir Knowledge Verification Chain

Antes de afirmar qualquer coisa tecnica ou de dominio, percorra a cadeia (ver [`knowledge-verification.md`](knowledge-verification.md)):

```
Codebase (CVS PRODUCAO ou ADO Repos main) ->
  Project docs (.specs/, wiki Arquitetura-Referencia) ->
    Context7 MCP ->
      Web search ->
        Flag uncertain ([REVISAO] / [BLOQUEADO])
```

**Nunca invente.** Se nao encontrar, marque incerteza explicitamente.

---

## Estrutura da spec.md (template generico)

```markdown
---
spec_id: SPEC-2026-COM-0001
titulo: <titulo curto e claro>
work_item_id: 12345
work_item_type: Feature
work_item_url: https://dev.azure.com/<org>/<project>/_workitems/edit/12345

demand_type: Improvement              # Project | Improvement | Maintenance
value_area: Tunning                   # Business | Tunning
demand_category: <quando aplicavel>

area_solicitante: Comercial
stack_principal: PL/SQL                # PL/SQL | dotnet | java | mista
risco_regulatorio: medio               # alto | medio | baixo

autor: <nome>
papel_autor: tech-lead
revisores:
  - papel: arquiteto
    nome: <nome>
    decisao_em: <data ISO>
  - papel: compliance
    nome: <nome>
    decisao_em: <data ISO>

estado_spec: in-refinement             # draft | in-refinement | approved | active | resolved | closed

datas:
  criacao: 2026-05-06
  refinement_iniciado: 2026-05-06
  approved: <a preencher>

rastreio:
  servicenow_inc: <numero quando aplicavel>
  lecom_id: <numero quando aplicavel>
  gmud_chg: <numero quando definida>
  baseline_cvs_tag: PRODUCAO
  baseline_arquivos:
    - schema.package_x
    - schema.procedure_y
  prd_path: <quando aplicavel>
  ata_teams_path: <quando aplicavel - sempre [REVISAO]>

adrs_referenciadas:
  - ADR-21
  - ADR-74

normas_ans_aplicaveis:
  - Lei-9656-98
  - RN-309-2012

glossario_termos:
  - beneficiario
  - vigencia

versao_spec: 0.1
ultima_atualizacao: 2026-05-06
---

# [Nome da Feature] - Especificacao

## 1. Problem Statement

[2-3 sentencas. Qual a dor? Por que agora?]

## 2. Goals

- [ ] [Goal primario com resultado mensuravel]
- [ ] [Goal secundario com resultado mensuravel]

## 3. Out of Scope

| Feature | Motivo |
|---|---|
| [Feature X] | [Por que excluida] |

## 4. Glossario aplicavel

Termos canonicos do dominio (ancorados em ADR 21 - Linguagem Onipresente):

- **Beneficiario**: [definicao canonica]
- **Vigencia**: [definicao canonica]

Mapeamento de sinonimos legados (PL/SQL):

- `BNF` em `tb_beneficiario` -> Beneficiario
- `DT_VIG` -> Vigencia

## 5. Regras de negocio

Para cada regra:

### RN-01: [Nome curto]

- **Gatilho:** [evento que dispara]
- **Comportamento:** [o que acontece]
- **Resultado:** [estado final / saida]
- **Fonte:** [REF: codigo ADRs ANS] - origem da regra
- **Marcador:** `[ANS]` se regulatoria

## 6. Requisitos funcionais

[Lista de capacidades funcionais]

## 7. Requisitos nao-funcionais

| Categoria | Requisito |
|---|---|
| Performance | [ex: p95 < 500ms] |
| Disponibilidade | [ex: 99.5%] |
| Seguranca | [ex: autenticacao Entra ID] |
| LGPD | [ex: anonimizacao em logs] |
| Observabilidade | [ex: metricas custom] |

## 8. Restricoes regulatorias [ANS]

[Liste normas aplicaveis com citacao]

- `[ANS]` Lei 9.656/98 - art. X - [aplicacao]
- `[ANS]` RN 309/2012 - art. Y - [aplicacao]

## 9. User Stories

### P1: [Story Title] - MVP

**User Story:** Como [role], quero [capacidade] para [beneficio].

**Why P1:** [Por que critico para MVP]

**Acceptance Criteria:**

| ID | Criterio |
|---|---|
| FEAT-01 | WHEN [evento] THEN sistema SHALL [comportamento] |
| FEAT-02 | WHEN [evento] THEN sistema SHALL [comportamento] |
| FEAT-03 | WHEN [edge case] THEN sistema SHALL [tratamento gracioso] |

**Independent Test:** [Como verificar essa story sozinha]

### P2: [Story Title]

[mesma estrutura]

### P3: [Story Title]

[mesma estrutura]

## 10. Edge Cases

| ID | Cenario | Comportamento esperado |
|---|---|---|
| EC-01 | [boundary condition] | [tratamento] |
| EC-02 | [erro] | [tratamento gracioso] |

## 11. Riscos, premissas e dependencias

**Riscos:**

- [Risco 1 com impacto e mitigacao]

**Premissas:**

- [PREMISSA] [Premissa assumida sujeita a contestacao]

**Dependencias:**

- [Sistema/feature/equipe externa]

**Stakeholders impactados (Personas affected):**

- [Persona 1 + tipo de impacto]

## 12. Plano de implementacao (high-level)

[Resumo de abordagem - detalhe vai para design.md quando necessario]

## 13. Plano de validacao

Cobertura de cada criterio por `Tests Artifact` co-localizado em
`.specs/features/[feature]/tests/` ([REF: ADR-013](../adr/013-modelo-testes-co-localizado-por-task.md)).

| Criterio | Tests Approach | Tests Artifact (em `tests/`) | Tasks (T<n>) | Massa de teste |
|---|---|---|---|---|
| FEAT-01 | automated\|manual\|hybrid\|none | `<artifact>` | T<n> | [descricao] |
| FEAT-02 | | | | [descricao] |

**Approaches em uso nesta feature:**

- [ ] `automated` (script executavel: PL/SQL via MCP, JUnit, xUnit, Vitest, etc.)
- [ ] `manual` (procedimento `.md` com passos numerados)
- [ ] `hybrid` (combinacao)
- [ ] `none` (raro - apenas refactor/doc sem mudanca de comportamento)

**Nota:** QA manual end-to-end (homologacao por testador humano) NAO entra em tasks.md - fluxo
proprio do QA, conforme [ADR-010 item 7](../adr/010-tasks-obrigatorias-com-sync-ado.md). QA
reaproveita os artifacts declarados acima.

## 14. Anexos e rastreio de fontes

| Fonte | Identificador / Link |
|---|---|
| Work item ADO | WI-12345 |
| ServiceNow INC | INC-##### (se Incident) |
| Lecom ID | ##### (se Feature com BPM) |
| GMUD CHG | CHG-##### (quando definida) |
| Baseline CVS tag | PRODUCAO |
| Baseline arquivos | [lista] |
| PRD | [path] |
| Ata Teams | [path] - `[REVISAO]` (atas nunca sao fonte primaria) |
| ADRs referenciadas | ADR-21, ADR-74 |

## 15. Requirement Traceability

| ID | Story | Fase | Status |
|---|---|---|---|
| FEAT-01 | P1: [Story] | Design | Pending |
| FEAT-02 | P1: [Story] | Design | Pending |
| FEAT-03 | P2: [Story] | - | Pending |

**Status:** Pending → In Design → In Tasks → Implementing → Verified

**Coverage:** X total, Y mapeados a tasks, Z nao mapeados (`[ATENCAO]` se algum)

## 16. Success Criteria

Como saberemos que a feature foi bem-sucedida:

- [ ] [Resultado mensuravel - ex: usuario completa X em < 2 minutos]
- [ ] [Resultado mensuravel]

## 17. Estado e historico

| Versao | Data | Autor | Mudanca |
|---|---|---|---|
| 0.1 | YYYY-MM-DD | <nome> | Versao inicial |
```

---

## Tips

- **P1 = Vertical Slice** - feature completa demonstravel, nao so backend ou so frontend
- **WHEN/THEN e codigo** - se voce nao consegue escrever como teste, reescreva
- **IDs de traceability sao obrigatorios** - cada story mapeia para IDs rastreaveis
- **Edge cases importam** - o que quebra? O que e vazio? O que e enorme?
- **Out of Scope previne creep** - se nao esta aqui, nao vai ser construido
- **Confirmar antes de Discuss** - usuario aprova spec antes de seguir para discuss/design

---

## Adaptacoes especificas para Hapvida

- Frontmatter YAML carrega rastreio para Lecom, ServiceNow, GMUD - imprescindivel para auditoria
- Marcador `[ANS]` obrigatorio em qualquer toque regulatorio com citacao de norma
- Glossario aplicavel referenciado da ADR 21 - linguagem ubiqua nao e opcional
- Mapeamento de sinonimos legados PL/SQL e parte da spec quando o codigo legado e tocado
- Spec atinge `Approved` quando: TL + revisores aprovam + DoR atendido + (revisao Compliance se risco alto)
- Quando atinge `Approved`: snapshot anexado ao work item via prompt file `spec-publish-snapshot`
