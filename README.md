# Framework Spec-Driven Hapvida

**Versao:** 0.3
**Status:** Pronto para piloto
**Base:** Adaptacao do framework [TLC Spec-Driven](https://github.com/tech-leads-club) (Tech Lead's Club)
**Repositorio:** https://github.com/rawelcl/hap-spec-driven

> Plan and implement projects with precision. Granular tasks. Clear dependencies. Right tools. Adaptado para o ecossistema Hapvida (Azure DevOps, WinCVS, ANS, GitHub Copilot com Claude).

## O que e

Framework adaptativo de desenvolvimento spec-driven que padroniza o fluxo
**Spec → Plano → Tarefas → Implementacao → Validacao** com a spec como
artefato de primeira classe, ancorada no work item Azure DevOps existente.

### As 4 fases adaptativas

```
+----------+    +----------+   +---------+   +---------+
| SPECIFY  | -> |  DESIGN  | ->|  TASKS  | ->| EXECUTE |
+----------+    +----------+   +---------+   +---------+
  obrigatorio    opcional*     obrigatorio**  obrigatorio

*  Auto-skip baseado em complexidade
** Sempre obrigatorio + sync automatico ao ADO ([REF: ADR-010](adr/010-tasks-obrigatorias-com-sync-ado.md))
```

| Escopo | Specify | Design | Tasks | Execute |
|---|---|---|---|---|
| **Pequeno** (≤3 arquivos) | Spec inline | Skip | Tasks minimas + sync ADO | Sim |
| **Medio** (feature clara) | Spec completa | Inline | Tasks padrao + sync ADO | Sim |
| **Grande** (multi-componente) | Spec + traceability | Sim | Sim + sync ADO | Sim |
| **Complexo** (ambiguidade, dominio novo) | Spec + Discuss | Pesquisa + arquitetura | Decomposicao paralela + sync ADO | Execute + UAT |

> **Nota:** Quick Mode (atalho TLC para tarefas pequenas) **nao esta no escopo do piloto**. Veja [ADR 008](adr/008-quick-mode-fora-do-escopo-piloto.md).

## Diferenca em relacao ao TLC original

Tres caracteristicas que diferenciam o framework Hapvida:

1. **Acoplamento ao Azure DevOps**
   - Spec versionada em ADO Repos (Git) na pasta `.specs/features/[feature]/`
   - **Snapshot anexado ao work item** quando estado vai para `Approved`, via MCP do Azure DevOps acionado por GitHub Copilot Agent Mode
   - Vinculo bidirecional spec ↔ work item

2. **Convivencia bi-VCS (PL/SQL legado em WinCVS + Java/.NET em ADO Repos Git)**
   - PL/SQL: convencao no cabecalho do procedure citando `WI-####` e `SPEC-####`
   - Java/.NET: Conventional Commits 1.0.0 com prefixo `WI-####:`
   - Tag `PRODUCAO` no WinCVS como base code unico permitido

3. **Camada fina sobre o processo Agile Hapvida 2.0**
   - Sem modificar o processo default usado em 211 projetos
   - Adicoes minimas: 2-3 campos customizados, 2-3 itens de DoR/DoD
   - Uso da matriz nativa **Demand Type x Value Area** para roteamento de templates
   - Aproveita estados existentes (`In Refinement` = elaboracao, `Approved` = spec aprovada)

## Para quem

- **Onda 1 (piloto):** ~30 tech leads
- **Onda 2 (escala):** ~120 devs e QAs em 30+ squads (~150 pessoas total)
- **Area do piloto:** Comercial (venda de planos)

## Stack de IA

- **GitHub Copilot** (Claude Opus / Sonnet) em VSCode
- **MCP Azure DevOps** local (`@azure-devops/mcp`) para snapshot ao work item
- **Wiki Arquitetura-Referencia** como RAG primario (>96 ADRs corporativas)

## Como navegar este repositorio

| Pasta | Conteudo |
|---|---|
| [`SKILL.md`](SKILL.md) | Ponto de entrada para o GitHub Copilot - leia primeiro |
| [`PROJECT.md`](PROJECT.md) | Visao, escopo e constraints deste framework |
| [`ROADMAP.md`](ROADMAP.md) | Evolucao planejada do framework |
| [`references/`](references/) | Documentos de referencia das fases e praticas |
| [`templates/`](templates/) | Templates de spec, design, tasks, ADR |
| [`prompts/`](prompts/) | Prompt files acionaveis no GitHub Copilot Chat |
| [`glossario/`](glossario/) | Glossario de dominio (Comercial, ANS, mapeamento legado) |
| [`adr/`](adr/) | ADRs do proprio framework (decisoes registradas) |
| [`examples/`](examples/) | Exemplos canonicos de uso |
| [`.github/`](.github/) | Instrucoes Copilot e instrucoes condicionais |

## Como comecar

### Para um tech lead (Onda 1)

1. Leia [`SKILL.md`](SKILL.md) - entenda como o framework opera
2. Leia [`adr/001-framework-spec-driven-hapvida.md`](adr/001-framework-spec-driven-hapvida.md) - entenda a decisao de adocao
3. Veja [`examples/`](examples/) - veja como uma spec real fica
4. Configure o MCP do ADO no seu VSCode (veja [`references/mcp-integration.md`](references/mcp-integration.md))
5. Comece pela primeira feature do seu squad

### Para um dev ou QA (Onda 2)

Aguarde o piloto da Onda 1 ser concluido. Documentacao especifica para Onda 2 sera publicada apos validacao.

## Comandos principais

Estes sao gatilhos que voce pode usar com o GitHub Copilot Chat:

| Comando / Frase | O que faz | Referencia |
|---|---|---|
| `Specify feature [nome]` | Inicia a fase Specify | [`references/specify.md`](references/specify.md) |
| `Discuss feature` | Captura decisoes de gray areas | [`references/discuss.md`](references/discuss.md) |
| `Design feature` | Inicia a fase Design | [`references/design.md`](references/design.md) |
| `Break into tasks` | Decompoe em tasks atomicas | [`references/tasks.md`](references/tasks.md) |
| `Implement task T#` | Executa uma task com verificacao | [`references/implement.md`](references/implement.md) |
| `Validate feature` | Validacao final + UAT | [`references/validate.md`](references/validate.md) |
| `Map codebase` | Brownfield mapping (7 docs) | [`references/brownfield-mapping.md`](references/brownfield-mapping.md) |
| `Initialize project` | Setup inicial do squad | [`references/project-init.md`](references/project-init.md) |
| `Pause work` / `Resume work` | Handoff entre sessoes | [`references/session-handoff.md`](references/session-handoff.md) |

## Guardrails inegociaveis

- **[GUARDRAIL]** Nunca usar MCP de banco de dados produtivo. Sempre WinCVS tag `PRODUCAO` como base code para PL/SQL.
- **[GUARDRAIL]** MCP do Azure DevOps esta autorizado para metadados (work items, attachments, repos) - **nao** para acesso a dados de beneficiario.
- **[GUARDRAIL]** Anonimizacao obrigatoria de dados de beneficiario em qualquer prompt, dataset, eval ou anexo de spec.
- **[GUARDRAIL]** ADR aplicavel ausente bloqueia avanco com marcador `[ADR-AUSENTE]`.
- **[GUARDRAIL]** Toque em area regulada exige marcador `[ANS]` + citacao de norma.

Veja [`adr/007-guardrail-acesso-producao.md`](adr/007-guardrail-acesso-producao.md) e demais ADRs.

## Licenca e creditos

Adaptacao do framework [TLC Spec-Driven](https://github.com/tech-leads-club) (CC-BY-4.0), customizado para o cenario Hapvida.

Autor da adaptacao: ver `PROJECT.md`.
