# ADR 002: Spec versionada em Git como fonte da verdade, snapshot anexado ao work item

**Status:** Accepted
**Data:** 2026-05-06

## Contexto

A spec do framework precisa ser versionada (historico, diff, PR review) e tambem precisa estar
acessivel a stakeholders nao-tecnicos no work item ADO. Tres opcoes foram consideradas:

- **Opcao A**: spec direto no campo Description do work item (rich text ADO)
- **Opcao B**: spec em `.specs/` no Git (ADO Repos), com snapshot anexado ao work item quando aprovada
- **Opcao C**: spec na wiki Arquitetura-Referencia, link no work item

## Decisao

**Opcao B**: spec versionada em ADO Repos (Git) como fonte da verdade. Snapshot anexado ao work
item via MCP do Azure DevOps quando estado vai para `Approved`.

## Justificativa

- **Versionamento e diff**: Git e o local natural; rich text do ADO nao oferece bom diff
- **Review via PR**: spec passa pelo mesmo fluxo de review que codigo
- **Single source of truth**: nao ha duplicacao - work item tem snapshot somente, ADO Repos tem fonte
- **Auditoria regulatoria**: snapshot no work item satisfaz auditoria sem expor Git para nao-tecnicos
- **Historico**: versoes anteriores ficam como anexos (`v1`, `v2`, `vN`) no work item, com versao
  ativa em campo customizado

## Consequencias

**Positivas:**
- Diff e history first-class via Git
- Review de spec via PR (fluxo familiar)
- Auditoria preservada
- Historico de versoes acessivel

**Negativas:**
- TL precisa lembrar de acionar snapshot manualmente (mitigado por prompt file)
- Drift potencial entre spec no Git e snapshot anexado se TL nao acionar snapshot apos mudanca

## Implementacao

- Spec em `.specs/features/[feature]/spec.md` no ADO Repos do squad
- Quando estado vai para `Approved`, TL aciona prompt file `/spec-publish-snapshot`
- Snapshot consolidado anexado ao work item via MCP (ver ADR 003)
- Campo customizado `Spec Path` no work item aponta para o caminho no Git
- Campo customizado opcional `Spec Version Atual` aponta para vN ativa
