---
spec_id: SPEC-2026-COM-0042
titulo: Cotacao online de planos PME (1-99 vidas)
work_item_id: 28471
work_item_type: Feature
work_item_url: https://dev.azure.com/hapvidalabs/comercial/_workitems/edit/28471

demand_type: Project
value_area: Business
demand_category: Plataforma de venda

area_solicitante: Comercial
stack_principal: mista
risco_regulatorio: medio

autor: <Tech Lead Cotacao PME>
papel_autor: tech-lead
revisores:
  - papel: arquiteto
    nome: <Arquiteto Comercial>
    decisao_em: 2026-05-02
  - papel: compliance
    nome: <Compliance Officer>
    decisao_em: 2026-05-04

estado_spec: in-refinement
datas:
  criacao: 2026-04-25
  refinement_iniciado: 2026-04-25
  approved: <a preencher>

rastreio:
  servicenow_inc: <nao aplicavel>
  lecom_id: 5421
  gmud_chg: <a definir>
  baseline_cvs_tag: PRODUCAO
  baseline_arquivos:
    - schema.pkg_proposta
  prd_path: '/lecom/comercial/prd-cotacao-pme-v2.pdf'
  ata_teams_path: '/comercial/atas/2026-04-15-kickoff-cotacao-pme.txt'

adrs_referenciadas:
  - ADR-21
  - ADR-22
  - ADR-24
  - ADR-25

normas_ans_aplicaveis:
  - Lei-9656-98
  - RN-195-2009
  - RN-593-2023

glossario_termos:
  - beneficiario
  - cotacao
  - proposta
  - plano
  - vigencia
  - carencia
  - faixa-etaria

versao_spec: 0.1
ultima_atualizacao: 2026-05-06
---

# Cotacao online de planos PME - Especificacao

## 1. Problem Statement

Cotacoes para planos coletivos PME (1-99 vidas) hoje sao processo manual via planilha e
contato com backoffice, levando em media 4 horas. Corretores parceiros perdem oportunidades
por falta de agilidade. Plataforma online dara autonomia para gerar cotacoes em <10 minutos.

## 2. Goals

- [ ] TTQ medio reduzido para <10 minutos
- [ ] 100% das cotacoes em conformidade com regras ANS vigentes
- [ ] Adesao de 30% dos parceiros em 6 meses pos-lancamento

## 3. Out of Scope

| Feature | Motivo |
|---|---|
| Pagamento online | Proximo ciclo - escopo separado |
| Cotacao de planos individuais | Squad separado |
| Integracao Lecom para esteira | v2 |

## 4. Glossario aplicavel

Termos canonicos `[REF: ADR-21]`:

- **Beneficiario**: pessoa fisica titular ou dependente
- **Cotacao**: calculo de mensalidade para conjunto de beneficiarios em plano especifico
- **Proposta**: oferta de plano formalizada
- **Plano PME**: plano coletivo empresarial para 1 a 99 vidas
- **Vigencia**: periodo de validade da cotacao (default 30 dias)
- **Faixa etaria**: faixas regulamentadas ANS para precificacao

## 5. Regras de negocio

### RN-01: Calculo de mensalidade segue tabela vigente

- **Gatilho:** corretor solicita cotacao
- **Comportamento:** sistema calcula mensalidade por beneficiario em funcao de faixa etaria, plano e CEP
- **Resultado:** valor total + breakdown por beneficiario
- **Fonte:** `pkg_proposta.calcula_mensalidade` no baseline (sera reusado, AD-001 do squad)

### RN-02: Aplicacao de carencias padrao [ANS]

- **Gatilho:** cotacao aceita pelo cliente
- **Comportamento:** carencias sao aplicadas conforme RN ANS aplicavel
- **Resultado:** datas de inicio de cobertura calculadas por categoria
- **Fonte:** `[ANS]` Lei 9.656/98 art. 12 + RN 195/2009

### RN-03: Validade da cotacao

- **Gatilho:** cotacao gerada
- **Comportamento:** sistema atribui validade de 30 dias a partir da geracao
- **Resultado:** apos 30 dias cotacao expira automaticamente
- **Fonte:** politica comercial Hapvida (PRD secao 4.2)

## 6. Requisitos funcionais

- Corretor cadastra beneficiarios (1-99 vidas)
- Corretor seleciona plano dentre opcoes elegiveis para PME
- Sistema calcula mensalidade
- Sistema gera PDF com proposta + condicoes contratuais
- Corretor envia proposta ao prospect

## 7. Requisitos nao-funcionais

| Categoria | Requisito |
|---|---|
| Performance | p95 < 2s para gerar cotacao com ate 50 vidas |
| Disponibilidade | 99.5% horario comercial (8h-20h dias uteis) |
| Seguranca | Autenticacao Entra ID corporativo + autorizacao por perfil |
| LGPD | Anonimizacao em logs; consentimento explicito do prospect |
| Observabilidade | Metricas de TTQ, taxa de conversao, erros por etapa |

## 8. Restricoes regulatorias [ANS]

- `[ANS]` Lei 9.656/98 art. 12 - carencias maximas aplicaveis
- `[ANS]` RN 195/2009 - tipos de planos coletivos
- `[ANS]` RN 593/2023 - Rol de Procedimentos vigente

## 9. User Stories

### P1: Cadastro de beneficiarios e geracao de cotacao - MVP

**Como** corretor, **quero** cadastrar beneficiarios e gerar cotacao online **para** dar
resposta rapida ao prospect.

**Why P1:** Core do produto - sem isso nao ha plataforma.

**Acceptance Criteria:**

