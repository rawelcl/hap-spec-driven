# Integracao MCP Azure DevOps

**Como o framework usa o MCP Server oficial Microsoft do Azure DevOps para integrar specs ao
work item.**

## Contexto

A decisao Hapvida e que **a spec do framework e versionada em ADO Repos (Git)** e quando atinge
estado `Approved` no work item, **um snapshot e anexado ao work item via MCP** acionado pelo
TL no GitHub Copilot Agent Mode.

Ver:
- [`adr/002-spec-versionada-em-git-snapshot-no-workitem.md`](../adr/002-spec-versionada-em-git-snapshot-no-workitem.md)
- [`adr/003-mcp-azure-devops-para-snapshot.md`](../adr/003-mcp-azure-devops-para-snapshot.md)

## Estado atual do MCP Server

### Local Azure DevOps MCP Server (recomendado para piloto)

- Pacote npm: `@azure-devops/mcp`
- Status: **GA desde outubro 2025**
- Roda na maquina do dev, configurado via `.vscode/mcp.json`
- Open source: https://github.com/microsoft/azure-devops-mcp
- Compatibilidade: GitHub Copilot em Visual Studio e Visual Studio Code

### Remote Azure DevOps MCP Server (avaliacao futura)

- URL: `https://mcp.dev.azure.com/{organization}`
- Status: Public Preview (anunciado marco 2026)
- Streamable HTTP, autenticacao Microsoft Entra
- Vantagem: zero setup local
- Restricao atual: so VS Code e Visual Studio (Claude Desktop, ChatGPT ainda nao oficialmente)

**Decisao framework:** comecar com **Local MCP** no piloto. Avaliar migracao para Remote quando
GA.

## Configuracao do Local MCP

### Arquivo `.vscode/mcp.json` no repositorio do squad

```json
{
  "inputs": [
    {
      "id": "ado_org",
      "type": "promptString",
      "description": "Azure DevOps organization name (ex: 'hapvidalabs')"
    }
  ],
  "servers": {
    "ado": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "-y",
        "@azure-devops/mcp",
        "${input:ado_org}",
        "-d",
        "core",
        "work-items",
        "repositories",
        "wiki"
      ]
    }
  }
}
```

**Dominios ativados (-d):**

- `core` - sempre incluido (projects, teams)
- `work-items` - **principal** - read/update/comment/attachment em work items
- `repositories` - operar sobre `.specs/` versionado em ADO Repos
- `wiki` - acessar a Wiki Arquitetura-Referencia para RAG

**Dominios disponiveis mas nao habilitados no piloto:**

- `search`, `test-plans`, `pipelines`, `advanced-security`

### Autenticacao

Na primeira invocacao, o browser abrira pedindo login com conta Microsoft Entra. Use as credenciais
corporativas Hapvida.

Alternativa: PAT (Personal Access Token) com scopes:
- Work Items: Read & Write
- Code: Read
- Wiki: Read

## Fluxo do snapshot ao work item

### Passo a passo

1. **TL elabora spec localmente** em `.specs/features/[feature]/spec.md` durante estado
   `In Refinement`

2. **TL abre PR de spec** no ADO Repos (revisao de spec via PR como qualquer codigo)

3. **PR aprovado e merged** para main

4. **TL transita work item para `Approved`** no ADO (gate manual de revisao + DoR atendido)

5. **TL aciona prompt file** `/spec-publish-snapshot` no Copilot Chat (Agent Mode)

6. **Copilot Agent executa:**
   a. Le frontmatter de `spec.md` -> extrai `work_item_id`
   b. Le `spec.md`, `design.md` (se existir), `tasks.md` (se existir)
   c. Gera snapshot consolidado: `WI-<id>-spec-v<N>.md`
   d. Chama tool MCP de attachment -> faz upload do arquivo
   e. Chama tool MCP de update work item -> adiciona link `AttachedFile` apontando para o anexo
   f. Atualiza campos customizados se existirem (`Spec Path`, `Spec Version Atual`)
   g. Adiciona comentario no work item registrando publicacao

7. **TL valida** que o anexo esta correto no work item ADO

### Convencao de versionamento de anexos

| Versao | Quando |
|---|---|
| `v1` | Primeira aprovacao |
| `v2` | Mudanca apos aprovacao (ex: change request, gap detectado em homologacao) |
| `vN` | Versoes subsequentes |

Campo customizado opcional `Spec Version Atual` aponta para vN ativa. Versoes anteriores ficam
como historico no work item.

## Tools MCP relevantes

Da documentacao oficial do `@azure-devops/mcp`, as tools mais relevantes para o framework:

### Work Items

- `wit_get_work_items_by_id` - obter work item por ID (extrair frontmatter alvo)
- `wit_update_work_item` - atualizar campos do work item
- `wit_create_attachment` (ou tool grouped equivalent) - criar attachment
- `wit_my_work_items` - listar work items do usuario atual

### Repositories

- `repo_create_branch` - criar branch para spec em elaboracao (opcional)
- `repo_search_commits` - rastrear commits que referenciam um work item

### Wiki

- Tools de leitura para acessar Wiki Arquitetura-Referencia como RAG

## Guardrails

- **`[GUARDRAIL]`** MCP do Azure DevOps esta autorizado para metadados (work items, attachments,
  repos, wiki). **NAO** para acesso a dados de beneficiario.
- **`[GUARDRAIL]`** O TL aciona o snapshot manualmente - **nao e automatico server-side**. Coerente
  com a decisao "sem pipeline ADO no piloto" (ADR 008 contexto).
- **`[GUARDRAIL]`** Conteudo da spec antes do upload **deve estar anonimizado** - nenhum dado de
  beneficiario real.
- **`[GUARDRAIL]`** Cada snapshot gera comentario no work item com hash do conteudo - rastreabilidade
  e auditoria.

## Cuidados praticos

1. **Permissoes**: PAT/Entra com scope minimo necessario (Work Items Read/Write)
2. **Aprovacao corporativa**: instalacao local nao exige aprovacao server-side, mas politicas
   corporativas podem exigir homologacao do MCP server como ferramenta aprovada
3. **Idempotencia**: re-aplicar `/spec-publish-snapshot` na mesma versao deve detectar e nao
   duplicar - prompt file implementa essa logica
4. **Rate limits**: `npx @azure-devops/mcp` respeita rate limits da REST API do ADO. Em piloto
   com ~30 TLs uso esporadico, sem problema esperado.
5. **Modo read-only de fallback**: pode-se usar MCP em modo `X-MCP-Readonly` para devs/QAs da
   Onda 2 que so consomem (sem permissao de upload)

## Troubleshooting

### "This user does not have the permissions"

Verifique licenca do Azure DevOps. Stakeholders tem permissoes limitadas. Para uso pleno do
framework, licenca **Basic** ou superior.

### MCP nao inicia / timeout

- Verifique Node.js 20+ instalado
- Verifique conectividade com `dev.azure.com`
- Reinicie VSCode

### Falha ao anexar arquivo

- Tamanho do arquivo: anexos ADO tem limite (verificar politica corporativa)
- Encoding: garantir UTF-8 sem BOM
- Permissoes do PAT: scope `Work Items: Read & Write`

## Migracao futura para Remote MCP

Quando Remote MCP atingir GA:

1. Atualizar `.vscode/mcp.json` para usar URL remota
2. Migrar autenticacao para Entra ID puro (sem PAT)
3. Desinstalar `npx @azure-devops/mcp` local

A interface dos tools deve ser compativel - codigo dos prompt files do framework nao deve mudar.
