# Glossario - Dominio Comercial (venda de planos)

> **Status:** Seed - expandir durante o piloto.

## Termos canonicos

### Beneficiario

Pessoa fisica titular ou dependente de um plano de saude. Sinonimo legado: `BNF`.

### Cliente

Pessoa fisica ou juridica que contrata um plano. Tambem chamado de `contratante`.

### Plano

Produto comercializado, vinculado a uma carteira de coberturas e tabelas de precos.

### Proposta

Oferta de plano feita a um cliente prospect, antes da efetivacao do contrato.

### Cotacao

Calculo de mensalidade para um conjunto de beneficiarios em um plano especifico, em uma data
especifica. Pode existir varias cotacoes ate uma proposta ser fechada.

### Carencia

Periodo apos a vigencia inicial em que o beneficiario nao pode usufruir de determinados servicos
do plano. **Regulada por** Lei 9.656/98 art. 12 - carencias maximas.

### Vigencia

Periodo em que o plano esta ativo. `vigencia_inicio` e `vigencia_fim`. Sinonimo legado: `DT_VIG`.

### Coberturas

Conjunto de procedimentos e servicos cobertos pelo plano, regulados pelo Rol da ANS.

### Coparticipacao

Valor que o beneficiario paga ao usar determinados servicos. Calculo deterministico, regulado por
RNs ANS.

### Reajuste

Ajuste anual ou por sinistralidade da mensalidade. Tipos: anual (regulado por RN ANS), por
sinistralidade (planos coletivos), por mudanca de faixa etaria.

### Faixa etaria

Faixas regulamentadas pela ANS para precificacao - `0-18`, `19-23`, `24-28`, `29-33`, `34-38`,
`39-43`, `44-48`, `49-53`, `54-58`, `59+`.

### Contrato

Documento juridico que formaliza a relacao entre cliente e operadora.

### Renovacao

Processo automatico ou manual de renovacao do contrato apos periodo de vigencia.

### Cancelamento

Encerramento do contrato. Tipos: a pedido do cliente, por inadimplencia, por descumprimento.

### Portabilidade

Direito do beneficiario migrar entre operadoras sem novo periodo de carencia, conforme RN
ANS aplicavel.

### Elegibilidade

Verificacao se um beneficiario pode usufruir de servico em determinado momento (vigencia ativa,
sem inadimplencia, sem carencia pendente).

---

## Termos a expandir (gaps identificados)

- [ ] CPT (Cobertura Parcial Temporaria)
- [ ] DLP (Doenca ou Lesao Preexistente)
- [ ] Rol de Procedimentos
- [ ] Tabela de precos por plano
- [ ] Regras comerciais por canal de venda
