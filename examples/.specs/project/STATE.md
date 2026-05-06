# State - Squad Cotacao PME

**Last Updated:** 2026-05-06
**Current Work:** Cotacao PME - Spec inicial em refinamento

---

## Recent Decisions

### AD-001: Manter calculo de mensalidade no PL/SQL legado para v1 (2026-04-15)

**Decision:** Reusar `pkg_proposta.calcula_mensalidade` da tag PRODUCAO sem refatorar para v1
**Reason:** Refatoracao introduz risco e estende cronograma. Foco no MVP.
**Trade-off:** Mantem dependencia de codigo legado complexo
**Impact:** Servico Java chama PL/SQL via stored procedure
**Tipo:** local

### AD-002: Nao implementar cache no MVP (2026-04-22)

**Decision:** Sem cache de cotacoes no MVP - cada cotacao recalcula
**Reason:** Volume de cotacoes baixo no MVP, complexidade nao justifica
**Trade-off:** Performance pior em cenario de stress
**Impact:** Servico mais simples
**Tipo:** local

---

## Active Blockers

(nenhum)

---

## Lessons Learned

### L-001: Drift entre tag PRODUCAO e banco real em pkg_proposta

**Context:** Ao iniciar refatoracao paralela, descobrimos que `pkg_proposta` no banco esta diferente da tag PRODUCAO no CVS
**Problem:** Hot-fix de 2024 nao foi commitado de volta no CVS
**Solution:** Time de DBA fez checkin retroativo, tag PRODUCAO atualizada
**Prevents:** Confusao em futuras refatoracoes - sempre validar drift antes

---

## Quick Tasks Completed

(vazio - Quick Mode fora do escopo do piloto v0.2)

---

## Deferred Ideas

- [ ] Cache de cotacoes (v2)
- [ ] Integracao Lecom para esteira de aprovacao (v2)
- [ ] Cotacao colaborativa (corretor + prospect simultaneos)

---

## Todos

- [ ] Validar com Compliance se calculo de carencia para PME estende criterio padrao
- [ ] Confirmar com DBA que tag PRODUCAO esta sincronizada antes de iniciar refatoracao paralela

---

## Preferences

**Model Guidance Shown:** never
**Skills SIGO availability:** yes (sigo-modernizacao-plsql, plsql-oracle-expert)
**MCP do ADO configurado:** yes (2026-04-10)
