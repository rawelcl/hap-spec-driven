# Copilot Instructions

Este projeto usa o **Framework Spec-Driven Hapvida v0.5.2**.

## Regra fundamental

Quando criar specs, designs, tasks ou implementar codigo, siga as instrucoes em `SKILL.md` do
framework. O framework esta em https://github.com/rawelcl/hap-spec-driven (v0.5.2).

## Comportamento esperado

1. **Antes de codar**: declare premissas, arquivos a tocar e criterio de sucesso
2. **Knowledge Verification Chain**: percorra Codebase -> Project docs -> Context7 -> Web -> Flag
   antes de afirmar tecnicamente
3. **Conventional Commits + WI prefix**: todo commit usa `WI-<id>: <type>(<scope>): <description>`
4. **Tokens textuais**: use `[ATENCAO]`, `[BLOQUEADO]`, `[REVISAO]`, `[ANS]`, `[REF: ...]`,
   `[ADR-AUSENTE]`, `[GUARDRAIL]`, etc - **sem emojis** em artefatos formais
5. **UTF-8 sem BOM** em todos os arquivos gerados

## Guardrails inegociaveis

- `[GUARDRAIL]` Codigo PL/SQL e Oracle Forms e sempre obtido via tool
  `tools/cvs-fetch-producao/cvs-fetch-producao.ps1` — o agente executa o tool diretamente,
  nao instrui o TL a buscar manualmente. `dba_source` proibido como fonte de codigo.
  Se o tool retornar `[BLOQUEADO]`, parar e notificar o TL sem fallback.
  ([ADR-007](../adr/007-guardrail-acesso-producao.md) emendada por [ADR-011](../adr/011-engenharia-reversa-como-baseline.md))
- `[GUARDRAIL]` MCP Oracle autorizado para: (a) dicionario read-only (`dba_*`, sem `dba_source`)
  pelas skills `engenharia-reversa-sigo` e `plsql-oracle-expert`; (b) SELECT read-only em tabelas
  de negocio para evidencia/rastreio/historico/debug — PII de beneficiario PF (CPF, nome,
  matricula, dados de saude) deve ser mascarado na saida antes de incluir em qualquer artefato.
  DML/DDL proibido. ([ADR-007](../adr/007-guardrail-acesso-producao.md) Excecao 2)
- `[GUARDRAIL]` MCP do Azure DevOps autorizado para metadados (work items, attachments, repos)
- `[GUARDRAIL]` Anonimizacao obrigatoria de PII de beneficiario pessoa fisica (CPF, nome,
  matricula, dados de saude). Dados comerciais (razao social, numero de contrato, CNPJ de empresa
  contratante) nao precisam ser anonimizados.
- `[GUARDRAIL]` Toque em area regulada exige `[ANS]` + citacao de norma
- `[GUARDRAIL]` ADR aplicavel ausente -> `[ADR-AUSENTE]` + bloquear ate proposta de ADR

## Skills SIGO disponiveis

Internas ao framework (em `skills/`):

- `engenharia-reversa-sigo` - engenharia reversa PL/SQL com persistencia em
  `.specs/reverse-engineering/` (ver [ADR-011](../adr/011-engenharia-reversa-como-baseline.md))
- `plsql-oracle-expert` - code review PL/SQL com regras ANS

Externas (quando disponiveis no ambiente):

- `sigo-refatoracao-workflow` - fluxo refatoracao

Quando relevante, **prefira skills SIGO** sobre solucoes ad-hoc.
