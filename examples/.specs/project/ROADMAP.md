# Roadmap (exemplo)

**Projeto:** Refatoracao Modulo Comercial - Cotacao PME
**Current Milestone:** M1 - Cotacao PME modernizada (Improvement+Tunning)
**Status:** In Progress

---

## M1 - Cotacao PME modernizada (Q3/2026)

**Goal:** Substituir a procedure `PKG_PROPOSTA.GERAR_COTACAO_PME` (~1.800 linhas) por
servico Java com regras extraidas, mantendo paridade funcional e melhorando p95
de tempo de resposta de 4.2s para <1.5s.

**Demand Type / Value Area:** Improvement / Tunning
**Risco regulatorio:** Alto (toca calculo de mensalidade e CPT)

### Features

**FEAT-COT-PME-01 - Engenharia reversa da procedure** - COMPLETE

- Mapear cursores e blocos logicos
- Extrair regras de negocio com gatilho/comportamento/resultado
- Identificar pontos de [ANS] e [MIGRACAO]

**FEAT-COT-PME-02 - Servico Java de calculo base** - IN PROGRESS

- Implementar calculo da mensalidade base por faixa etaria
- Implementar aplicacao de coparticipacao
- Cobertura de testes >= 90%

**FEAT-COT-PME-03 - Servico Java de carencia/CPT** - PLANNED

- Aplicar tabela de carencia conforme Lei 9.656/98 art. 12
- Aplicar CPT em casos previstos pela RN ANS 438/2018

**FEAT-COT-PME-04 - Strangler Fig - rota dupla** - PLANNED

- Manter procedure legada como fallback
- Comparar resultados em paralelo (sombra)
- Migrar progressivamente por segmento de cliente

**FEAT-COT-PME-05 - Desativacao da procedure legada** - PLANNED

- Confirmar paridade durante 30 dias
- Marcar procedure como obsoleta
- Plano de rollback documentado

---

## M2 - Cotacao PJ Grande Porte (Q4/2026)

**Goal:** Replicar o padrao de M1 para `PKG_PROPOSTA.GERAR_COTACAO_PJ_GRANDE`.

### Features

**FEAT-COT-PJ-01 - Engenharia reversa procedure PJ** - PLANNED
**FEAT-COT-PJ-02 - Reuso do servico Java de M1** - PLANNED

---

## Future Considerations

- Migracao do calculo de reajuste anual
- Modernizacao do modulo de comissionamento
- Avaliacao de uso de event-driven architecture (depende de ADR)

---

_Atualizado: 2026-05-06_
