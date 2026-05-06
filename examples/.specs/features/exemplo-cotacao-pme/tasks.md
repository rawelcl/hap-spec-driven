# Cotacao PME Tasks

**Design:** `.specs/features/exemplo-cotacao-pme/design.md`
**Status:** Draft

---

## Plano de execucao

### Fase 1: Fundacao backend

```
T1 -> T2 -> T3
```

### Fase 2: Servicos core

```
       +-> T4 [P] -+
T3 ----+-> T5 [P] -+--> T8
       +-> T6 [P] -+
```

### Fase 3: API e UI

```
T8 -> T9 -> T10 -> T11
```

---

## Detalhamento das tasks

### T1: Definir entidades de dominio (Cotacao, BeneficiarioCotacao, Plano)

**O que:** records Java + DDL Oracle + scripts de migration
**Onde:** `comercial-core/src/main/java/com/hapvida/comercial/cotacao/domain/`
**Depende de:** Nenhuma
**Reutiliza:** `[REF: ADR-21]` glossario, `[REF: ADR-74]` DDD
**Requirement:** FEAT-01, FEAT-02

**Ferramentas:**
- MCP: nenhuma especifica
- Skill: nenhuma

**Done when:**
- [ ] Records definidos com validation
- [ ] DDL Oracle revisado pelo DBA
- [ ] Migration script criado e testado em DEV
- [ ] Test count: 5 testes (validacao de invariantes) passam

**Tests:** unit
**Gate:** quick
**Commit:** `WI-28471: feat(comercial): definir entidades de dominio para cotacao`

---

### T2: Criar CotacaoRepository (JPA)

**O que:** repositorio JPA para Cotacao
**Onde:** `comercial-core/src/main/java/com/hapvida/comercial/cotacao/repository/`
**Depende de:** T1
**Reutiliza:** `[REF: ADR-22]` Padrao Repositorio
**Requirement:** FEAT-05

**Ferramentas:**
- MCP: nenhuma
- Skill: nenhuma

**Done when:**
- [ ] CotacaoRepository implementa CRUD basico
- [ ] Indices apropriados em DDL (id, corretor, dt_cotacao)
- [ ] Test count: 4 testes (save, findById, findByCorretor, findExpired) passam

**Tests:** integration
**Gate:** full
**Commit:** `WI-28471: feat(comercial): adicionar repositorio JPA de cotacoes`

---

### T3: Criar PkgPropostaGateway (anti-corruption layer)

**O que:** wrapper Java sobre `pkg_proposta.calcula_mensalidade`
**Onde:** `comercial-core/src/main/java/com/hapvida/comercial/cotacao/gateway/`
**Depende de:** T1
**Reutiliza:** padrao Gateway, `[REF: ADR-22]`
**Requirement:** FEAT-02

**Ferramentas:**
- Skill: `plsql-oracle-expert` (validar interface da stored procedure)

**Done when:**
- [ ] Gateway chama stored proc com parametros tipados
- [ ] Tratamento de erros conforme design
- [ ] Test count: 3 testes (happy path, edge cases, error handling) passam

**Tests:** integration (com banco DEV)
**Gate:** full
**Commit:** `WI-28471: feat(comercial): adicionar gateway para pkg_proposta`

---

### T4: Implementar CotacaoService.gerar [P]

**O que:** logica de orquestracao para gerar cotacao
**Onde:** `comercial-core/src/main/java/com/hapvida/comercial/cotacao/CotacaoService.java`
**Depende de:** T2, T3
**Reutiliza:** patterns do `[REF: ADR-74]` DDD
**Requirement:** FEAT-01, FEAT-02, FEAT-03

**Ferramentas:**
- MCP: nenhuma

**Done when:**
- [ ] gerar() valida input, chama gateway, persiste, retorna
- [ ] Tratamento de EC-01, EC-02, EC-03 conforme design
- [ ] Test count: 8 testes passam

**Tests:** unit
**Gate:** quick
**Commit:** `WI-28471: feat(comercial): implementar geracao de cotacao`

---

### T5: Implementar CotacaoService.recuperar [P]

**O que:** recuperacao por ID
**Onde:** `CotacaoService.java`
**Depende de:** T2
**Requirement:** FEAT-05, FEAT-06

**Done when:**
- [ ] recuperar() retorna Optional<Cotacao>
- [ ] Test count: 3 testes passam

**Tests:** unit
**Gate:** quick
**Commit:** `WI-28471: feat(comercial): implementar recuperacao de cotacao`

