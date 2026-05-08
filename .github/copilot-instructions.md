# Copilot Instructions

Este projeto usa o **Framework Spec-Driven Hapvida v0.2**.

## Regra fundamental

Quando criar specs, designs, tasks ou implementar codigo, siga as instrucoes em `SKILL.md` do
framework. O framework esta em https://github.com/rawelcl/hap-spec-driven.

## Comportamento esperado

1. **Antes de codar**: declare premissas, arquivos a tocar e criterio de sucesso
2. **Knowledge Verification Chain**: percorra Codebase -> Project docs -> Context7 -> Web -> Flag
   antes de afirmar tecnicamente
3. **Conventional Commits + WI prefix**: todo commit usa `WI-<id>: <type>(<scope>): <description>`
4. **Tokens textuais**: use `[ATENCAO]`, `[BLOQUEADO]`, `[REVISAO]`, `[ANS]`, `[REF: ...]`,
   `[ADR-AUSENTE]`, `[GUARDRAIL]`, etc - **sem emojis** em artefatos formais
5. **UTF-8 sem BOM** em todos os arquivos gerados

## Guardrails inegociaveis

- `[GUARDRAIL]` NUNCA acessar dados de beneficiario via MCP Oracle - codigo PL/SQL sempre via
  WinCVS tag PRODUCAO
- `[GUARDRAIL]` **Toda engenharia reversa de PL/SQL e Oracle Forms deve ser feita
  prioritariamente com base na ultima versao com TAG DE PRODUCAO no WinCVS.** Nao iniciar RE
  sem confirmar que o codigo em analise e a ultima tag de producao (`cvs log` ou tag explicita).
  Nenhuma outra fonte (banco produtivo, sandbox, branch) substitui WinCVS tag PRODUCAO como
  baseline de RE.
- `[GUARDRAIL]` MCP Oracle autorizado APENAS para dicionario read-only (`dba_*`, sem `dba_source`)
  pelas skills `engenharia-reversa-sigo` e `plsql-oracle-expert` ([ADR-007](../adr/007-guardrail-acesso-producao.md) emendada por [ADR-011](../adr/011-engenharia-reversa-como-baseline.md))
  Fonte de codigo e **exclusivamente WinCVS tag PRODUCAO**.
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
