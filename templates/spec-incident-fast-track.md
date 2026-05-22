---
spec_id: SPEC-YYYY-<area>-NNNN
titulo: <titulo curto - normalmente "Incident X">
work_item_id: <id>
work_item_type: Incident

demand_type: Maintenance  # ou conforme campo do work item
value_area: Business

criticidade: <alta | media>
servicenow_inc: <numero - obrigatorio>

area_solicitante: <area>
stack_principal: <stack>
risco_regulatorio: <alto | medio | baixo>

autor: <nome>
papel_autor: tech-lead

estado_spec: in-refinement

rastreio:
  servicenow_inc: <numero - obrigatorio>
  baseline_cvs_tag: PRODUCAO
  baseline_arquivos: []
  recent_implementation_wi: <numero do WI da implementacao recente que pode ter causado>

adrs_referenciadas: []
normas_ans_aplicaveis: []
glossario_termos: []

versao_spec: 0.1
ultima_atualizacao: YYYY-MM-DD
---

# [Incident] - Especificacao Fast-Track

> **Template:** Incident criticidade alta/media - fast-track para resolucao rapida com
> documentacao minima essencial. Vinculo a ServiceNow obrigatorio (campo Required-SNOw).

> **Tempo estimado:** TL deve elaborar essa spec em <2h apos confirmacao de ownership.

## 1. Problema

[O que esta quebrado / errado em producao - descricao curta e direta]

## 2. Impacto

| Categoria | Impacto |
|---|---|
| Quem afetado | [usuarios / clientes / parceiros] |
| Volume | [quantidade aproximada] |
| Severidade percebida | [alta / media / baixa] |
| Tempo desde inicio | [horas / dias] |

## 3. Causa raiz (root cause)

[Hipotese inicial - sera atualizada conforme analise]

**Recent Implementation linkada:** [link para WI se aplicavel - campo `Required-Recent Implementation`]

## 4. Solucao proposta

### Hot-fix (curto prazo)

[Acao para estabilizar producao agora]

### Correcao definitiva (medio prazo)

[Correcao que enderece causa raiz - pode virar outro work item]

## 5. Acceptance Criteria

| ID | Criterio |
|---|---|
| FEAT-01 | WHEN [reproducao do incidente] THEN sistema SHALL [comportamento correto] |

## 6. Plano de validacao

Para incidentes, o plano em HML/PROD foca em reproduzir o cenario afetado. Quando aplicavel,
cada task gera um `Tests Artifact` co-localizado em `.specs/features/[feature]/tests/` que
codifica a verificacao da correcao ([REF: ADR-013](../adr/013-modelo-testes-co-localizado-por-task.md)).

| Acao | Como verificar | Tests Artifact (se aplicavel) |
|---|---|---|
| Hot-fix em HML | Reproducir cenario, verificar correcao | `verifica_<cenario>.sql` ou `procedimento_<cenario>.md` |
| Hot-fix em PROD | Monitoramento pos-deploy 30 minutos | (acao operacional fora de tasks.md - QA/sustentacao) |

## 7. Comunicacao

- [ ] ServiceNow atualizado a cada [intervalo]
- [ ] Stakeholders comunicados conforme severidade
- [ ] Postmortem agendado (se severidade alta)

## 8. Loop de retroalimentacao

Apos resolucao, o framework exige:

- [ ] Comparar com spec original da feature de origem (se houver Required-Recent Implementation)
- [ ] Identificar gap na spec original que permitiu o incident
- [ ] Atualizar template/checklist da Feature de origem se gap identificado
- [ ] Registrar L-NNN em STATE.md do squad

## 9. Anexos

[Igual ao template generico, mais foco em ServiceNow + Recent Implementation]
