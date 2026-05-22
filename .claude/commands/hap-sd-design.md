---
mode: 'agent'
description: 'Gerar design.md a partir de spec.md aprovada'
---

> **[HAP-SDD]** Hapvida Desenvolvimento Spec-Driven · [`SKILL.md`](../SKILL.md)

# Tarefa

Gerar `.specs/features/[feature]/design.md` a partir da spec.md ja aprovada (estado `Approved`).

# Input esperado

- Path da spec.md
- Confirmacao do TL de que spec esta aprovada

# Passos

1. Ler spec.md completa
2. Ler context.md se existir (decisoes locked)
3. Aplicar Code Reuse Analysis - identificar codigo existente reutilizavel
4. Aplicar Knowledge Verification Chain
5. Citar ADRs aplicaveis via `[REF: ADR-XX]`
6. Para refatoracao PL/SQL: identificar `[MIGRACAO]` points
7. **Preencher secao `## Estrategia de verificacao`** ([ADR-013](../adr/013-modelo-testes-co-localizado-por-task.md)):
   para cada componente declarado em `## Components`, atribuir Approach esperado
   (automated|manual|hybrid|none), tooling (alinhado com TESTING.md do squad) e artifact path
   esperado em `.specs/features/[feature]/tests/`. Esse mapa alimenta diretamente o
   `hap-sd-tasks` na proxima fase.
8. Gerar design.md usando template
9. Confirmar com TL: "Design gerado em `.specs/features/[feature]/design.md`. Revisar antes de
   ir para Tasks?"

# Guardrails

- `[GUARDRAIL]` ADR aplicavel ausente -> `[ADR-AUSENTE]` + bloquear ate ADR ser proposta
- `[GUARDRAIL]` Decisoes locked em context.md sao invioleis

# Output

design.md criado + confirmacao + proximos passos.
