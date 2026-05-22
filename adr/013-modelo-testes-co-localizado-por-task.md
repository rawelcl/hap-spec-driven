# ADR 013: Modelo de testes co-localizado por task com Approach hibrido stack-agnostic

**Status:** Accepted
**Data:** 2026-05-22
**Tipo:** framework
**Relaciona-se com:** [ADR 010](010-tasks-obrigatorias-com-sync-ado.md) (Tasks obrigatorias),
[ADR 005](005-conventional-commits-com-prefixo-wi.md) (Commits com prefixo WI-####),
[ADR 011](011-engenharia-reversa-como-baseline.md) (Engenharia reversa como baseline)

## Contexto

A versao 0.5.2 do framework herdou do TLC original um modelo de testes baseado em tres premissas
implicitas:

1. **Frameworks de teste consolidados** por stack (JUnit 5, xUnit, utPLSQL, etc.) com
   `Test Coverage Matrix` em `TESTING.md` classificando camadas como `unit/integration/e2e/none`.
2. **Gate Check Commands** executaveis que retornam exit code (`mvn test`, `dotnet test`, etc.) e
   sao chamados em pontos especificos do `hap-sd-implement`.
3. **Test Cases ADO** (`TC-####`) criados manualmente no Azure DevOps e mapeados em `spec.md §13`
   como evidencia de cobertura para cada `FEAT-NN`.

Na pratica do piloto Hapvida (Comercial + Cadastro), nenhuma das tres premissas se realiza:

- **Sem framework de testes consolidado** para PL/SQL legado (utPLSQL nao adotado em produto). Os
  testes que existem sao **scripts PL/SQL ad-hoc executaveis via MCP Oracle** ou **procedimentos
  manuais documentados em markdown**.
- **Sem comando de gate executavel** disponivel via CI/CD nesse contexto.
- **Sem criacao automatica de TC-####** no ADO — o squad nao tem ritual de criar test cases ADO.
  Quando o QA assume a feature em homologacao, ele cria sua propria **Task ADO type=Testing** por
  iniciativa, fora do fluxo `hap-sd-tasks`.

Consequencias do descompasso entre o modelo do framework e a realidade do piloto:

- O gate "Test Co-location Validation" do `hap-sd-tasks` vira **teatro**: sem teste pra
  co-localizar, sempre passa trivialmente. Aparenta cobertura, nao cobre.
- A "Definition of Done" por task fica **subjetiva** — TL aprova "no olho", sem evidencia
  estruturada.
- O trabalho de testar e **duplicado**: dev "testa no olho", QA depois refaz do zero sem herdar
  nenhum artefato.
- **Sem gate validando que cada AC tem task que o satisfaz** — possivel aprovar `tasks.md` que
  ignora silenciosamente `FEAT-03` da spec.

Esta ADR formaliza o reframing do modelo de testes para a realidade do piloto, mantendo o framework
**stack-agnostic** (extensivel a Java/.NET/Frontend conforme essas stacks entrarem no escopo).

## Decisao

1. **Todo `tasks.md` declara tres campos obrigatorios por task de codigo:**
   - `Tests Approach:` valor em `automated | manual | hybrid | none`
   - `Tests Artifact:` caminho relativo ao test artifact (ou `N/A` quando `Approach: none`)
   - `Evidence:` como provar que o teste passou (comando + output esperado, screenshot path,
     query de validacao, ou justificativa textual quando `none`)

2. **Test artifacts vivem em `.specs/features/[feature]/tests/`** versionados em git junto
   com `spec.md`, `design.md` e `tasks.md`. Mesma tag = mesmos testes que QA herda na homologacao.
   O **formato** do artifact e ditado pelo stack (script `.sql`, classe `Test*.java`,
   procedimento `.md`, etc.); o **local** e padronizado.

3. **`hap-sd-tasks` adquire um quarto gate hard pre-aprovacao: "AC Coverage Check".**
   Toda `FEAT-NN` declarada em `spec.md §9` deve ter **pelo menos uma task** em `tasks.md` com
   `Requirement: FEAT-NN`. Tasks sem `Requirement` correspondente a alguma FEAT sao permitidas
   (tasks de suporte, refactor), mas FEATs sem cobertura sao **bloqueio hard**.

4. **O gate "Test Co-location Validation" e re-significado.** Antes validava
   `Tests: unit|integration|e2e` contra `Test Coverage Matrix`. Agora valida que cada task com
   mudanca de codigo tem `Tests Approach != none` quando a camada exige cobertura per
   `TESTING.md`, `Tests Artifact` aponta para arquivo em `tests/` (existente ou a criar na
   propria task) e `Evidence` e verificavel.

5. **`TESTING.md` e reframed como matriz hibrida stack-agnostic.** O schema gerado pelo
   `hap-sd-map` deixa de assumir `unit/integration/e2e/none` e passa a usar
   `automated/manual/hybrid/none` com tooling declarado **por stack do squad**. PL/SQL via MCP
   Oracle continua valido como exemplo de `automated`; o framework nao prescreve um tooling fixo.

6. **QA manual end-to-end fica explicitamente fora do escopo do `hap-sd-tasks`.** Analogo ao
   guardrail GMUD/deploy do [ADR-010 item 7](010-tasks-obrigatorias-com-sync-ado.md). QA conduz
   seu trabalho proprio (cria Task ADO type=Testing por iniciativa), reaproveitando os artifacts
   produzidos pelo dev em `tests/`. O framework nao decompoe atividade de QA em tasks.

7. **Modelo stack-agnostic.** O schema (3 campos + 4 gates + path padronizado) vale para
   qualquer stack do piloto e dos squads futuros (PL/SQL, Java/.NET, Frontend isolado). O
   tooling especifico e declarado em `TESTING.md` por squad.

## Justificativa

- **Alinhamento a realidade do piloto:** o modelo vigente assumia infra que nao existe; este
  fix elimina o teatro de gates e dexa Definition of Done objetiva.
- **Co-locacao dispara reuso natural com QA:** mesmo artifact escrito pelo dev vira insumo de
  homologacao. Acabou a duplicacao "dev testa no olho, QA refaz do zero".
- **AC Coverage Check fecha o ultimo buraco de rastreabilidade:** antes `Test Co-location`
  garantia "toda task tem teste", agora `AC Coverage` garante "todo AC tem task". Cadeia
  forward `FEAT-NN -> task -> Tests Artifact -> Evidence` fica completa.
- **Modelo extensivel:** quando Java/.NET/Frontend entrarem no piloto, basta o squad declarar
  seu tooling em `TESTING.md`. Schema e gates nao mudam.
- **Compliance e auditoria:** TL e auditor (ANS) conseguem provar "este AC foi verificado por
  este artifact, com esta evidencia" sem dependencia de TC-#### no ADO.

## Alternativas consideradas

- **Manter `unit/integration/e2e` e adotar utPLSQL no piloto:** descartado por overhead de
  adocao em legado PL/SQL grande. Decisao tecnica fora do escopo do framework.
- **TQ tasks separadas (QA decomposto em paralelo as dev tasks):** desenhado e descartado em
  sessao de planejamento. Inflaria `tasks.md` (15 dev = 30 itens) e ainda assim a QA real
  cria sua propria Task no ADO. Co-locacao em `tests/` resolve o problema de reuso sem inflar
  a decomposicao.
- **Adiar criacao de Test Cases ADO automatico via MCP:** considerado. Quando o ritual de
  TC-#### estiver consolidado no piloto, uma skill futura `hap-sd-test-cases` pode criar TCs
  ADO a partir do `Tests Artifact` declarado. Fora do escopo desta ADR.
- **Remover `spec.md §13 "Plano de validacao"`:** considerado. Decidiu-se **manter, reframed**
  para `FEAT-NN -> Tests Artifact path`, porque a spec e o artefato apresentado ao PO e §13
  da visao de cobertura sem precisar abrir `tasks.md`.

## Consequencias

**Positivas:**

- Definition of Done por task vira objetiva (Evidence verificavel).
- Cobertura forward `FEAT-NN -> task -> artifact -> evidence` rastreavel ponta a ponta.
- QA reaproveita artifacts do dev — fim da duplicacao de trabalho de teste.
- Gates do `hap-sd-tasks` deixam de ser teatro e passam a cobrir o que prometiam.
- Framework extensivel a novas stacks sem mudar schema.

**Negativas / Riscos:**

- **Overhead em tasks pequenas:** mudancas de 1 linha agora pedem `Tests Artifact + Evidence`.
  Mitigado por aceitar `Approach: none` com justificativa textual em refactor/doc puros.
- **Squads com TESTING.md no schema antigo** (unit/integration/e2e) ficam fora do novo modelo
  ate atualizar. **Retrocompatibilidade declarada:** schema antigo continua valido para
  projetos pre-C002 (criados antes da adocao desta ADR). Novos campos (`Tests Approach`,
  `Tests Artifact`, `Evidence`) sao **obrigatorios para tasks criadas apos a aprovacao desta
  ADR** e opcionais (aceitos mas nao validados) para tasks legadas.
- **Risco de Artifact placeholder vazio:** task declara `Tests Artifact` apontando para arquivo
  que nunca e criado. Mitigado por gate "Test Co-location Validation" re-significado, que
  exige que o arquivo exista (ou seja criado na propria task durante `hap-sd-implement`).
- **`spec.md §13` reframed quebra specs publicadas como snapshot ADO** que ainda referenciam
  `TC-####`. Snapshots sao imutaveis — nao precisam ser reescritos retroativamente; novos
  snapshots sairao com o schema novo.

## Implementacao

Esta ADR e materializada nos seguintes arquivos do framework (commit thematico por bloco):

**Commit 1 — Governance (este bloco):**

- [adr/013-modelo-testes-co-localizado-por-task.md](013-modelo-testes-co-localizado-por-task.md) — esta ADR
- [adr/010-tasks-obrigatorias-com-sync-ado.md](010-tasks-obrigatorias-com-sync-ado.md) — item 7 ampliado com QA manual fora de escopo

**Commit 2 — Schema de tasks:**

- [templates/tasks-template.md](../templates/tasks-template.md) — bloco de cada task ganha 3 campos novos
- [references/tasks.md](../references/tasks.md) — §1.5, §"Validar Antes de Apresentar", template embedded de T1/T2, §"Test Co-location Validation"
- [prompts/hap-sd-tasks.prompt.md](../prompts/hap-sd-tasks.prompt.md) — passo 6 + passo 7 (4 checks) + 2 guardrails novos
- [.claude/commands/hap-sd-tasks.md](../.claude/commands/hap-sd-tasks.md) — paridade Copilot/Claude Code

**Commit 3 — TESTING.md reframe + skills perifericos + spec templates:**

- [references/brownfield-mapping.md](../references/brownfield-mapping.md) — schema de TESTING.md reframed para matriz hibrida
- [prompts/hap-sd-map.prompt.md](../prompts/hap-sd-map.prompt.md) e [.claude/commands/hap-sd-map.md](../.claude/commands/hap-sd-map.md) — descricao do TESTING.md gerado
- [templates/design-template.md](../templates/design-template.md) — nova secao "Estrategia de verificacao"
- [prompts/hap-sd-design.prompt.md](../prompts/hap-sd-design.prompt.md) e [.claude/commands/hap-sd-design.md](../.claude/commands/hap-sd-design.md) — passo novo
- [prompts/hap-sd-validate.prompt.md](../prompts/hap-sd-validate.prompt.md) e [.claude/commands/hap-sd-validate.md](../.claude/commands/hap-sd-validate.md) — checklist amplia com AC Coverage e Tests Approach
- [references/validate.md](../references/validate.md) — §2.5 nova (AC Coverage Check)
- [prompts/hap-sd-implement.prompt.md](../prompts/hap-sd-implement.prompt.md) e [.claude/commands/hap-sd-implement.md](../.claude/commands/hap-sd-implement.md) — registro de Evidence
- [references/implement.md](../references/implement.md) — §4 approach-aware + §5b registro de Evidence
- [templates/spec-project-business.md](../templates/spec-project-business.md) — §13 reframed para `FEAT-NN -> Tests Artifact path`
- Demais [templates/spec-*.md](../templates/) — reframing equivalente onde §13 existir
- [references/specify.md](../references/specify.md) — atualizar exemplo embedded de §13

**Commit 4 — Housekeeping:**

- [SKILL.md](../SKILL.md), [.github/copilot-instructions.md](../.github/copilot-instructions.md), [references/prompt-flow.md](../references/prompt-flow.md) — alinhar terminologia onde houver referencia ao modelo antigo

## Relacao com Knowledge Verification Chain (ADR-006)

O `Tests Artifact` declarado em cada task deve ser **citavel** no padrao `[REF: arquivo:linha]`
da KVC. Quando o dev escreve um script PL/SQL de verificacao ou procedimento manual, o caminho
em `.specs/features/[feature]/tests/<nome>` vira referencia auditavel — alimentando o Step 1 da
KVC em features futuras que tocam o mesmo objeto.

## Roadmap futuro (fora do escopo desta ADR)

- **Skill `hap-sd-test-cases`:** quando o ritual de TC-#### estiver consolidado no piloto,
  criar TCs ADO automaticamente a partir do `Tests Artifact` declarado.
- **Skill `hap-sd-evidence`:** validar Evidence registrada (rodar comando declarado, conferir
  output, anexar ao Task ADO).
- **Integracao com MCP de execucao:** padronizar comando de execucao de `automated` artifacts
  (sqlplus, mvn, dotnet, pytest) declarado em `TESTING.md` por squad.
