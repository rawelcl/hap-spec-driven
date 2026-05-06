---
spec_id: SPEC-YYYY-<area>-NNNN
titulo: <titulo curto - normalmente "Otimizacao de X">
work_item_id: <id>
work_item_type: <tipo>

demand_type: Maintenance
value_area: Tunning

area_solicitante: <area>
stack_principal: PL/SQL
risco_regulatorio: baixo

autor: <nome>
papel_autor: tech-lead

estado_spec: in-refinement

rastreio:
  servicenow_inc: <numero>
  baseline_cvs_tag: PRODUCAO
  baseline_arquivos: []

ficha_tunning:
  tempo_pre_melhoria_seg: <numero>
  tempo_pos_melhoria_seg: <a preencher>
  ganho_pct: <a calcular>

versao_spec: 0.1
ultima_atualizacao: YYYY-MM-DD
---

# [Otimizacao de X] - Especificacao (Maintenance+Tunning)

> **Template:** Maintenance + Tunning - otimizacao pontual sem refatoracao estrutural. Tipico de
> "queries lentas que viraram problema". Escopo menor que Improvement+Tunning.

## 1. Contexto

[Identificacao do gargalo - query lenta, procedure com plano ruim, etc]

## 2. Acao proposta

[Acao pontual - adicionar indice, reescrever WHERE, ajustar hint, etc]

## 3. Ficha de Tunning

| Metrica | Pre | Pos | Ganho |
|---|---|---|---|
| Tempo execucao | <X>s | | |

## 4. Riscos

- Plano de execucao pode degradar em outras queries - mitigacao: validar planos relacionados

## 5. Plano de validacao

[Comparacao de plano antes/depois, medicao em HML, monitoramento pos-deploy]

## 6. Anexos

[Igual ao template generico, mais foco em ficha de tunning]
