---
mode: 'agent'
description: 'Pausar ou retomar sessao de trabalho - gerencia HANDOFF.md para continuidade entre sessoes'
---

> **[HAP-SDD]** Hapvida Desenvolvimento Spec-Driven · [`SKILL.md`](../SKILL.md)

# Tarefa

Pausar o trabalho atual preservando o contexto (cria `HANDOFF.md`), ou retomar uma sessao
pausada anteriormente (le `HANDOFF.md` e reconstroi contexto).

# Input esperado

- **"Pause work" / "end session" / "stopping for the day"** → modo PAUSE
- **"Resume work" / "continue" / "where were we"** → modo RESUME

---

## Modo PAUSE

1. **Salvar mudancas** - lembrar ao TL de fazer commit em branch de trabalho ou stash antes
   de encerrar

2. **Ler estado atual**:
   - Qual feature esta em foco (`STATE.md` → `Current Work`)
   - Qual task esta em andamento (`tasks.md`)
   - Decisoes pendentes abertas

3. **Atualizar STATE.md**:
   - `Last Updated` com timestamp atual
   - Adicionar qualquer decisao ou blocker que surgiu na sessao

4. **Criar `.specs/project/HANDOFF.md`**:

   ```markdown
   # Handoff - [data ISO]

   ## Where I was
   **Feature:** [nome]
   **Phase:** [Specify | Design | Tasks | Execute | Validate]
   **Current task:** T[N]: [titulo]

   ## What's done
   - [x] T1
   - [x] T2
   - [x] T3 (em parte - faltando [especifico])

   ## What's next
   - [ ] T4: [descricao]
   - [ ] T5: [descricao]

   ## Open decisions
   - [Decisao pendente aguardando input]

   ## Blockers (se houver)
   - [B-NNN: descricao]

   ## Notes para o eu do futuro
   - [Detalhe importante que pode escapar]

   ## Files in flight
   - `src/path/file.java` - [estado: implementado parcialmente, falta X]
   ```

5. **Confirmar ao TL**: "Sessao pausada. HANDOFF.md criado. Para retomar: 'Resume work'."

---

## Modo RESUME

1. **Ler `.specs/project/HANDOFF.md`** - reconstruir estado mental completo

2. **Carregar contexto** dos documentos referenciados:
   - `spec.md` da feature em foco
   - `tasks.md` com status atual
   - `STATE.md` para decisoes e blockers ativos

3. **Confirmar com o TL**: "Estavamos em [feature], task [T#]: [titulo]. Continuar de onde
   paramos? Ou ha alguma mudanca de rumo?"

4. **Apos confirmacao**: arquivar HANDOFF.md para
   `.specs/project/HANDOFF-ARCHIVE-YYYY-MM-DD.md` e prosseguir com a task indicada.

# Output

**PAUSE:** `.specs/project/HANDOFF.md` criado + STATE.md atualizado.
**RESUME:** Contexto reconstruido + confirmacao com TL + HANDOFF.md arquivado.
