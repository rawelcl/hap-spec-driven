# ADR 005: Conventional Commits 1.0.0 com prefixo `WI-####:`

**Status:** Accepted
**Data:** 2026-05-06

## Contexto

Hapvida tem dois VCS estruturais (WinCVS para PL/SQL, ADO Repos Git para Java/.NET). Convencao de
commit unificada e desejavel para rastreabilidade ao work item.

## Decisao

Adotar **Conventional Commits 1.0.0** com prefixo obrigatorio `WI-<id>:` antes do tipo:

```
WI-12345: feat(comercial): adicionar validacao de carencia
WI-12345: refactor(plsql): extrair logica de calculo de proposta
WI-12345: fix(auth): corrigir refresh de token expirado
```

Para PL/SQL no CVS (cuja commit message e fraca), a convencao e replicada no **cabecalho de
comentario** do procedure ou package:

```sql
/*
 * WI-12345 / SPEC-2026-COM-0001
 * refactor(plsql): extrair logica de calculo de proposta
 * Refs: ADR-22 (Padrao Repositorio), ADR-74 (DDD)
 * [ANS] Lei 9.656/98 art. 12 - carencias maximas
 * Author: <nome>
 * Date: YYYY-MM-DD
 */
```

## Justificativa

- **Conventional Commits** e padrao de mercado, gera changelog, facilita semantic versioning quando
  aplicavel
- **Prefixo WI** vincula commit a work item ADO - rastreabilidade nativa
- **Cabecalho em PL/SQL** compensa fraqueza do CVS sem exigir mudanca de VCS

## Alternativas consideradas

- Sem padrao formal: descartado pela perda de rastreabilidade
- Padrao proprio Hapvida: descartado pela barreira de entrada
- Conventional Commits sem prefixo WI: descartado, perde rastreabilidade

## Consequencias

**Positivas:**
- Commits sao auto-explicativos
- Rastreio commit -> work item -> spec via grep simples
- Geracao de changelog automatizada possivel no futuro

**Negativas:**
- Disciplina exige treino e ferramentas (commit lint pode ajudar)
- Cabecalho PL/SQL e ritual extra para devs PL/SQL
