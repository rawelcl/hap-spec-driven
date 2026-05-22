# ADR 007: Guardrail de acesso a producao - sempre WinCVS tag PRODUCAO

**Status:** Accepted
**Data:** 2026-05-06
**Emendas:** 2026-05-22 (Excecao 1 atualizada — tool cvs-fetch-producao; Excecao 2 — SELECT read-only em dados de negocio)

## Contexto

LGPD, sigilo medico e regulacao ANS impoem que dados de beneficiario nunca devem ser acessados por
agente IA (LLM). Codigo PL/SQL produtivo no banco pode ter drift em relacao ao baseline (mudancas
hot-fix nao versionadas), mas a fonte da verdade legal e o repositorio versionado.

## Decisao

`[GUARDRAIL]` **NUNCA** usar MCP de banco de dados produtivo Oracle para acessar **dados de
beneficiario** ou para qualquer DML/DDL.

`[GUARDRAIL]` Codigo PL/SQL e sempre obtido via **tool `cvs-fetch-producao`** que busca a tag
`PRODUCAO_*` mais recente no WinCVS. O agente executa o tool diretamente — nao instrui o TL
a buscar manualmente.

`[GUARDRAIL]` Drift detectado entre tag PRODUCAO e banco produtivo gera tarefa de correcao na tag
PRODUCAO **antes** de prosseguir com refatoracao.

### Excecao 1 — Dicionario Oracle read-only (emendada por [ADR-011](011-engenharia-reversa-como-baseline.md))

Leitura **read-only do dicionario Oracle** via MCP e autorizada para fins de engenharia reversa
e code review:

- `dba_objects`, `dba_dependencies`, `dba_constraints`, `dba_indexes`, `dba_scheduler_jobs`,
  `plan_table` - metadados sem PII

`[GUARDRAIL]` Fonte de codigo e **exclusivamente o WinCVS tag PRODUCAO** via tool
`tools/cvs-fetch-producao/cvs-fetch-producao.ps1`. O `dba_source` esta explicitamente proibido
como fonte de codigo. Se o tool retornar `[BLOQUEADO]`, parar e notificar o TL — sem fallback.

### Excecao 2 — SELECT read-only em dados de negocio (emendada em 2026-05-22)

SELECT read-only em tabelas de negocio de producao via MCP Oracle e autorizado quando a
finalidade for: coleta de evidencia, rastreio, historico ou debug.

Condicoes obrigatorias:
- Apenas `SELECT` — proibido `DML`, `DDL`, `EXECUTE`, `DBMS_SCHEDULER`
- PII de beneficiario pessoa fisica (CPF, nome, matricula, dados de saude) deve ser
  **mascarado na saida antes de incluir em qualquer artefato** (spec, tasks, RE, chat).
  Formato: CPF -> `***.***.***/***-**`, nome -> `[ANONIMIZADO]`, matricula -> `[ANONIMIZADO]`
- Dados comerciais (razao social, CNPJ de empresa contratante, nu_controle, numero de contrato)
  nao precisam de mascara
- Resultado de queries com PII anonimizado deve ser registrado como evidencia versionada em
  `.specs/features/[feature]/evidencias/` quando usado como insumo de spec ou tasks

`[GUARDRAIL]` Permanecem proibidos: qualquer DML/DDL, acesso sem anonimizacao a PII de
beneficiario pessoa fisica.

## Justificativa

- **LGPD**: dados pessoais (PII) e sensiveis (medicos) protegidos
- **Sigilo medico**: legalmente obrigatorio
- **Auditoria**: tag PRODUCAO no CVS e imutavel e auditavel
- **Drift**: hot-fixes diretamente em producao sem checkin sao incidente, nao pratica - corrigir
  na origem
- **Excecao 2**: queries de volumetria e rastreio em dados comerciais sao necessarias para
  evidenciar impacto de incidents e validar corretude de scripts de reprocessamento

## Escopo

Este guardrail **se aplica a**:
- MCP que conecte a banco Oracle produtivo
- Qualquer ferramenta de IA que acesse dados de beneficiario reais
- Massa de teste com PII real (proibida)

Este guardrail **NAO se aplica a**:
- MCP do Azure DevOps (autorizado para metadados, ver ADR 003)
- Banco de teste/HML com massa anonimizada
- Skills SIGO operando sobre baseline da tag PRODUCAO
- Wiki Arquitetura-Referencia
- Leitura read-only do dicionario Oracle via MCP por skills `engenharia-reversa-sigo` e
  `plsql-oracle-expert` (ver Excecao 1)
- SELECT read-only em dados de negocio para evidencia/rastreio/debug com anonimizacao PII
  obrigatoria (ver Excecao 2)
