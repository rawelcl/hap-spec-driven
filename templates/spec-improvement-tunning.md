---
spec_id: SPEC-YYYY-<area>-NNNN
titulo: <titulo curto - normalmente "Refatoracao de X">
work_item_id: <id>
work_item_type: Feature
work_item_url: https://dev.azure.com/<org>/<project>/_workitems/edit/<id>

demand_type: Improvement
value_area: Tunning

area_solicitante: <area>
stack_principal: PL/SQL
risco_regulatorio: <alto | medio | baixo>

autor: <nome>
papel_autor: tech-lead

revisores:
  - papel: arquiteto
    nome: <nome>

estado_spec: in-refinement
datas:
  criacao: YYYY-MM-DD

rastreio:
  servicenow_inc: <numero - tipicamente origem da demanda>
  baseline_cvs_tag: PRODUCAO
  baseline_arquivos:
    - schema.package_x
    - schema.procedure_y

ficha_tunning:
  tempo_pre_melhoria_seg: <numero>
  tempo_pos_melhoria_seg: <a preencher apos validacao>
  ganho_pct: <a calcular>
  cenario_medicao: <descricao da carga e ambiente>
  data_medicao_pre: YYYY-MM-DD
  data_medicao_pos: <a preencher>

adrs_referenciadas:
  - ADR-22  # Padrao Repositorio
  - ADR-74  # DDD
normas_ans_aplicaveis: []
glossario_termos: []

versao_spec: 0.1
ultima_atualizacao: YYYY-MM-DD
---

# [Refatoracao de X] - Especificacao (Improvement+Tunning)

> **Template:** Improvement + Tunning - **refatoracao PL/SQL** focada em performance ou modernizacao,
> sem mudanca de comportamento funcional.

> **`[GUARDRAIL]`** Comportamento funcional NAO pode mudar. Se mudar, vira Improvement+Business.

## 1. Contexto

### Comportamento atual

[Descricao do que a procedure/package faz hoje, baseado no baseline da tag PRODUCAO]

### Problema de performance ou design

[Descricao do problema - tempo de execucao, acoplamento, dificuldade de manutencao, etc]

## 2. Goals

- [ ] Reduzir tempo de execucao para <X> segundos (medido em [cenario])
- [ ] Aplicar `[REF: ADR-22]` (Padrao Repositorio)
- [ ] Aplicar `[REF: ADR-74]` (DDD) onde aplicavel
- [ ] Manter comportamento funcional **integro** (validacao via diff de output)

## 3. Out of Scope

- Mudanca de comportamento funcional (vira outro Demand Type)
- Mudanca de schema sem ADR aplicavel ou aprovacao do DBA

## 4. Code Reuse Analysis

### Componentes do baseline a substituir

| Componente legado | Substituicao | ADR |
|---|---|---|
| Cursor row-by-row em `pkg_x.proc_y` | BULK COLLECT + FORALL | `[REF: ADR-XX]` se houver |
| Logica de calculo inline | Package dedicado `pkg_x_calc` | `[REF: ADR-22]` |

### Pontos de migracao `[MIGRACAO]`

[Liste pontos com `DBMS_*`, `UTL_*`, tipos proprietarios, COMMITs dispersos, etc]

## 5. Strategy

### Abordagem de refatoracao

1. [Passo 1 - ex: extrair calculo para package separado]
2. [Passo 2 - ex: substituir cursor por BULK COLLECT/FORALL]
3. [Passo 3 - ex: adicionar exception handler explicito]

### Validacao de comportamento integro

| Metodo | Como aplicar |
|---|---|
| Diff de output | Rodar baseline + refatorado em massa de teste; comparar resultados |
| utPLSQL | Adicionar testes de regressao se viavel |
| Comparacao de plano | Verificar plano de execucao melhorou |

## 6. Ficha de Tunning

| Metrica | Pre | Pos | Ganho |
|---|---|---|---|
| Tempo execucao (cenario base) | <X>s | <a preencher> | <a calcular> |
| Tempo execucao (cenario stress) | <X>s | <a preencher> | <a calcular> |
| CPU consumida | <X>% | <a preencher> | <a calcular> |
| Memoria | <X>MB | <a preencher> | <a calcular> |

## 7. Riscos, premissas e dependencias

**Riscos:**
- Regressao funcional - mitigacao: massa de teste robusta
- Drift entre tag PRODUCAO e banco produtivo - mitigacao: corrigir drift antes de iniciar

**Premissas:**
- [PREMISSA] Tag PRODUCAO esta sincronizada com banco produtivo (validar antes)

## 8. Plano de validacao

[Cadeia ate producao - executar plano em HML, comparar com baseline]

## 9. Anexos e rastreio

[Igual ao template generico]

## 10. Estado e historico

[Igual ao template generico]

---

> **Skill recomendada:** `sigo-modernizacao-plsql` para extracao de regras do baseline,
> `plsql-oracle-expert` para code review pos-refatoracao.
