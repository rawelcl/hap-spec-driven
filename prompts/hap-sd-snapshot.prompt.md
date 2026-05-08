---
mode: 'agent'
description: 'Publicar snapshot da spec aprovada como anexo no work item ADO via MCP'
---

> **[HAP-SDD]** Hapvida Desenvolvimento Spec-Driven · [`SKILL.md`](../SKILL.md)

# Tarefa

Quando uma feature atinge estado `Approved` no work item ADO, publicar snapshot consolidado
de spec/design/tasks como anexo no work item via MCP do Azure DevOps.

# Pre-requisitos verificaveis

- [ ] `.vscode/mcp.json` configurado com servidor `ado` e dominios `core`, `work-items`,
      `repositories`
- [ ] Estado do work item ADO = `Approved` (validar antes de prosseguir)
- [ ] Spec.md aprovada via PR e merged em main do ADO Repos
- [ ] Frontmatter da spec.md tem `work_item_id` valido
- [ ] **Anonimizacao verificada** - sem PII de beneficiario

Se algum pre-requisito falhar -> ABORTAR e indicar ao TL o que falta.

# Passos

1. Ler frontmatter de `.specs/features/[feature]/spec.md` -> extrair `work_item_id`
2. Verificar via MCP que o work item esta em estado `Approved`
3. Ler arquivos da feature:
   - `spec.md` (sempre)
   - `design.md` (se existir)
   - `tasks.md` (se existir)
   - `context.md` (se existir)
4. Gerar snapshot consolidado em arquivo unico:
   - Path local: `WI-<id>-spec-v<N>.md`
   - Onde N e versao incremental: 1 se primeira publicacao, N+1 se ja existia anexo anterior
5. Verificar via MCP se ja existe attachment com nome `WI-<id>-spec-v<N>.md`:
   - Se existe -> incrementar N e regerar
6. Chamar tool MCP de attachment -> upload do arquivo
7. Chamar tool MCP `wit_update_work_item` -> adicionar relacao `AttachedFile` apontando ao anexo
8. Atualizar campos customizados se existirem:
   - `Spec Path` -> caminho no Git (`.specs/features/[feature]/spec.md`)
   - `Spec Version Atual` -> `vN`
9. Adicionar comentario no work item via MCP:

   ```
   Snapshot da spec publicado: WI-<id>-spec-v<N>.md
   Path no Git: .specs/features/[feature]/spec.md (commit <hash>)
   Versao: <N>
   Hash do conteudo: <sha256>
   Publicado por: <autor>
   Data: <YYYY-MM-DD HH:MM>
   ```

10. Reportar ao TL:

    ```
    Snapshot publicado com sucesso.

    Work item: WI-<id>
    Versao: vN
    Anexo: <link>
    Comentario adicionado: sim
    ```

# Guardrails

- `[GUARDRAIL]` Conteudo deve estar anonimizado antes de upload - se houver `[REVISAO]` em campo
  de PII, ABORTAR e pedir correcao
- `[GUARDRAIL]` Idempotencia - re-execucao na mesma versao da spec NAO duplica anexo (verificar
  hash antes)

# Tratamento de erros

- Falha de autenticacao -> instruir TL a re-autenticar Entra ID ou renovar PAT
- Falha de rede -> retry 3x com backoff
- Tamanho de anexo excedido -> tentar comprimir ou dividir spec
- Permissao insuficiente -> reportar e instruir TL a contactar plataforma ADO
