# ADR 009: STATE.md obrigatorio em projeto individual

**Status:** Accepted
**Data:** 2026-05-06

## Contexto

TLC tem PROJECT.md, ROADMAP.md e STATE.md como opcionais em `.specs/project/`. Hapvida precisa
decidir o que e obrigatorio em cada nivel.

## Decisao

| Arquivo | Repositorio do framework | Projeto individual (squad) |
|---|---|---|
| PROJECT.md | Obrigatorio | Opcional (pode delegar a Epic ADO) |
| ROADMAP.md | Obrigatorio | Opcional (pode delegar a board ADO) |
| **STATE.md** | Util para o framework | **OBRIGATORIO** |

## Justificativa

- **PROJECT.md/ROADMAP.md no squad**: muitos squads usam Epic e ADO Boards nativos como visao -
  duplicar em arquivos pode ser overhead
- **STATE.md no squad**: memoria persistente do squad e crucial para o framework funcionar entre
  sessoes - decisoes locais (AD-NNN), blockers (B-NNN), aprendizados (L-NNN), preferencias do
  agente. Sem STATE.md, o agente perde contexto entre sessoes.
- **STATE.md no framework**: util para evolucao do framework (decisoes do framework registradas)
  mas nao critico

## Consequencias

**Positivas:**
- Squads tem flexibilidade (PROJECT/ROADMAP no ADO se preferirem)
- Memoria persistente garantida (STATE.md sempre)
- Reducao de friccao para squads que ja usam ADO Boards/Epics como roadmap

**Negativas:**
- Inconsistencia entre squads que adotam PROJECT.md e os que nao
- STATE.md exige curadoria periodica (size management)

## Implementacao

- Project init script cria sempre STATE.md
- PROJECT.md e ROADMAP.md so criados se TL pedir explicitamente
- Tamanho do STATE.md gerenciado conforme zonas (verde <7k, amarela 7-10k, vermelha >10k)
- Cleanup de STATE.md: decisoes >60 dias movidas para STATE-ARCHIVE.md
