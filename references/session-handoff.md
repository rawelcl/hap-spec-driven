# Session Handoff

**Goal:** Pausar trabalho com contexto preservado e retomar em nova sessao sem perda.

**Triggers:**
- Pause: "Pause work", "end session", "stopping for the day"
- Resume: "Resume work", "continue", "where were we"

## Output

`.specs/project/HANDOFF.md` (criado em pause, lido em resume, opcionalmente arquivado)

## Estrutura

```markdown
# Handoff - [data ISO]

## Where I was

**Feature:** [nome da feature]
**Phase:** [Specify | Design | Tasks | Execute | Validate]
**Current task:** T[N]: [titulo da task]

## What's done

- [x] T1
- [x] T2
- [x] T3 (em parte - faltando [especifico])

## What's next

- [ ] T4
- [ ] T5

## Open decisions

- [Decisao pendente que esta aguardando input]
- [Decisao pendente que esta aguardando alguem]

## Blockers (se houver)

- [B-NNN: descricao]

## Notes para o eu do futuro

- [Algo que voce quer lembrar - exemplo: "estava pensando em reusar pkg_X mas nao tinha confirmado"]
- [Detalhe que pode escapar facil]

## Files in flight

- `src/path/file1.java` - [estado: implementado parcialmente, falta tratamento de erro]
- `src/path/file2.java` - [estado: refatorado, testes pendentes]
```

## Process

### Pause

1. Salve mudancas no VCS (commit em branch de trabalho ou stash)
2. Atualize STATE.md com any pending decisions/blockers
3. Crie HANDOFF.md com snapshot do estado mental
4. Indique ao usuario: "Sessao pausada. Para retomar: 'Resume work'."

### Resume

1. Leia HANDOFF.md
2. Reconstrua contexto carregando docs apontados
3. Confirme com usuario: "Estavamos em [feature], task [T#]. Continuar de onde paramos?"
4. Apos reuniao confirmada, arquive HANDOFF.md (mover para `.specs/project/HANDOFF-ARCHIVE-YYYY-MM-DD.md`)

## Adaptacoes Hapvida

- Para PL/SQL no CVS: stash equivalente e checkin local em branch CVS de trabalho
- HANDOFF.md NUNCA contem dados de beneficiario reais (anonimizar antes de pausar)
- Quando pausa for entre TLs (passing the baton), o resumo de HANDOFF.md vira comentario no work
  item ADO via MCP - facilita continuidade
