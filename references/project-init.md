# Project Initialization

**Goal:** Criar a estrutura `.specs/project/` para um novo squad ou primeira adocao do framework.

**Trigger:** "Initialize project", "setup project", "start using framework"

**Outputs:**
- `.specs/project/PROJECT.md` (opcional)
- `.specs/project/ROADMAP.md` (opcional)
- `.specs/project/STATE.md` (**OBRIGATORIO**)

## Process

### 1. Conversa inicial com o TL

- Squad: nome, area de atuacao, tamanho
- Stack predominante: PL/SQL? Java? .NET? Mista?
- Codebase: existente (brownfield) ou novo (greenfield)?
- Numero de Features ativas no backlog

### 2. Decidir nivel de adocao

| Cenario | Arquivos a criar |
|---|---|
| Squad novo, sem repo Git ainda | Apenas STATE.md (PROJECT/ROADMAP gerenciados no ADO) |
| Squad com codigo PL/SQL legado | `.specs/codebase/` (brownfield mapping) + STATE.md + opcionalmente PROJECT.md |
| Squad com codigo Java/.NET | STATE.md + opcionalmente PROJECT.md, ROADMAP.md |
| Squad multi-stack | Brownfield mapping + STATE.md + PROJECT.md + ROADMAP.md |

### 3. Gerar arquivos

Use os templates:
- PROJECT.md: ver [`templates/`](../templates/) (se aplicavel)
- ROADMAP.md: ver [`references/roadmap.md`](roadmap.md) (se aplicavel)
- STATE.md: ver [`references/state-management.md`](state-management.md)

### 4. Configurar `.vscode/mcp.json`

Conforme [`mcp-integration.md`](mcp-integration.md).

### 5. Configurar `.github/copilot-instructions.md`

Apontar para SKILL.md do framework no repositorio do squad. Exemplo minimo:

```markdown
# Copilot Instructions

Este projeto usa o Framework Spec-Driven Hapvida v0.2.

Quando criar specs, designs, tasks ou implementar codigo, siga as instrucoes em
[SKILL.md do framework](https://github.com/rawelcl/hapvida-spec-driven/blob/main/SKILL.md).

Stack do squad: [PL/SQL | Java | .NET | mista]
Area de atuacao: [Comercial | Autorizacao | etc]
```

### 6. Onboarding rapido com o TL

- Walkthrough do `SKILL.md` do framework
- Configuracao do MCP do ADO
- Selecao da primeira feature alvo
- Apontamento das skills SIGO disponiveis

## Adaptacoes Hapvida

- STATE.md obrigatorio (ADR 009)
- PROJECT.md/ROADMAP.md frequentemente delegados ao ADO (Epic e Roadmap nativos)
- `.vscode/mcp.json` e parte do setup inicial
