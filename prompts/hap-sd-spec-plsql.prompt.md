---
mode: 'agent'
description: 'Engenharia reversa de procedure/package PL/SQL para gerar spec.md (Improvement+Tunning)'
---

> **[HAP-SDD]** Hapvida Desenvolvimento Spec-Driven · [`SKILL.md`](../SKILL.md)

# Tarefa

Fazer engenharia reversa de uma procedure ou package PL/SQL e gerar spec.md tipo
**Improvement+Tunning** (refatoracao).

# Input esperado

- Caminho do arquivo PL/SQL no checkout do CVS na **tag PRODUCAO** (NUNCA banco produtivo)
- ID do work item ADO destino
- Cenario de medicao base para Ficha de Tunning

# Passos

1. **Verificar guardrail**: confirmar que o caminho aponta para checkout CVS tag PRODUCAO
2. **Verificar RE cacheada**: se existe `.specs/reverse-engineering/plsql/<NOME>/v<VERSAO_CVS>-rev-NNN/` com
   tag batendo na PRODUCAO atual, usar como baseline (`[REF]`). Se ausente ou stale, disparar antes
   o prompt [`/hap-sd-re-plsql`](hap-sd-re-plsql.prompt.md) que invoca
   a skill [`engenharia-reversa-sigo`](../skills/engenharia-reversa-sigo/SKILL.md).
3. Identificar: regras de negocio implementadas, gargalos de performance, pontos de modernizacao
   `[MIGRACAO]`
4. Aplicar Knowledge Verification Chain - citar ADRs aplicaveis (ADR 22 Padrao Repositorio,
   ADR 74 DDD)
5. Gerar spec usando template `spec-improvement-tunning`
6. Preencher Ficha de Tunning com `tempo_pre_melhoria_seg` (medir no cenario indicado)

# Guardrails

- `[GUARDRAIL]` Comportamento funcional NAO pode mudar (vira outro Demand Type se mudar)

# Output

Arquivo spec.md tipo Improvement+Tunning + Ficha de Tunning preenchida + confirmacao.
