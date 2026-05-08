---
mode: 'agent'
description: 'Implementar uma task - ciclo planejar > implementar > verificar > commit'
---

> **[HAP-SDD]** Hapvida Desenvolvimento Spec-Driven · [`SKILL.md`](../SKILL.md)

# Tarefa

Implementar UMA task por vez do `tasks.md` da feature em foco. Mudancas cirurgicas.
Verificar. Commit. Repetir.

# Input esperado

- **Feature em foco** (nome/slug)
- **Task a implementar** (ex: "T3" ou "proxima disponivel")
- `tasks.md` deve existir com `ADO Task ID` preenchido em todas as tasks

# OBRIGATORIO antes de comecar

**Declare explicitamente:**

1. **Premissas** - O que estou assumindo? Qualquer incerteza?
2. **Arquivos a tocar** - APENAS os arquivos que esta task exige
3. **Criterio de sucesso** - Como vou verificar que funciona?

**Nao prossiga sem declarar isso.**

# Checklist pre-implementacao (nao-negociavel)

- [ ] `tasks.md` existe na pasta da feature
- [ ] Status do `tasks.md` esta `Synced` ou `In Progress`
- [ ] A task escolhida tem `ADO Task ID` preenchido
- [ ] Dependencias da task estao satisfeitas (tasks anteriores concluidas)

Se algum item falhar: PARE e rode `/tasks-from-design` antes de prosseguir.

# Passos

1. **Carregar contexto** - ler `spec.md`, `design.md` (se existir), `context.md` (se existir),
   e a task especifica do `tasks.md`

2. **Verificar dependencias** - confirmar que tasks prerequisito estao concluidas

3. **Implementar** seguindo coding-principles.md:
   - Mudancas cirurgicas - apenas o que a task exige
   - Para PL/SQL: cabecalho de comentario com `WI-####` e `SPEC-####`
   - Para Java/.NET: commits atomicos com `WI-<ADO Task ID>: <type>(<scope>): <descricao>`

4. **Verificar** (parte obrigatoria de cada task):
   - Rodar testes do escopo afetado
   - Checklist de codigos PL/SQL: sem DML em producao, sem acesso a dados PII direto
   - Confirmar criterio de sucesso declarado no passo pre-implementacao

5. **Commit**:
   - Formato: `WI-<ADO Task ID>: <type>(<scope>): <descricao>`
   - Exemplos: `WI-12345: feat(proposta): calcula carencia por acomodacao`
   - Atualizar status da task em `tasks.md` para `done`

6. **Reportar** - resumo do que foi implementado, testes que passaram, proxima task sugerida

# Guardrails

- `[GUARDRAIL]` NUNCA acessar ou modificar dados de producao diretamente
- `[GUARDRAIL]` Para PL/SQL: cabecalho de comentario com `WI-####` e `SPEC-####` no procedure

# Output

Task implementada, verificada e commitada. `tasks.md` atualizado. Resumo ao TL com status
e proxima task disponivel.
