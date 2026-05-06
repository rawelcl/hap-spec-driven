# Squad Cotacao PME - Comercial

**Vision:** Plataforma de cotacao online de planos coletivos PME (Pequenas e Medias Empresas) que reduz tempo medio de gerar cotacao de 4h para <10min.

**For:** Equipe de vendas Comercial, parceiros (corretores), e clientes prospects PME.

**Solves:** Hoje cotacoes PME sao manuais, dependem de planilha e ligacao ao backoffice. Plataforma online da autonomia ao corretor e prospect.

## Goals

- [ ] **MVP em producao em Q3 2026** (sprint atual + 2)
- [ ] **Reducao de TTQ (Time-to-Quote)** de 4h para <10min
- [ ] **Adesao** - 30% dos parceiros usando plataforma em 6 meses
- [ ] **Conformidade ANS** - 100% das cotacoes seguem regras vigentes

## Tech Stack

- **Frontend:** React + TypeScript (per ADR 25)
- **Backend:** Java Spring Boot (per ADR 24)
- **PL/SQL legado** (calculos consolidados): `pkg_proposta` no banco corporativo
- **Banco:** Oracle (corporativo)

## Scope

**v1 (MVP) inclui:**
- Cotacao para planos PME (1 a 99 vidas)
- Calculo de mensalidade conforme tabelas vigentes
- Aplicacao de carencias e CPT padrao
- Geracao de PDF da proposta

**v1 fora de escopo:**
- Cotacao para planos individuais (squad separado)
- Pagamento online (proximo ciclo)
- Integracao Lecom para esteira de aprovacao (v2)

## Constraints

- **Timeline:** sprint atual + 2
- **Tecnicos:** integracao com `pkg_proposta` legado (refatoracao em paralelo - outro work item)
- **Recursos:** squad de 5 (1 TL + 3 devs + 1 QA)
- **Politicos:** 100% conformidade ANS - sem exceções
