# ADR 007: Guardrail de acesso a producao - sempre WinCVS tag PRODUCAO

**Status:** Accepted
**Data:** 2026-05-06

## Contexto

LGPD, sigilo medico e regulacao ANS impoem que dados de beneficiario nunca devem ser acessados por
agente IA (LLM). Codigo PL/SQL produtivo no banco pode ter drift em relacao ao baseline (mudancas
hot-fix nao versionadas), mas a fonte da verdade legal e o repositorio versionado.

## Decisao

`[GUARDRAIL]` **NUNCA** usar MCP de banco de dados produtivo Oracle para qualquer finalidade.

`[GUARDRAIL]` Codigo PL/SQL e sempre lido da **WinCVS tag PRODUCAO**.

`[GUARDRAIL]` Drift detectado entre tag PRODUCAO e banco produtivo gera tarefa de correcao na tag
PRODUCAO **antes** de prosseguir com refatoracao.

## Justificativa

- **LGPD**: dados pessoais (PII) e sensiveis (medicos) protegidos
- **Sigilo medico**: legalmente obrigatorio
- **Auditoria**: tag PRODUCAO no CVS e imutavel e auditavel
- **Drift**: hot-fixes diretamente em producao sem checkin sao incidente, nao pratica - corrigir
  na origem

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