---

### T6: Integrar PdfGateway [P]

**O que:** wrapper para PDFService corporativo
**Onde:** `comercial-core/.../gateway/PdfGateway.java`
**Depende de:** T1
**Requirement:** FEAT-04

**Done when:**
- [ ] Gateway gera PDF a partir de Cotacao
- [ ] Auth corporativo configurado
- [ ] Test count: 2 testes (sucesso, erro) passam

**Tests:** integration
**Gate:** full
**Commit:** `WI-28471: feat(comercial): integrar PdfService para gerar proposta`

---

### T7: API endpoints REST (CotacaoController)

**O que:** controller com 3 endpoints
**Onde:** `comercial-bff/.../CotacaoController.java`
**Depende de:** T4, T5, T6
**Reutiliza:** `[REF: ADR-14]`
**Requirement:** FEAT-01, FEAT-02, FEAT-04, FEAT-05, FEAT-06

**Done when:**
- [ ] POST /api/cotacoes funciona
- [ ] GET /api/cotacoes/{id} funciona
- [ ] GET /api/cotacoes/{id}/pdf funciona
- [ ] Test count: 6 testes (3 endpoints x happy + edge) passam

**Tests:** integration (springboot test)
**Gate:** full
**Commit:** `WI-28471: feat(comercial): expor API REST de cotacoes`

---

### T8: UI - Formulario de cadastro de beneficiarios

**O que:** componente React para cadastrar beneficiarios
**Onde:** `comercial-ui/src/features/cotacao/components/BeneficiariosForm.tsx`
**Depende de:** T7 (interface da API)
**Reutiliza:** `[REF: ADR-25]`
**Requirement:** FEAT-01

**Done when:**
- [ ] Formulario valida CEP, datas, sexo
- [ ] Faixa etaria calculada automaticamente
- [ ] Test count: 5 testes (RTL) passam

**Tests:** unit (component)
**Gate:** quick
**Commit:** `WI-28471: feat(comercial): adicionar formulario de cadastro de beneficiarios`

---

### T9: UI - Tela de cotacao com breakdown

**O que:** componente que exibe resultado
**Onde:** `comercial-ui/src/features/cotacao/components/ResultadoCotacao.tsx`
**Depende de:** T8
**Requirement:** FEAT-02, FEAT-03

**Done when:**
- [ ] Exibe valor total + breakdown
- [ ] Botao para gerar PDF
- [ ] Test count: 4 testes passam

**Tests:** unit (component)
**Gate:** quick
**Commit:** `WI-28471: feat(comercial): adicionar tela de resultado de cotacao`

---

### T10: UAT - Fluxo completo cadastro -> cotacao -> PDF

**O que:** teste E2E + UAT interativo
**Onde:** `comercial-ui/cypress/e2e/cotacao-pme.cy.ts`
**Depende de:** T9
**Requirement:** todos P1

**Done when:**
- [ ] Teste E2E passa
- [ ] UAT interativo conduzido com TL e validado

**Tests:** e2e
**Gate:** full
**Commit:** `WI-28471: test(comercial): adicionar e2e de cotacao PME`

---

### T11: Telemetria e metricas

**O que:** instrumentar TTQ e taxa de erro
**Onde:** servicos relevantes
**Depende de:** T10
**Requirement:** Success Criteria

**Done when:**
- [ ] Metricas custom expostas em endpoint /actuator
- [ ] Dashboard configurado em ferramenta corporativa

**Tests:** none
**Gate:** build
**Commit:** `WI-28471: feat(comercial): instrumentar telemetria de cotacao`

---

## Validacao pre-aprovacao

### Granularity Check

Todas as tasks tocam UM componente / arquivo coeso. OK Granular.

### Diagram-Definition Cross-Check

Verificacao manual: setas no diagrama batem com `Depende de` em cada task. OK Match.

### Test Co-location Validation

| Task | Camada | Matrix exige | Task diz | Status |
|---|---|---|---|---|
| T1 | Domain | unit | unit | OK |
| T2 | Repository | integration | integration | OK |
| T3 | Gateway | integration | integration | OK |
| T4 | Service | unit | unit | OK |
| T5 | Service | unit | unit | OK |
| T6 | Gateway | integration | integration | OK |
| T7 | Controller | integration | integration | OK |
| T8 | UI Component | unit | unit | OK |
| T9 | UI Component | unit | unit | OK |
| T10 | E2E | e2e | e2e | OK |
| T11 | Config | none | none | OK |

Tudo OK.
