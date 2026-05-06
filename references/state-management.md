# State Management

**Proposito:** Memoria persistente entre sessoes - decisoes, blockers, aprendizados.

**`STATE.md` e OBRIGATORIO em projeto individual** (decisao Hapvida - ADR 009). PROJECT.md e
ROADMAP.md sao opcionais para projetos individuais; obrigatorios para o repositorio do framework.

## Adaptacoes Hapvida em relacao ao TLC original

- TLC tem STATE.md, PROJECT.md, ROADMAP.md no `.specs/project/` opcionais
- `[ADAPTACAO]` Hapvida torna **STATE.md obrigatorio em todo projeto/squad** que adota o framework
- ADRs locais do squad (AD-NNN) sao distintas das **ADRs corporativas** que vivem na wiki Arquitetura-Referencia

---

## Estrutura

**Output:** `.specs/project/STATE.md`

```markdown
# State - [Nome do Squad / Projeto]

**Last Updated:** [ISO timestamp]
**Current Work:** [Feature name] - [Task identifier]

---

## Recent Decisions (ultimos 60 dias)

### AD-[NNN]: [Decision title] ([data])

**Decision:** [O que foi decidido]
**Reason:** [Por que essa escolha]
**Trade-off:** [O que foi sacrificado]
**Impact:** [Como afeta implementacao]
**Tipo:** local | escalar-para-corporativo (se merece virar ADR na wiki)

### AD-[NNN]: [Decision title] ([data])

[mesma estrutura]

---

## Active Blockers

### B-[NNN]: [Blocker description]

**Discovered:** [Data]
**Impact:** [Severidade e escopo]
**Workaround:** [Solucao temporaria se houver]
**Resolution:** [Caminho para fix permanente]
**Owner:** [Quem esta resolvendo]

---

## Lessons Learned

### L-[NNN]: [Learning description]

**Context:** [Situacao que ocorreu]
**Problem:** [O que deu errado]
**Solution:** [Como foi resolvido]
**Prevents:** [O que esse aprendizado previne no futuro]

---

## Quick Tasks Completed

| # | Description | Date | Commit | Status |
|---|---|---|---|---|
| 001 | [Quick task description] | [date] | [hash] | OK Done |

> **Nota Hapvida:** Quick Mode esta fora do escopo do piloto v0.2. Esta tabela existe para futuro
> uso e tasks de manutencao pequena que nao se encaixam em fluxo completo.

---

## Deferred Ideas

Ideias capturadas durante trabalho que pertencem a features ou fases futuras. Previne scope creep
preservando boas ideias.

- [ ] [Idea description] - Captured during: [feature/phase]
- [ ] [Idea description] - Captured during: [feature/phase]

---

## Todos

Capture pensamentos em-progresso e action items que nao se encaixam em tasks ativas.

- [ ] [TODO: action item]
- [ ] [TODO: action item]

---

## Preferences

Estado comportamental do usuario com o agente:

**Model Guidance Shown:** [data ISO ou "never"]
**Skills SIGO availability:** [yes/no - quais]
**MCP do ADO configurado:** [yes/no - data]
```

---

## Quando atualizar

| Evento | Acao |
|---|---|
| Escolha arquitetural significativa local | Adicionar AD-[NNN] |
| Implementacao bloqueada | Adicionar B-[NNN] |
| Descoberta/aprendizado importante | Adicionar L-[NNN] |
| Quick task completada (raro no piloto) | Adicionar linha em Quick Tasks |
| Scope creep capturado | Adicionar a Deferred Ideas |
| Pensamento em-progresso | Adicionar a Todos |
| Fim de sessao | Atualizar "Last Updated" e "Current Work" |
| Decisao local que pode merecer ADR corporativa | Marcar `Tipo: escalar-para-corporativo` e propor ADR na wiki |

---

## Distincao critica - ADRs corporativas vs AD-NNN local

| Tipo | Onde vive | Escopo | Quem aprova |
|---|---|---|---|
| **ADR corporativa** | Wiki Arquitetura-Referencia | Toda organizacao Hapvida | Time de Arquitetura |
| **AD-NNN local** | `.specs/project/STATE.md` do squad | So o squad/projeto | TL do squad |
| **ADR do framework** | `adr/` deste repositorio | So o framework spec-driven | Mantenedores do framework |

Quando uma AD-NNN local revelar valor para outras squads, **proponha promover para ADR corporativa**
seguindo o processo da Wiki Arquitetura-Referencia.

---

## Size Management (Hybrid Strategy)

**Zonas:**

- **Verde** <7k tokens: Sem acao
- **Amarela** 7-10k tokens: Footer note "STATE.md em [X]k. Cleanup recomendado."
- **Vermelha** >10k tokens: Active prompt "STATE.md critico ([X]k). Cleanup agora?"

**Cleanup process:**

- Mover decisoes >60 dias para `STATE-ARCHIVE.md`
- Manter so blockers ativos
- Preservar aprendizados recentes (<60 dias)

**Validation:**

- Decisoes tem racional claro?
- Blockers incluem caminho de resolucao?
- Aprendizados sao acionaveis?

---

## Preferences (output behavior)

Track estado comportamental user-facing em STATE.md:

```markdown
## Preferences

**Model Guidance Shown:** [data ISO ou "never"]
```

**Atualizar quando:**

| Evento | Acao |
|---|---|
| Primeiro tip de modelo dado | Setar data |
| Usuario reconhece/dispensa | Manter data (nao repetir) |

Isso previne sugestoes repetitivas mantendo comportamento natural e util.

---

## Adaptacoes especificas Hapvida

- **STATE.md obrigatorio** - todo squad que adota o framework cria STATE.md no inicio
- **AD-NNN distinguir de ADRs corporativas** - decisoes locais nao "concorrem" com ADRs da wiki
- **Field `Skills SIGO availability`** em Preferences - permite ao agente saber se pode usar
  skills SIGO no contexto atual
- **Field `MCP do ADO configurado`** em Preferences - permite ao agente saber se pode usar MCP
  para anexar snapshot
- **Tabela Quick Tasks com nota explicita** - registra que Quick Mode esta fora do piloto v0.2
  mas a tabela existe para futuro uso e manutencoes pequenas
