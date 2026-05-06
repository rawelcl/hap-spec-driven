---
spec_id: SPEC-YYYY-<area>-NNNN
titulo: <titulo curto>
work_item_id: <id>
work_item_type: Defect ou User Story
work_item_url: https://dev.azure.com/<org>/<project>/_workitems/edit/<id>

demand_type: Maintenance
value_area: Business

area_solicitante: <area>
stack_principal: <stack>
risco_regulatorio: <alto | medio | baixo>

autor: <nome>
papel_autor: tech-lead

estado_spec: in-refinement
datas:
  criacao: YYYY-MM-DD

rastreio:
  servicenow_inc: <numero>
  baseline_cvs_tag: PRODUCAO
  baseline_arquivos: []

adrs_referenciadas: []
normas_ans_aplicaveis: []
glossario_termos: []

versao_spec: 0.1
ultima_atualizacao: YYYY-MM-DD
---

# [Nome] - Especificacao (Maintenance+Business)

> **Template:** Maintenance + Business - correcao funcional, ajuste pequeno em regra de negocio,
> bug de comportamento. Defects, User Stories standalone de manutencao.

## 1. Problem Statement

[Descricao do bug ou ajuste necessario]

## 2. Comportamento atual (incorreto)

[O que acontece hoje]

## 3. Comportamento esperado

[O que deveria acontecer]

## 4. Causa raiz (root cause)

[Analise da origem do problema - exigida quando work item exige Required-Root Cause]

## 5. Acceptance Criteria

| ID | Criterio |
|---|---|
| FEAT-01 | WHEN [cenario] THEN sistema SHALL [comportamento correto] |

## 6. Riscos

- Regressao em fluxos relacionados - mitigacao: testes de fluxo completo

## 7. Plano de validacao

| Criterio | Test Case ADO |
|---|---|
| FEAT-01 | TC-#### |

## 8. Anexos e rastreio

[Igual ao template generico]

## 9. Estado e historico

[Igual ao template generico]
