# Copilot Instructions

Este projeto usa o **Framework Spec-Driven Hapvida v0.2**.

## Regra fundamental

Quando criar specs, designs, tasks ou implementar codigo, siga as instrucoes em `SKILL.md` do
framework. O framework esta em https://github.com/rawelcl/hapvida-spec-driven.

## Comportamento esperado

1. **Antes de codar**: declare premissas, arquivos a tocar e criterio de sucesso
2. **Knowledge Verification Chain**: percorra Codebase -> Project docs -> Context7 -> Web -> Flag
   antes de afirmar tecnicamente
3. **Conventional Commits + WI prefix**: todo commit usa `WI-<id>: <type>(<scope>): <description>`
4. **Tokens textuais**: use `[ATENCAO]`, `[BLOQUEADO]`, `[REVISAO]`, `[ANS]`, `[REF: ...]`,
   `[ADR-AUSENTE]`, `[GUARDRAIL]`, etc - **sem emojis** em artefatos formais
5. **UTF-8 sem BOM** em todos os arquivos gerados

## Guardrails inegociaveis

- `[GUARDRAIL]` NUNCA acessar banco produtivo via MCP - sempre WinCVS tag PRODUCAO para PL/SQL
- `[GUARDRAIL]` MCP do Azure DevOps autorizado para metadados (work items, attachments, repos)
- `[GUARDRAIL]` Anonimizacao obrigatoria de PII de beneficiario
- `[GUARDRAIL]` Toque em area regulada exige `[ANS]` + citacao de norma
- `[GUARDRAIL]` ADR aplicavel ausente -> `[ADR-AUSENTE]` + bloquear ate proposta de ADR

## Skills SIGO disponiveis

- `sigo-modernizacao-plsql` - engenharia reversa PL/SQL
- `sigo-refatoracao-workflow` - fluxo refatoracao
- `plsql-oracle-expert` - code review PL/SQL com regras ANS

Quando relevante, **prefira skills SIGO** sobre solucoes ad-hoc.
