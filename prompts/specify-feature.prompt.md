---
mode: 'agent'
description: 'Especificar uma feature - criar spec.md com requisitos testaveis e rastreaveis'
---

> **[HAP-SDD]** Hapvida Desenvolvimento Spec-Driven · [`SKILL.md`](../SKILL.md)

# Tarefa

Criar `.specs/features/[feature]/spec.md` especificando O QUE construir, com requisitos
testaveis e rastreaveis, seguindo o fluxo adaptativo (auto-sizing por complexidade).

# Input esperado

- **Descricao da feature** (o que o TL quer construir)
- **Work item ID** (se houver - alternativa: use `/spec-from-workitem`)
- **Demand Type x Value Area** (determina template): Project/Improvement/Maintenance x Business/Tunning
- **Criticidade** (para Incident/Defect)

# Passos

1. **Clarificar requisitos** - escuta ativa, perguntas abertas:
   - "Qual problema voce esta resolvendo?"
   - "Quem e o usuario e qual a dor dele?"
   - "Como e o sucesso?"
   - Desafie vagueza - nunca aceite respostas difusas.

2. **Detectar gray areas** - se comportamento user-facing pode ir de multiplas formas,
   dispare o processo Discuss (crie `context.md`) antes de prosseguir.

3. **Identificar template** pela matriz Demand Type x Value Area:
   - Project/Business → `spec-project-business.md`
   - Improvement/Business → `spec-improvement-business.md`
   - Improvement/Tunning → `spec-improvement-tunning.md` (refatoracao PL/SQL)
   - Maintenance/Business → `spec-maintenance-business.md`
   - Maintenance/Tunning → `spec-maintenance-tunning.md`
   - Incident alta/media → `spec-incident-fast-track.md`

4. **Criar `.specs/features/[feature]/spec.md`** com:
   - Frontmatter YAML: `work_item_id`, `demand_type`, `value_area`, `area_solicitante`,
     `status: Draft`, `spec_version: 0.1.0`
   - User Stories com prioridade P1/P2/P3
   - Acceptance Criteria no formato WHEN/THEN/SHALL
   - Restricoes regulatorias com `[ANS]` se aplicavel
   - `[REVISAO]` em secoes que exigem input adicional

5. **Checar risco regulatorio**:
   - Alto (`[ANS]` + Project): exige revisao TL + Arquiteto + Compliance
   - Medio (Project sem ANS, ou Improvement com ANS): exige TL + Arquiteto

6. **Confirmar com o TL** e orientar proximo passo: Design (se Grande/Complexo) ou Tasks direto.

# Guardrails

- `[GUARDRAIL]` Anonimizar PII de beneficiario pessoa fisica (CPF, nome, matricula, dados de saude)
- `[GUARDRAIL]` Marcar `[ANS]` em qualquer regra que toca regulacao ANS/Lei 9.656/98
- `[GUARDRAIL]` Decisao sem ADR corporativa → marcar `[ADR-AUSENTE]` e bloquear ate proposta de ADR
- `[GUARDRAIL]` Para refatoracao PL/SQL: exige baseline de RE em `.specs/reverse-engineering/`
  via WinCVS tag PRODUCAO antes de iniciar spec ([ADR-011](../adr/011-engenharia-reversa-como-baseline.md))

# Output

Arquivo `.specs/features/[feature]/spec.md` criado (e opcionalmente `context.md` se Discuss foi
disparado). Confirmacao ao TL com resumo das User Stories e proximos passos.
