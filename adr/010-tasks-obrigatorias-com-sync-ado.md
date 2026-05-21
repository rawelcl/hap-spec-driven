# ADR 010: Tasks obrigatorias com sync automatico ao Azure DevOps

**Status:** Accepted
**Data:** 2026-05-06
**Tipo:** framework
**Supersede parcialmente:** [ADR 001](001-framework-spec-driven-hapvida.md) (auto-skip de Tasks no Auto-Sizing)

## Contexto

O processo Hapvida 2.0 exige que **toda mudanca em codigo esteja vinculada a um work item do
tipo Task no Azure DevOps**, filho de uma User Story ou Feature. Esse vinculo e usado para
rastreabilidade de horas, governanca de release e compliance regulatorio (ANS).

A versao 0.2 do framework herdou do TLC original o auto-skip da fase Tasks para escopos Pequeno
e Medio. Na pratica, isso colidiu com o processo Hapvida em dois pontos:

1. **Falta de Task ADO em mudancas pequenas:** devs implementavam ajustes pequenos sem criar
   Task ADO, quebrando rastreabilidade de commit -> work item -> spec.
2. **Criacao manual da Task ADO:** quando o dev se lembrava de criar a Task no ADO antes de
   commitar, havia retrabalho - duplicar passos atomicos do plano de implementacao em campos
   do work item.

Alem disso, o prefixo `WI-####` definido na [ADR 005](005-conventional-commits-com-prefixo-wi.md)
e ambiguo sem essa decisao - nao fica claro se o ID e da User Story ou da Task filha.

## Decisao

1. **A fase Tasks deixa de ser auto-skip.** `tasks.md` passa a ser **obrigatorio em todos os
   escopos** do Auto-Sizing (Pequeno -> Complexo), com granularidade proporcional:
   - Pequeno: 1 a 3 tasks minimas, sem diagrama de fases.
   - Medio: 3 a 10 tasks, fases simples.
   - Grande / Complexo: como hoje (decomposicao + dependencias + paralelismo).

2. **Cada item de `tasks.md` e sincronizado 1:1 com um work item Task no Azure DevOps**,
   criado automaticamente pelo prompt `tasks-from-design` apos aprovacao humana, via MCP
   `@azure-devops/mcp` (`create_work_item`, type=Task).

3. **A Task ADO criada e filha (Parent link) da User Story ou Feature pai** declarada no
   frontmatter da spec (campo `wi_pai`).

4. **`tasks.md` e a fonte da verdade.** O ADO e o espelho operacional. Reverse sync
   (ADO -> tasks.md) **fica fora de escopo** desta versao - se um TL editar a Task direto no
   ADO, e responsabilidade do TL refletir em `tasks.md`.

5. **Commits de implementacao usam o ID da Task ADO filha** no prefixo `WI-####`, nao o ID da
   User Story / Feature pai. Isso refina e nao revoga a [ADR 005](005-conventional-commits-com-prefixo-wi.md).

6. **Design continua auto-skip** para escopos Pequeno e Medio - a decisao toca apenas a fase
   Tasks.

7. **Escopo da palavra "mudanca":** "toda mudanca" nesta ADR refere-se a **deliverable de
   codigo** (procedure PL/SQL, classe Java/.NET, endpoint, migracao de schema, etc.). Atos
   operacionais ficam **fora** do `tasks.md` e **nao geram Task ADO** via este fluxo, pois
   possuem dono proprio (TL / sustentacao), ferramenta propria e nao sao verificaveis pelo
   padrao Done-when do framework:
   - **GMUD:** RFC, aprovacao CAB, agendamento de janela, comunicacao de stakeholders,
     evidencias de mudanca.
   - **Deploy:** build de release, promocao entre ambientes (DEV -> HML -> PRD), execucao em
     PRD, rollback, smoke test pos-deploy.

   A enforcement vive no guardrail "Fora de escopo" do skill
   [hap-sd-tasks.prompt.md](../prompts/hap-sd-tasks.prompt.md) e e documentada em
   [references/tasks.md](../references/tasks.md) (secao "Fora de escopo").