| ID | Criterio |
|---|---|
| FEAT-01 | WHEN corretor cadastra beneficiario com data de nascimento, sexo, CEP THEN sistema SHALL validar e calcular faixa etaria automaticamente |
| FEAT-02 | WHEN corretor solicita cotacao com >=1 beneficiario e plano selecionado THEN sistema SHALL calcular mensalidade em <2s p95 |
| FEAT-03 | WHEN cotacao e gerada THEN sistema SHALL exibir breakdown por beneficiario + total mensal + carencias aplicaveis |
| FEAT-04 | WHEN corretor solicita PDF THEN sistema SHALL gerar PDF da proposta com termos contratuais ANS |

**Independent Test:** corretor consegue cadastrar 5 beneficiarios fictícios, gerar cotacao,
exportar PDF.

### P2: Salvamento e historico de cotacoes

**Como** corretor, **quero** salvar cotacoes geradas **para** retomar com prospect depois.

**Acceptance Criteria:**

| ID | Criterio |
|---|---|
| FEAT-05 | WHEN corretor salva cotacao THEN sistema SHALL armazenar com validade de 30 dias |
| FEAT-06 | WHEN corretor acessa historico THEN sistema SHALL listar cotacoes ativas e expiradas dos ultimos 90 dias |

### P3: Compartilhamento de cotacao por link

**Acceptance Criteria:**

| ID | Criterio |
|---|---|
| FEAT-07 | WHEN corretor solicita link de cotacao THEN sistema SHALL gerar URL temporaria (7 dias) |

## 10. Edge Cases

| ID | Cenario | Comportamento esperado |
|---|---|---|
| EC-01 | Beneficiario com CEP invalido | Erro claro com sugestao de correcao |
| EC-02 | Plano nao disponivel para regiao do CEP | Mostrar planos alternativos disponiveis |
| EC-03 | Mais de 99 beneficiarios | Bloquear e indicar produto adequado |
| EC-04 | Beneficiario com idade >=60 anos sem dependente | Aplicar regra especifica de plano (consultar Compliance) `[REVISAO]` |

## 11. Riscos, premissas e dependencias

**Riscos:**
- Mudanca de RN ANS durante desenvolvimento - mitigacao: monitorar comunicacoes ANS, Compliance review semanal
- Drift em `pkg_proposta` legado - mitigacao: AD-002 do squad, DBA validou tag PRODUCAO

**Premissas:**
- [PREMISSA] Tabela de precos vigente esta atualizada em `tb_tabela_precos`
- [PREMISSA] CEP esta pre-validado em `tb_cep` (sera removida se nao verdadeiro)

**Dependencias:**
- Servico de Auth (Entra ID) - ja disponivel
- `pkg_proposta` no banco corporativo
- Servico de geracao de PDF corporativo

**Stakeholders:**
- Corretores (usuarios finais)
- Backoffice Comercial (operam excecoes)
- Compliance (revisao regulatoria)

## 12. Plano de implementacao (high-level)

- Frontend React + TypeScript per `[REF: ADR-25]`
- Backend Java Spring Boot per `[REF: ADR-24]`
- Padrao Repositorio per `[REF: ADR-22]`
- Calculo via stored procedure `pkg_proposta.calcula_mensalidade` (decisao AD-001 do squad)
- Geracao de PDF via servico corporativo

Detalhes em `design.md`.

## 13. Plano de validacao

| Criterio | Test Case ADO | Massa de teste |
|---|---|---|
| FEAT-01 | TC-2891 | beneficiarios sinteticos cobrindo todas as faixas etarias |
| FEAT-02 | TC-2892 | conjuntos de 1, 10, 50 vidas |
| FEAT-03 | TC-2893 | comparacao com calculo manual |
| FEAT-04 | TC-2894 | PDF gerado validado contra modelo aprovado por Juridico |
| FEAT-05 | TC-2895 | persistencia + recuperacao |
| FEAT-06 | TC-2896 | listagem com filtros |
| FEAT-07 | TC-2897 | link valido + expiracao em 7 dias |

**Tipos de teste necessarios:**
- [x] Unit (servicos Java)
- [x] Integration (chamada PL/SQL)
- [x] E2E (fluxo completo)
- [x] UAT (interativa - feature user-facing)

## 14. Anexos e rastreio de fontes

| Fonte | Identificador / Link |
|---|---|
| Work item ADO | WI-28471 |
| Lecom ID | 5421 (PRD oficial) |
| Baseline CVS tag | PRODUCAO |
| Baseline arquivos | `schema.pkg_proposta` |
| PRD | `/lecom/comercial/prd-cotacao-pme-v2.pdf` |
| Ata Teams kickoff | `/comercial/atas/2026-04-15-kickoff-cotacao-pme.txt` `[REVISAO]` |
| ADRs | ADR-21, ADR-22, ADR-24, ADR-25 |

## 15. Requirement Traceability

| ID | Story | Fase | Status |
|---|---|---|---|
| FEAT-01 | P1 | Design | Pending |
| FEAT-02 | P1 | Design | Pending |
| FEAT-03 | P1 | Design | Pending |
| FEAT-04 | P1 | Design | Pending |
| FEAT-05 | P2 | - | Pending |
| FEAT-06 | P2 | - | Pending |
| FEAT-07 | P3 | - | Pending |

## 16. Success Criteria

- [ ] Corretor gera cotacao com 50 vidas em <10 minutos (medido em UAT com corretores reais)
- [ ] 100% dos calculos batem com calculo manual de referencia
- [ ] PDF gerado aprovado por Juridico
- [ ] Adesao de 30% dos parceiros em 6 meses pos-go-live

## 17. Estado e historico

| Versao | Data | Autor | Mudanca |
|---|---|---|---|
| 0.1 | 2026-04-25 | TL Cotacao PME | Versao inicial |
| 0.2 | 2026-05-04 | TL Cotacao PME | Refinamento apos review com Compliance |
