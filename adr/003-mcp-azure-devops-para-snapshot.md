# ADR 003: Uso do Azure DevOps MCP Server (local) para snapshot de spec

**Status:** Accepted
**Data:** 2026-05-06

## Contexto

A ADR 002 decidiu que a spec e versionada em Git e snapshot anexado ao work item quando aprovada.
A pergunta e: como executar o anexo? Manualmente, via pipeline ADO, ou via automacao?

Opcoes:
- **Manual**: TL baixa spec.md, anexa pelo browser ADO
- **Pipeline ADO**: trigger no merge para main do `.specs/`, executa anexo
- **MCP Azure DevOps**: TL aciona via Copilot Agent Mode, MCP faz o anexo

## Decisao

Usar o **Azure DevOps MCP Server local** (`@azure-devops/mcp`, GA desde out/2025) acionado pelo TL
via prompt file no GitHub Copilot Agent Mode.

## Justificativa

- **Pipeline ADO descartado** porque a decisao de design do framework e "sem pipeline ADO no piloto"
  (validacao deve ser local + Copilot + humano)
- **Manual descartado** porque introduz friccao significativa, baixa probabilidade de TLs lembrarem
- **MCP escolhido** porque:
  - E client-side (acionado pelo TL, nao pipeline server-side)
  - Microsoft mantem oficialmente como GA
  - Integracao natural com VSCode + Copilot ja em uso
  - Permite logica adicional no prompt (versionamento, comentarios, atualizacao de campos)

## Alternativas consideradas

- Remote Azure DevOps MCP Server (preview): descartado para piloto pois ainda em preview;
  reavaliar quando GA
- Script local autonomo (Node.js / Python rodando REST API ADO): descartado por exigir manutencao
  paralela ao MCP que ja existe e e mantido pela Microsoft

## Consequencias

**Positivas:**
- Aproveita ferramental oficial Microsoft (GA, mantido)
- Acionavel via prompt file - workflow integrado no IDE
- Possibilita auditoria via comentarios automaticos no work item
- Pode ser estendido para outros usos (atualizar campos, criar comentarios estruturados)

**Negativas:**
- Dependencia de Node.js 20+ na maquina do dev
- Requer autenticacao (Entra ID interativo na primeira vez, ou PAT)
- Politica corporativa pode exigir homologacao do MCP server

## Implementacao

- Configuracao em `.vscode/mcp.json` do squad
- Dominios habilitados: `core`, `work-items`, `repositories`, `wiki`
- Prompt file: `prompts/spec-publish-snapshot.prompt.md`
- Documentacao: `references/mcp-integration.md`

## Guardrail

`[GUARDRAIL]` MCP do Azure DevOps autorizado **apenas para metadados** (work items, attachments,
repos, wiki). **Nao** se aplica a banco produtivo Oracle, que continua proibido para qualquer
agente IA (ver ADR 007).