## Justificativa

- **Alinhamento ao processo Hapvida 2.0:** toda mudanca passa a ter Task ADO sem excecao - o
  framework deixa de competir com o processo.
- **Eliminacao de trabalho manual:** o dev nao pre-cria Tasks; o framework cria a partir do
  artefato que ja vai existir (`tasks.md`).
- **Rastreabilidade granular:** commit -> Task ADO filha -> User Story / Feature -> spec ->
  design (quando existe).
- **Compliance:** atende auditoria de releases sem ritual extra para o dev.
- **Governance:** tornar Tasks obrigatorio fortalece o veto a Quick Mode
  ([ADR 008](008-quick-mode-fora-do-escopo-piloto.md)).

## Alternativas consideradas

- **Manter auto-skip de Tasks para escopos Pequeno/Medio:** descartado por colidir com o processo
  Hapvida e empurrar o dev a criar Tasks ADO manualmente.
- **Tornar Tasks obrigatorio mas sem sync automatico:** descartado - obriga retrabalho duplicado
  (escrever em `tasks.md` e depois copiar para o ADO).
- **Sync bidirecional (ADO <-> tasks.md):** descartado nesta versao por complexidade. Reverse
  sync entra no roadmap futuro.
- **1 Task ADO por feature inteira (em vez de 1:1):** descartado por perder granularidade -
  feature de 8 tasks viraria 1 Task ADO de 8 itens, sem rastreio fino por commit.

## Consequencias

**Positivas:**

- Rastreabilidade ponta a ponta sem ritual extra.
- Commits usam ID de Task ADO especifico - grep direto leva ao trabalho exato.
- Veto a Quick Mode reforcado: nao ha como burlar Task ADO via atalho.
- `tasks.md` deixa de ser "opcional caro" e vira insumo direto de governanca.

**Negativas / Riscos:**

- Overhead percebido em mudancas Pequenas (1-2 arquivos) ganha 1 artefato extra. Mitigado por
  permitir `tasks.md` minimalista (1 task, sem diagrama).
- Risco de drift `tasks.md` vs ADO se TL editar direto no ADO - mitigado declarando `tasks.md`
  como fonte da verdade.
- Dependencia operacional do MCP `@azure-devops/mcp`: se MCP estiver offline, criacao
  automatica falha. Mitigacao: fallback documentado em
  [references/tasks.md](../references/tasks.md) para criacao manual com guardrail de gravar IDs
  de volta em `tasks.md`.

## Implementacao

- [SKILL.md](../SKILL.md) - diagrama do pipeline, tabela Auto-Sizing, regras e tabela MCP
  atualizadas.
- [references/tasks.md](../references/tasks.md) - "Sempre obrigatorio" + secao "Sincronizacao
  com Azure DevOps".
- [templates/tasks-template.md](../templates/tasks-template.md) - campo `ADO Task ID` e bloco
  `wi_pai`.
- [prompts/hap-sd-tasks.prompt.md](../prompts/hap-sd-tasks.prompt.md) - passos de
  criacao automatica via MCP.
- [references/implement.md](../references/implement.md) - verificacao de IDs ADO antes de
  iniciar Execute.
- [adr/005](005-conventional-commits-com-prefixo-wi.md) - esclarecer que `WI-####` no commit de
  implementacao refere-se a Task ADO filha.
- [adr/008](008-quick-mode-fora-do-escopo-piloto.md) - cross-reference reforcando o veto.
- [references/tasks.md](../references/tasks.md) - secao "Fora de escopo (nao entram em
  tasks.md)" delimitando GMUD e deploy.
- [prompts/hap-sd-tasks.prompt.md](../prompts/hap-sd-tasks.prompt.md) e
  [.claude/commands/hap-sd-tasks.md](../.claude/commands/hap-sd-tasks.md) - guardrail "Fora de
  escopo" enforcing a exclusao de GMUD e deploy na decomposicao.
