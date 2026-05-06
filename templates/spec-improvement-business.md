---
spec_id: SPEC-YYYY-<area>-NNNN
titulo: <titulo curto>
work_item_id: <id>
work_item_type: Feature
work_item_url: https://dev.azure.com/<org>/<project>/_workitems/edit/<id>

demand_type: Improvement
value_area: Business

area_solicitante: <area>
stack_principal: <stack>
risco_regulatorio: <alto | medio | baixo>

autor: <nome>
papel_autor: tech-lead
revisores: []

estado_spec: in-refinement
datas:
  criacao: YYYY-MM-DD

rastreio:
  servicenow_inc: <quando aplicavel>
  lecom_id: <numero>
  baseline_cvs_tag: PRODUCAO
  baseline_arquivos: []

adrs_referenciadas: []
normas_ans_aplicaveis: []
glossario_termos: []

versao_spec: 0.1
ultima_atualizacao: YYYY-MM-DD
---

# [Nome da Feature] - Especificacao (Improvement+Business)

> **Template:** Improvement + Business - melhoria sobre funcionalidade existente que entrega valor
> de negocio (UX, novo fluxo dentro de feature ja existente, ampliacao de regra).

[Aplique a mesma estrutura do spec-project-business.md - Problem, Goals, Glossario, Regras,
Requisitos, User Stories, Edge Cases, Riscos, Plano impl/valid, Anexos, Traceability, Success
Criteria, Historico]

## Diferencial deste template

- Secao "Comportamento atual vs comportamento desejado" antes das regras de negocio
- Refere-se ao baseline existente em `rastreio.baseline_arquivos`
- Tipicamente menor que Project+Business
