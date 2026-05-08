---
mode: 'agent'
description: 'Inicializar a estrutura .specs/ + .vscode/ + .github/ no repo do squad'
---

Voce e o assistente do Framework Spec-Driven Hapvida v0.2.

# Tarefa

Criar o scaffold padrao de adocao do framework no repositorio atual do squad,
preenchendo apenas o que e responsabilidade do squad. NAO copie artefatos do
framework (SKILL.md, prompts, templates, ADRs); esses ficam no repo central
[hap-spec-driven](https://github.com/rawelcl/hap-spec-driven).

Referencias canonicas:

- [references/project-init.md](../references/project-init.md)
- [references/state-management.md](../references/state-management.md)
- [references/mcp-integration.md](../references/mcp-integration.md)
- [ADR-009](../adr/009-state-md-obrigatorio-projeto-individual.md) - STATE.md obrigatorio

# Input esperado (peca ao TL antes de criar arquivos)

1. **Squad / projeto** - nome curto
2. **Stack predominante** - PLSQL | Java | DotNet | Mista
3. **Area de atuacao** - Comercial, Autorizacao, etc
4. **AdoOrg** - slug da organizacao no Azure DevOps (default `hapvidalabs`, URL `https://dev.azure.com/hapvidalabs/`)
5. **Brownfield?** - existe codigo legado a mapear? (sim/nao)
6. **Criar PROJECT.md / ROADMAP.md locais?** - geralmente nao (delegar ao ADO)

# Passos

1. **Verificar pre-condicoes**
   - Estamos na raiz de um repositorio Git? Se nao, alerte e pare.
   - `.specs/` ja existe? Se sim, confirme com o TL antes de sobrescrever.

2. **Criar diretorios base**
   - `.specs/project/`, `.specs/features/`, `.vscode/`, `.github/`

3. **Criar `.specs/project/STATE.md`** (OBRIGATORIO)
   - Use o esqueleto de [references/state-management.md](../references/state-management.md)
   - Preencha: nome do squad, `Last Updated` (data atual), `Current Work: -`
   - Em `Preferences`: stack, area de atuacao, `MCP do ADO configurado: yes`,
     `Skills SIGO availability` conforme contexto

4. **Criar `.vscode/mcp.json`** (default `AdoOrg = hapvidalabs` → URL `https://dev.azure.com/hapvidalabs/`)

   ```json
   {
     "servers": {
       "azure-devops": {
         "command": "npx",
         "args": ["-y", "@azure-devops/mcp", "<AdoOrg>"]
       }
     }
   }
   ```

5. **Criar `.github/copilot-instructions.md`**
   - Aponte para SKILL.md do framework no repo central (URL absoluta)
   - Inclua contexto do squad: nome, stack, area
   - Liste guardrails inegociaveis (PII, ANS, ADR-007, ADR-AUSENTE)
   - Liste convencao de commits (WI-prefix + Conventional Commits)
   - Reforce UTF-8 sem BOM e ausencia de emojis em artefatos formais

6. **Opcionais (so se o TL pediu)**
   - `.specs/project/PROJECT.md` - esqueleto Vision/For/Solves/Goals/Stack/Scope
   - `.specs/project/ROADMAP.md` - Now/Next/Later

7. **Brownfield (se aplicavel)**
   - Crie esqueleto vazio de `.specs/codebase/` e `.specs/codebase/knowledge-base/`
   - Avise: "rode `Map codebase` para preencher os 7 docs"
   - Se Stack = PLSQL: crie `.specs/reverse-engineering/` e avise sobre
     [`baseline-reverse-engineering`](baseline-reverse-engineering.prompt.md)
     antes de specs de refatoracao ([ADR-011](../adr/011-engenharia-reversa-como-baseline.md))

8. **Resumo final ao TL**
   - Liste arquivos criados
   - Proximos passos: revisar `copilot-instructions.md`, autenticar MCP do ADO,
     commit inicial `WI-XXXX: chore(spec-driven): scaffold inicial`,
     primeira feature via prompt `spec-from-workitem`

# Guardrails

- `[GUARDRAIL]` UTF-8 sem BOM em todos os arquivos gerados
- `[GUARDRAIL]` Sem emojis em artefatos formais
- `[GUARDRAIL]` NAO copiar SKILL.md/prompts/templates/ADRs do framework para o repo do squad
- `[GUARDRAIL]` Se ja existir `.specs/` populado, confirmar antes de sobrescrever

# Output

Arquivos criados (`STATE.md`, `mcp.json`, `copilot-instructions.md` + opcionais),
mais resumo com proximos passos para o TL.
