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

Se algum item falhar: PARE e rode `/hap-sd-tasks` antes de prosseguir.

# Passos

1. **Carregar contexto** - ler `spec.md`, `design.md` (se existir), `context.md` (se existir),
   e a task especifica do `tasks.md`

2. **Verificar dependencias** - confirmar que tasks prerequisito estao concluidas

3. **Implementar** seguindo coding-principles.md:
   - Mudancas cirurgicas - apenas o que a task exige
   - Para PL/SQL: cabecalho de comentario com `WI-####` e `SPEC-####`
   - Para Java/.NET: commits atomicos com `WI-<ADO Task ID>: <type>(<scope>): <descricao>`

4. **Criar/atualizar Tests Artifact** ([ADR-013](../adr/013-modelo-testes-co-localizado-por-task.md)):
   - Conforme `Tests Approach` declarado na task:
     - `automated` -> criar/atualizar script executavel em `Tests Artifact` (ex: `.sql` via MCP, `Test*.java`, `*.test.ts`)
     - `manual` -> criar/atualizar procedimento documentado em `Tests Artifact` (`.md` com passos numerados + resultado esperado)
     - `hybrid` -> ambos
     - `none` -> apenas justificar (refactor / doc sem mudanca de comportamento)
   - Artifact vive em `.specs/features/[feature]/tests/` conforme path declarado na task.

5. **Verificar** (parte obrigatoria de cada task):
   - Para `automated`/`hybrid`: rodar o Tests Artifact e capturar output (exit code, contagem, JUnit XML)
   - Para `manual`/`hybrid`: executar procedimento, capturar screenshot/log da etapa final
   - Checklist de codigos PL/SQL: sem DML em producao, sem acesso a dados PII direto
   - Confirmar criterio de sucesso declarado no passo pre-implementacao

6. **Registrar Evidence em tasks.md (OBRIGATORIO antes do commit):**
   - Preencher o campo `Evidence` da task com a saida real (nao placeholder):
     - `automated` -> comando real + exit code + contagem ("`./mvnw test -Dtest=UserServiceTest` exit 0; 14 testes passam")
     - `manual` -> path do screenshot ou log + assinatura ("`tests/screenshots/cadastro_passo5.png` + dev: rawelcl")
     - `hybrid` -> ambos
     - `none` -> justificativa textual final

7. **Commit**:
   - Formato: `WI-<ADO Task ID>: <type>(<scope>): <descricao>`
   - Exemplos: `WI-12345: feat(proposta): calcula carencia por acomodacao`
   - Atualizar status da task em `tasks.md` para `done`

8. **Reportar** - resumo do que foi implementado, evidencia registrada, proxima task sugerida

# Guardrails

- `[GUARDRAIL]` NUNCA acessar ou modificar dados de producao diretamente
- `[GUARDRAIL]` Para PL/SQL: cabecalho de comentario com `WI-####` e `SPEC-####` no procedure

# Output

Task implementada, verificada e commitada. `tasks.md` atualizado. Resumo ao TL com status
e proxima task disponivel.
