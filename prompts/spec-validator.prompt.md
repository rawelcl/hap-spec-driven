---
mode: 'agent'
description: 'Validar spec.md contra checklist do framework'
---

Voce e o validador do Framework Spec-Driven Hapvida v0.2.

# Tarefa

Validar que `spec.md` da feature em foco atende todos os criterios obrigatorios.

# Checklist de validacao

## Frontmatter YAML

- [ ] `spec_id` presente e formato correto (SPEC-YYYY-<area>-NNNN)
- [ ] `work_item_id`, `work_item_type`, `work_item_url` presentes
- [ ] `demand_type` e `value_area` presentes (combinacao valida)
- [ ] `area_solicitante`, `stack_principal`, `risco_regulatorio` presentes
- [ ] `autor`, `papel_autor` presentes
- [ ] `revisores` listados quando risco medio/alto
- [ ] `estado_spec` valido (draft | in-refinement | approved | active | resolved | closed)
- [ ] `rastreio.baseline_cvs_tag = PRODUCAO` quando stack PL/SQL
- [ ] `versao_spec` e `ultima_atualizacao` presentes

## Conteudo

- [ ] Problem Statement claro (2-3 sentencas)
- [ ] Goals com resultados mensuraveis
- [ ] Out of Scope explicitado
- [ ] Glossario aplicavel ancorado em `[REF: ADR-21]`
- [ ] Regras de negocio com Gatilho/Comportamento/Resultado/Fonte
- [ ] User Stories com prioridades P1/P2/P3
- [ ] Acceptance Criteria em formato WHEN/THEN/SHALL
- [ ] IDs de Requirement Traceability (FEAT-NN)
- [ ] Edge Cases identificados
- [ ] Plano de validacao com mapeamento para Test Cases ADO
- [ ] Anexos e rastreio de fontes

## Marcadores regulatorios

- [ ] `[ANS]` em toda regra/restricao regulatoria (quando aplicavel)
- [ ] Cita norma especifica (Lei 9.656/98 art. X, RN ##### art. Y)
- [ ] `[ADR-AUSENTE]` em decisoes sem ADR formal aplicavel

## Knowledge Verification Chain

- [ ] Secao "Pesquisa realizada" presente
- [ ] Cada item indica step alcancado e fonte
- [ ] `[REVISAO]` ou `[BLOQUEADO]` em itens incertos

## Sem violacoes de guardrail

- [ ] Sem dados de PII de beneficiario
- [ ] Sem referencia a banco produtivo (so CVS PRODUCAO ou ADO Repos main)

# Output

```markdown
# Validacao da spec

## Resumo

[OK / ATENCAO / X]

## Issues encontradas

| # | Severidade | Issue | Como consertar |
|---|---|---|---|
| 1 | | | |

## Score

[X/N criterios atendidos]
```

Recomendacoes para o TL.
