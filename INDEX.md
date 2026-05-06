# INDEX - Navegacao Rapida

Mapa para encontrar rapidamente o arquivo certo no framework.

## Comecar aqui

1. **[README.md](README.md)** - Overview, conceitos-chave, comandos
2. **[SKILL.md](SKILL.md)** - Ponto de entrada para o GitHub Copilot Agent Mode
3. **[PROJECT.md](PROJECT.md)** - Vision, goals, scope do framework
4. **[ROADMAP.md](ROADMAP.md)** - Versao atual e proximas

## Por situacao

### "Vou criar uma spec nova"

1. Identifique tipo da demanda (Demand Type x Value Area)
2. Escolha o template em `templates/`:
   - Project + Business -> [`spec-project-business.md`](templates/spec-project-business.md)
   - Improvement + Business -> [`spec-improvement-business.md`](templates/spec-improvement-business.md)
   - Improvement + Tunning -> [`spec-improvement-tunning.md`](templates/spec-improvement-tunning.md) (refatoracao PL/SQL)
   - Maintenance + Business -> [`spec-maintenance-business.md`](templates/spec-maintenance-business.md)
   - Maintenance + Tunning -> [`spec-maintenance-tunning.md`](templates/spec-maintenance-tunning.md)
   - Incident criticidade alta/media -> [`spec-incident-fast-track.md`](templates/spec-incident-fast-track.md)
3. Use o prompt file: [`prompts/spec-from-workitem.prompt.md`](prompts/spec-from-workitem.prompt.md)
4. Valide com: [`prompts/spec-validator.prompt.md`](prompts/spec-validator.prompt.md)
5. Quando aprovada, publique com: [`prompts/spec-publish-snapshot.prompt.md`](prompts/spec-publish-snapshot.prompt.md)

### "Vou refatorar uma procedure PL/SQL legada"

1. Use o template: [`templates/spec-improvement-tunning.md`](templates/spec-improvement-tunning.md)
2. Use o prompt file especifico: [`prompts/spec-from-baseline-plsql.prompt.md`](prompts/spec-from-baseline-plsql.prompt.md)
3. Aproveite skills SIGO existentes: `sigo-modernizacao-plsql`, `sigo-refatoracao-workflow`, `plsql-oracle-expert`
4. Veja exemplo end-to-end: [`examples/.specs/features/exemplo-cotacao-pme/`](examples/.specs/features/exemplo-cotacao-pme/)

### "Vou desenhar arquitetura para uma feature"

1. Pre-requisito: spec aprovada
2. Use: [`prompts/design-from-spec.prompt.md`](prompts/design-from-spec.prompt.md)
3. Template: [`templates/design-template.md`](templates/design-template.md)
4. Referencia: [`references/design.md`](references/design.md)

### "Vou quebrar em tasks"

1. Pre-requisito: design aprovado
2. Use: [`prompts/tasks-from-design.prompt.md`](prompts/tasks-from-design.prompt.md)
3. Template: [`templates/tasks-template.md`](templates/tasks-template.md)
4. Referencia: [`references/tasks.md`](references/tasks.md)

### "Vou implementar uma task"

1. Referencia obrigatoria: [`references/coding-principles.md`](references/coding-principles.md)
2. Fluxo: [`references/implement.md`](references/implement.md)
3. Convencao de commits: [`adr/005-conventional-commits-com-prefixo-wi.md`](adr/005-conventional-commits-com-prefixo-wi.md)

### "Vou validar uma feature pronta"

1. Fluxo de validacao adaptado Hapvida: [`references/validate.md`](references/validate.md)
2. Cadeia: Resolved -> Homologation -> Ready for Production -> GMUD aprovada -> Closed

### "Preciso de uma decisao arquitetural"

1. Verifique se ja existe ADR na **Wiki Arquitetura-Referencia** (96+ ADRs corporativas)
2. Se nao existir e for arquitetural: marque `[ADR-AUSENTE]` e proponha ADR
3. Se for decisao do framework em si: use [`templates/adr-template.md`](templates/adr-template.md)
4. Distincao detalhada: [`.github/instructions/adr.instructions.md`](.github/instructions/adr.instructions.md)

### "Configurar MCP do Azure DevOps"

1. Guia completo: [`references/mcp-integration.md`](references/mcp-integration.md)
2. Decisao registrada: [`adr/003-mcp-azure-devops-para-snapshot.md`](adr/003-mcp-azure-devops-para-snapshot.md)

### "Conheco o TLC e quero entender o que mudou"

1. Lista completa de adaptacoes: [`CHANGELOG.md`](CHANGELOG.md)
2. ADRs especificas das adaptacoes: pasta [`adr/`](adr/)

## Por papel

### Tech Lead (Onda 1)

Leitura obrigatoria:
- [README.md](README.md), [SKILL.md](SKILL.md)
- [`.github/copilot-instructions.md`](.github/copilot-instructions.md)
- [`references/specify.md`](references/specify.md)
- [`references/coding-principles.md`](references/coding-principles.md)
- Templates da matriz Demand Type x Value Area

Configuracao no projeto:
- Copiar `.github/copilot-instructions.md` para o repo do squad
- Configurar `.vscode/mcp.json` conforme [`references/mcp-integration.md`](references/mcp-integration.md)

### Dev / QA (Onda 2)

Leitura obrigatoria:
- [README.md](README.md) - overview
- [`.github/copilot-instructions.md`](.github/copilot-instructions.md) - regras de comportamento
- [`references/coding-principles.md`](references/coding-principles.md) - principios de codigo
- [`references/implement.md`](references/implement.md) - fluxo de implementacao
- [`references/knowledge-verification.md`](references/knowledge-verification.md) - cadeia de verificacao

### PO / Compliance

Leitura recomendada:
- [PROJECT.md](PROJECT.md) - vision do framework
- Templates de spec relevantes
- Exemplos em [`examples/`](examples/)
- Glossario regulatorio: [`glossario/regulatorio-ans.md`](glossario/regulatorio-ans.md)

## Navegacao rapida por arquivos

| Categoria | Pasta | Conteudo |
|---|---|---|
| Raiz | `/` | README, SKILL, PROJECT, ROADMAP, CHANGELOG, LICENSE |
| Referencias TLC adaptadas | `references/` | 17 docs do fluxo (specify, design, tasks, implement, validate, etc) |
| Templates de spec | `templates/` | 10 templates por tipo de demanda |
| Prompts Copilot | `prompts/` | 7 prompt files acionaveis em Agent Mode |
| Glossario | `glossario/` | Termos canonicos + mapeamento legado |
| ADRs do framework | `adr/` | 9 decisoes arquiteturais do framework |
| Exemplos | `examples/.specs/` | Projeto, codebase, feature end-to-end |
| Config Copilot | `.github/` | copilot-instructions + instructions especificas |

---

**Versao:** 0.2.0 (piloto Onda 1 - area Comercial)
**Repositorio:** https://github.com/rawelcl/hapvida-spec-driven
**Base:** TLC Spec-Driven 2.0.0 (CC-BY-4.0)
