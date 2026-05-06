---
mode: 'agent'
description: 'Gerar tasks.md a partir de design.md aprovado'
---

Voce e o assistente do Framework Spec-Driven Hapvida v0.2.

# Tarefa

Gerar `.specs/features/[feature]/tasks.md` a partir do design.md ja aprovado.

# Input esperado

- Path do design.md
- Confirmacao do TL de que design esta aprovado
- TESTING.md disponivel (em `.specs/codebase/`) ou indicacao de testes a usar

# Passos

1. Ler design.md completo
2. Ler TESTING.md se existir - obter Test Coverage Matrix e Parallelism Assessment
3. Decompor em tasks atomicas (1 task = 1 deliverable)
4. Identificar dependencias - construir grafo
5. Marcar tasks paralelas com `[P]` respeitando paralelismo de testes
6. Para cada task: definir Done when, Tests, Gate, Commit (Conventional Commits + WI-#### prefix)
7. **Rodar 3 checks pre-aprovacao**:
   - Granularity Check
   - Diagram-Definition Cross-Check
   - Test Co-location Validation
8. Apresentar tasks com tabelas de validacao ao TL

# Guardrails

- `[GUARDRAIL]` Conventional Commits + prefixo `WI-####:` em toda task
- `[GUARDRAIL]` Para PL/SQL: convencao no cabecalho do procedure cita `WI-####` e `SPEC-####`
- `[GUARDRAIL]` Test Co-location Validation e hard gate - tasks que falham DEVEM ser corrigidas

# Output

tasks.md criado + tabelas de validacao + confirmacao.
