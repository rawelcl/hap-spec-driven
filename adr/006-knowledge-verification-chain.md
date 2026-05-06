# ADR 006: Knowledge Verification Chain explicita

**Status:** Accepted
**Data:** 2026-05-06

## Contexto

LLMs podem alucinar (inventar APIs, padroes, comportamentos). No contexto Hapvida com regulacao
ANS, isso pode produzir codigo perigoso (ex: regra de carencia errada).

## Decisao

Adotar a **Knowledge Verification Chain** explicita do TLC, adaptada para Hapvida:

```
Step 1: Codebase
  PL/SQL: WinCVS tag PRODUCAO
  Java/.NET: ADO Repos main

Step 2: Project docs + Wiki Arquitetura-Referencia (>96 ADRs)

Step 3: Context7 MCP (libraries, frameworks)

Step 4: Web search (oficial ANS, padroes)

Step 5: Flag uncertain ([REVISAO] ou [BLOQUEADO])
```

Regras inegociaveis:
1. Nunca pular Steps 1-4
2. Step 5 sempre marcado como `[REVISAO]` ou `[BLOQUEADO]`, nunca apresentado como fato
3. NUNCA inventar - "nao sei" e sempre preferivel

## Justificativa

- Reduz alucinacao em area regulada
- Aproveita Wiki Arquitetura-Referencia (ja existe e e rica)
- Marcadores `[REVISAO]` e `[BLOQUEADO]` integram com tokens textuais Hapvida
- Sem custo - e instrucao comportamental no SKILL.md

## Consequencias

**Positivas:**
- Reducao de alucinacoes
- Cultura de citacao explicita de fontes
- Wiki Arquitetura-Referencia ganha mais uso (ROI dos >96 ADRs)

**Negativas:**
- Pode parecer "lento" inicialmente (passo a passo)
- Exige disciplina para nao pular steps
