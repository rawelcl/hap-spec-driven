# Codebase Concerns - Modulo Comercial SIGO (exemplo)

**Analysis Date:** 2026-05-01
**Baseline:** WinCVS tag `PRODUCAO`

---

## Tech Debt

**God procedures em PKG_PROPOSTA:**

- Issue: Procedures com mais de 1.500 linhas misturando regra de negocio, acesso a dados e formatacao
- Files: `PKG_PROPOSTA.GERAR_COTACAO_PME` (~1.800 linhas), `PKG_PROPOSTA.PROCESSAR_PROPOSTA` (~2.300 linhas)
- Why: Acumulo de 15+ anos de mudancas pontuais sem refatoracao
- Impact: Tempo de manutencao alto, risco de regressao em cada mudanca, p95 de execucao 4.2s
- Fix approach: Extrair regras para servicos Java (strangler fig), manter procedure fina como fachada durante transicao

**COMMIT/ROLLBACK disperso:**

- Issue: Mais de 40 chamadas de COMMIT espalhadas em sub-procedures internas
- Files: `PKG_PROPOSTA`, `PKG_BENEFICIARIO`, `PKG_REAJUSTE`
- Why: Codigo originalmente escrito sem padrao de transacao
- Impact: Inconsistencia possivel em caso de falha, dificil rollback
- Fix approach: Centralizar controle transacional na fachada, remover COMMITs internos

## Known Bugs

**Calculo de carencia incorreto para portabilidade:**

- Symptoms: Beneficiario portado de outra operadora recebe carencia integral em vez de aproveitamento
- Trigger: Proposta com flag `IND_PORTABILIDADE='S'` e tipo de produto especifico
- Files: `PKG_CARENCIA.CALCULAR_CARENCIA_INDIVIDUAL` linhas ~340-380
- Workaround: Atendimento ajusta manualmente apos importacao
- Root cause: Condicao no `DECODE` invertida - `[ANS]` viola RN ANS 438/2018
- Blocked by: Necessita ADR para definir se correcao vai no PL/SQL legado ou no servico Java em construcao

## Security Considerations

**SQL injection potencial em packages de relatorios:**

- Risk: Parametros recebidos como VARCHAR concatenados em queries dinamicas
- Files: `PKG_RELATORIOS.GERAR_RELATORIO_CUSTOMIZADO` linhas ~120-180
- Current mitigation: Acesso restrito via roles do Oracle
- Recommendations: Migrar para `DBMS_SQL` com bind variables ou para servico fora do banco

## Performance Bottlenecks

**N+1 queries em listagem de beneficiarios:**

- Problem: Loop em cursor de propostas chamando `PKG_BENEFICIARIO.OBTER_DADOS` para cada beneficiario
- Files: `PKG_RELATORIOS.LISTAR_PROPOSTAS_DETALHADO`
- Measurement: 1.500ms p95 com 100 propostas, 12s p95 com 500 propostas
- Cause: Falta de uso de `BULK COLLECT` + JOIN
- Improvement path: Refatorar para single query com JOIN + BULK COLLECT

**Falta de indice em coluna de busca frequente:**

- Problem: `TB_PROPOSTA.NUM_DOCUMENTO_TITULAR` sem indice, full table scan em consultas
- Files: chamadas em multiplos packages
- Measurement: Full scan em tabela de 12M linhas, 8s p95
- Cause: Indice nao foi criado quando o filtro virou comum
- Improvement path: `CREATE INDEX IDX_PROPOSTA_DOC ON TB_PROPOSTA(NUM_DOCUMENTO_TITULAR)` - validar com DBA antes

## Fragile Areas

**PKG_REAJUSTE.CALCULAR_REAJUSTE_ANUAL:**

- Files: `PKG_REAJUSTE` linhas 1.200-2.800
- Why fragile: Codigo regulado [ANS] tocado sempre que ANS publica novo indice anual
- Common failures: Branch missing para novo tipo de produto regulado
- Safe modification: Sempre criar nova rota com sombra paralela (calcular old + new e logar diferencas) antes de cutover
- Test coverage: ZERO testes automatizados [REVISAO]

## Missing Critical Features

**Logs estruturados:**

- Problem: `DBMS_OUTPUT` majoritariamente, nao persistido apos sessao
- Current workaround: DBA puxa traces sob demanda
- Blocks: Auditoria de calculos regulados, troubleshooting em producao
- Implementation complexity: Medio - implementar tabela `TB_AUDIT_LOG` + procedure de log padronizado

## Test Coverage Gaps

**Modulo comercial inteiro:**

- What's not tested: Pratacamente nada do PL/SQL tem testes automatizados
- Risk: Regressoes em area regulada [ANS] - sancao da ANS, glosa, prejuizo financeiro
- Priority: Alta
- Difficulty to test: Alta - requer setup de banco com massa, sem framework adotado
- Recomendacao: utPLSQL para testar packages criticos antes de qualquer modernizacao

---

_Este e um exemplo ilustrativo. Numeros e cenarios sao para fins de demonstracao
do framework - nao refletem o codigo real do SIGO._
