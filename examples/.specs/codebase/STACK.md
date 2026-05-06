# Tech Stack - Modulo Comercial SIGO (exemplo)

**Analyzed:** 2026-05-01
**Baseline:** WinCVS tag `PRODUCAO`
**Escopo:** packages PL/SQL do modulo comercial (cotacao, proposta, implantacao)

---

## Core

- Framework: PL/SQL Oracle 19c
- Linguagem principal: PL/SQL (~85%) + SQL puro (~15%)
- Banco: Oracle Database 19c Enterprise
- Ferramenta de versionamento: WinCVS (legado, sem migracao planejada)
- Build/Deploy: deploy manual via DBA (sem CI/CD para PL/SQL)

## Packages criticos (modulo comercial)

| Package | Tamanho aprox | Criticidade | Observacao |
|---|---|---|---|
| `PKG_PROPOSTA` | ~12.000 linhas | Alta | God package, candidato prioritario [REVISAO] |
| `PKG_BENEFICIARIO` | ~8.500 linhas | Alta | Toca SIB, regulado [ANS] |
| `PKG_CARENCIA` | ~3.200 linhas | Alta | Lei 9.656/98 art. 12 [ANS] |
| `PKG_CPT` | ~2.100 linhas | Alta | RN ANS 438/2018 [ANS] |
| `PKG_REAJUSTE` | ~5.800 linhas | Critica | Calculo regulado [ANS] |
| `PKG_CALCULO_FINANCEIRO` | ~7.400 linhas | Critica | Mensalidade, coparticipacao |
| `PKG_RELATORIOS` | ~9.100 linhas | Media | Apoio operacional |

**Tamanho total do modulo:** ~48.000 linhas de PL/SQL

## Tipos proprietarios identificados

- `TYP_PROPOSTA_REC` - record customizado para proposta
- `TYP_BENEFICIARIO_TAB` - table de beneficiarios
- `TYP_FAIXA_ETARIA_OBJ` - object com regra de faixa

[MIGRACAO] Tipos proprietarios precisam ser mapeados para classes Java/C# durante
modernizacao - mapeamento vive em `glossario/legado-mapeamento.md`.

## Recursos Oracle utilizados intensivamente

- `BULK COLLECT` + `FORALL` (performance)
- `CONNECT BY` (hierarquia de produtos)
- `MERGE` (operacoes de upsert em tabelas grandes)
- `DBMS_OUTPUT` (logs - **nao usar em modernizacao**)
- `UTL_FILE` (geracao de arquivos para SIB)
- `DBMS_SCHEDULER` (jobs noturnos de fechamento)
- Pragma `AUTONOMOUS_TRANSACTION` em logs e auditoria

[MIGRACAO] Cada um destes precisa contraparte definida na arquitetura alvo
(streaming, mensageria, batch jobs, etc).

## Dependencias entre packages

```
PKG_PROPOSTA
  -> PKG_BENEFICIARIO
  -> PKG_CARENCIA
  -> PKG_CPT
  -> PKG_CALCULO_FINANCEIRO

PKG_REAJUSTE (independente, scheduled)

PKG_CALCULO_FINANCEIRO
  -> PKG_FAIXA_ETARIA (utilitario, pequeno)
  -> PKG_TABELA_PRECO
```

## Externals identificados

- SIB (Sistema de Informacoes de Beneficiarios - ANS): exportacao via UTL_FILE
- ServiceNow (incidents): nao integrado direto no PL/SQL
- Lecom (BPM): integracao via tabelas de interface

## Observacoes para modernizacao

- Sem testes automatizados para PL/SQL [REVISAO]
- Cobertura de log e baixa (DBMS_OUTPUT majoritariamente, nao persistido)
- `COMMIT`/`ROLLBACK` espalhados em sub-procedures (anti-padrao)
- Acoplamento alto entre packages dificulta strangler fig isolado por package

---

_Este e um exemplo ilustrativo. Numero de linhas e nomes sao aproximados para fins
de demonstracao do framework - nao refletem o codigo real do SIGO._
