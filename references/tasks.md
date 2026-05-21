# Tasks

**Goal:** Quebrar em tasks GRANULARES e ATOMICAS. Dependencias claras. Ferramentas certas. Plano de execucao paralela. **Cada task de `tasks.md` vira 1 work item Task no Azure DevOps**, vinculada a User Story / Feature pai.

**Sempre obrigatorio no piloto Hapvida.** [REF: ADR-010](../adr/010-tasks-obrigatorias-com-sync-ado.md) -
toda mudanca, pequena ou complexa, exige Task no ADO. Para escopo Pequeno o `tasks.md` pode ter
1-3 tasks minimas e dispensar diagrama de fases - mas existe e sincroniza ao ADO.

## Adaptacoes Hapvida em relacao ao TLC original

| Item | TLC | Hapvida |
|---|---|---|
| Local | `.specs/[feature]/tasks.md` | Idem |
| Obrigatoriedade | Auto-skip para escopo direto | `[ADAPTACAO]` **Sempre obrigatorio** ([REF: ADR-010](../adr/010-tasks-obrigatorias-com-sync-ado.md)) |
| Sync com tracker | Nao se aplica | `[ADAPTACAO]` **Cada task vira 1 work item Task no ADO** (1:1, parent = User Story / Feature) via MCP |
| Test Coverage Matrix | TLC tem em `.specs/codebase/TESTING.md` | Idem - mas para PL/SQL no piloto adaptado (sem CI/CD) |
| Parallelism Assessment | TLC tem | Idem - mas Java/.NET geralmente parallel-safe; PL/SQL legado pode nao ser |
| Sub-agent delegation | TLC sugere Task tool | `[ADAPTACAO]` GitHub Copilot Agent Mode com tools restritas |
| Conventional Commits | TLC obriga | `[ADAPTACAO]` Mantem + adiciona prefixo `WI-####:` (ID da Task ADO filha) antes do tipo |
| Convencao para CVS | Nao se aplica TLC | `[ADAPTACAO]` Cabecalho de comentario no procedure cita `WI-####` (Task ADO) e `SPEC-####` |

## Por que tasks granulares?

| Vague Task (RUIM) | Granular Tasks (BOM) |
|---|---|
| x

**Beneficios:**

- **Agentes nao erram** - foco unico, sem ambiguidade
- **Facil testar** - cada task = um resultado verificavel
- **Paralelizavel** - tasks independentes rodam simultaneamente
- **Erros isolados** - uma falha nao bloqueia tudo

**Regra:** Uma task = UMA destas:

- Um componente
- Uma funcao
- Um endpoint API
- Uma alteracao de arquivo

---

## Fora de escopo (nao entram em tasks.md)

Os itens abaixo **nao sao decompostos em tasks** pelo skill [`/hap-sd-tasks`](../prompts/hap-sd-tasks.prompt.md)
e **nao sao sincronizados como Tasks no ADO**. Sao responsabilidade do TL, fora do fluxo
spec-driven, gerenciados pelos processos corporativos proprios.

| Categoria | Exemplos do que NAO vira task |
|---|---|
| **GMUD** | Abertura de RFC, aprovacao CAB, agendamento de janela, comunicacao de stakeholders, evidencias de mudanca |
| **Deploy** | Build de release, promocao entre ambientes (DEV -> HML -> PRD), execucao de script em PRD, rollback, smoke test pos-deploy |

**Como o skill se comporta:** se `design.md` mencionar passos de GMUD ou deploy, o agente
**ignora** esses passos ao decompor. Se o TL pedir explicitamente para incluir, o agente
**recusa e aponta este guardrail**.

**Por que esta fora:** GMUD e deploy nao sao deliverables de codigo verificaveis por gate de
teste - sao atos operacionais com fluxo proprio, dono proprio (TL / sustentacao) e ferramenta
propria. Inclui-los em `tasks.md` polui o sync ADO, distorce metrica de progresso da feature
e cria tasks que ninguem consegue "verificar" no padrao Done-when do framework.

---

## Process

### 1. Revisar Design

Leia `.specs/[feature]/design.md` antes de criar tasks.

### 1.5. Carregar Test Coverage Matrix

Leia `.specs/codebase/TESTING.md` (se existir) antes de criar tasks. A Test Coverage Matrix e a
Parallelism Assessment direcionam duas decisoes criticas:

**Tests co-localizados:** Toda task que cria ou modifica uma camada de codigo com tipo de teste
exigido DEVE incluir escrita/atualizacao desses testes na mesma task. Tests NAO sao tasks separadas.

| Task cria... | "Done When" deve incluir... |
|---|---|
| Camada de codigo com requisito "unit" | Teste unitario escrito + gate quick passa |
| Camada de codigo com requisito "e2e" | Teste e2e escrito + gate full passa |
| Camada de codigo com requisito "integration" | Teste de integracao escrito + gate full passa |
| Camada de codigo com requisito "none" | Gate check no nivel apropriado |

**Flags de paralelismo:** Cruze com a Parallelism Assessment ao marcar tasks `[P]`:

- Se o tipo de teste exigido pela task e marcado "Parallel-Safe: No" -> retire flag `[P]`
- Se o tipo de teste e "Parallel-Safe: Yes" -> `[P]` permitido
- Se a task nao tem testes -> `[P]` depende so de dependencias de codigo

Se TESTING.md nao existe (projeto greenfield), pergunte ao usuario quais tipos de teste e comandos
o projeto usara antes de criar tasks.

### 2. Quebrar em Tasks Atomicas

**Task = UM deliverable.** Exemplos:

- ✓ "Criar UserService interface" (um arquivo, um conceito)
- X "Implementar gestao de usuarios" (vago, multiplos arquivos)

### 3. Definir Dependencias

O que DEVE estar feito antes desta task comecar?

### 4. Criar Plano de Execucao

Agrupe tasks em fases. Identifique o que pode rodar em paralelo.

### 5. Validar Antes de Apresentar (OBRIGATORIO)

Antes de mostrar tasks ao usuario, rode TRES checks pre-aprovacao. Estes NAO sao opcionais - sao
gates. Se algum check falha, reestruture e re-rode ate todos passarem.

**Check 1: Granularidade da Task** - verifique cada task atomica (ver secao Granularity Check).

**Check 2: Cross-Check Diagrama-Definicao** - verifique que o diagrama de execucao bate com o
campo `Depends on` de cada task.

**Check 3: Validacao de Test Co-location** - verifique que o campo `Tests` de cada task bate com a
matriz de cobertura do TESTING.md.

**Apresente as duas tabelas de validacao com as tasks** para o usuario ver os resultados. Qualquer
X significa que voce DEVE reestruturar antes de apresentar.

### 6. PERGUNTAR sobre MCPs e Skills

**CRITICO:** Antes de execucao, pergunte ao usuario:

> "Para cada task, quais ferramentas devo usar?"
>
> **MCPs disponiveis:** [listar - tipicamente: `@azure-devops/mcp`, Context7]
> **Skills disponiveis:** [listar - tipicamente: `sigo-modernizacao-plsql`, `sigo-refatoracao-workflow`, `plsql-oracle-expert`]

### 7. Sincronizar tasks.md com Azure DevOps (OBRIGATORIO)

Apos aprovacao das tasks pelo TL, criar 1 work item Task no ADO por item de `tasks.md`,
via MCP `@azure-devops/mcp`.

**Pre-requisitos:**

- Spec aprovada com `wi_pai` declarado no frontmatter (ID da User Story ou Feature pai).
- `tasks.md` com todos os 3 checks pre-aprovacao verdes.
- MCP `@azure-devops/mcp` conectado.

**Acao automatizada (ver [`/hap-sd-tasks`](../prompts/hap-sd-tasks.prompt.md)):**

Para cada task `T<n>`:

1. Chamar `mcp_azure-devops_create_work_item` com:
   - `type`: `Task`
   - `title`: `T<n> - <titulo da task>`
   - `parent`: `wi_pai` (User Story / Feature da spec)
   - `description`: bloco com link ao `tasks.md` no ADO Repos + secao "Done when" da task
   - `area_path` / `iteration_path`: herdados da spec
2. Receber o ID do work item retornado.
3. Gravar de volta em `tasks.md` no campo `**ADO Task ID:**` da task correspondente.
4. Ao final, apresentar tabela `T<n> <-> ADO Task #<id>` ao TL.

**Fonte da verdade:** `tasks.md`. ADO e espelho operacional. Se TL editar Task direto no ADO,
e responsabilidade do TL refletir em `tasks.md`.

**Fallback (MCP indisponivel):** TL cria as Tasks manualmente no ADO e preenche `ADO Task ID`
em `tasks.md` antes de iniciar Execute. `[GUARDRAIL]` **Execute nao pode iniciar sem todos os
IDs preenchidos.**

---

## Template: `.specs/[feature]/tasks.md`

```markdown
# [Feature] Tasks

**Design:** `.specs/[feature]/design.md` (quando aplicavel)
**Status:** Draft | Approved | Synced | In Progress | Done

**Sync ADO:**

- `wi_pai`: <ID da User Story / Feature pai>
- `ado_project`: <projeto ADO>
- `ado_area_path`: <area path do squad>

---

## Plano de execucao

### Fase 1: Fundacao (Sequencial)

Tasks que devem vir primeiro, em ordem.

```
T1 -> T2 -> T3
```

### Fase 2: Implementacao Core (Paralelo OK)

Apos fundacao, estas podem rodar em paralelo.

```
       +-> T4 -+
T3 ----+-> T5 -+--> T8
       +-> T6 -+
T7 ------------>
```

### Fase 3: Integracao (Sequencial)

Juntando tudo.

```
T8 -> T9
```

---

## Detalhamento das tasks

### T1: [Criar X Interface]

**O que:** [Uma frase: deliverable exato]
**Onde:** `src/path/to/file.ts` ou `schema.package_x`
**Depende de:** Nenhuma
**Reutiliza:** `src/existing/BaseInterface.ts` ou `[REF: ADR-22]`
**Requirement:** FEAT-01
**ADO Task ID:** <preenchido apos sync via MCP>

**Ferramentas:**

- MCP: `@azure-devops/mcp` (para work item updates)
- Skill: `plsql-oracle-expert` (se PL/SQL)

**Done when:**

- [ ] Interface definida com todos os metodos do design
- [ ] Tipos exportados corretamente
- [ ] Sem erros de compilacao
- [ ] Test count: [N] testes passam (sem deletes silenciosos)

**Tests:** unit
**Gate:** quick
**Commit:** `WI-<ADO Task ID>: feat(comercial): criar interface de servico de cotacao`

---

### T2: [Implementar Y Service] [P]

**O que:** [Deliverable exato]
**Onde:** `src/services/YService.ts`
**Depende de:** T1
**Reutiliza:** `src/services/BaseService.ts` patterns
**Requirement:** FEAT-01

**Ferramentas:**

- MCP: `@azure-devops/mcp`, Context7
- Skill: nenhuma

**Done when:**

- [ ] Implementa interface da T1
- [ ] Trata casos de erro do design
- [ ] Gate check passa: `[comando do quick gate do TESTING.md]`
- [ ] Test count: [N] testes passam

**Tests:** unit
**Gate:** quick
**Commit:** `WI-12345: feat(comercial): implementar servico de cotacao`

---

[repetir estrutura para demais tasks]

---

## Mapa de execucao paralela

```
Fase 1 (Sequencial):
  T1 -> T2 -> T3

Fase 2 (Paralelo):
  T3 completa, entao:
    +-- T4 [P]
    +-- T5 [P]  } Podem rodar simultaneamente
    +-- T6 [P]

Fase 3 (Sequencial):
  T4, T5, T6 completas, entao:
    T7 -> T8
```

**Restricao de paralelismo:** Uma task marcada `[P]` deve ter TODAS estas:

- Sem dependencias nao-finalizadas
- Tipo de teste exigido e parallel-safe (per TESTING.md Parallelism Assessment)
- Sem estado mutavel compartilhado com outras tasks `[P]` na mesma fase

Se os testes da task NAO sao parallel-safe, ela DEVE rodar sequencialmente mesmo que o codigo nao
tenha dependencias. A execucao de testes e o gargalo.

**Como execucao paralela funciona:**

Tasks marcadas `[P]` sao executadas via sub-agents - um sub-agent por task, lancados concorrentemente.
Cada sub-agent recebe so a definicao de sua task e o contexto relevante. O agente orquestrador
aguarda todos os sub-agents da fase completarem antes de avancar.

Tasks sequenciais (sem `[P]`) tambem sao delegadas a sub-agents, mas uma de cada vez. Isso mantem
artefatos de implementacao (file reads, output de teste, logs de gate check) fora do contexto
principal.

---

## Granularity Check

Antes de aprovar tasks, verifique se sao granulares o suficiente:

| Task | Escopo | Status |
|---|---|---|
| T1: Criar input email | 1 componente | OK Granular |
| T2: Adicionar funcao de validacao | 1 funcao | OK Granular |
| T3: Criar form com todos os campos | 5+ componentes | X Dividir! |
| T4: Conectar a API | 1 funcao | OK Granular |

**Granularity check:**

- OK 1 componente / 1 funcao / 1 endpoint = Bom
- ATENCAO 2-3 coisas relacionadas no mesmo arquivo = OK se coesas
- X Multiplos componentes ou arquivos = DEVE dividir

---

## Diagram-Definition Cross-Check

Antes de aprovar tasks, verifique consistencia entre diagrama e definicoes. Sao artefatos
independentes que podem divergir.

Para cada task, verifique:

| Task | Depends On (corpo da task) | Diagrama mostra | Status |
|---|---|---|---|
| T[N] | [deps do corpo] | [deps das setas] | OK Match ou X Mismatch |

**Regras:**

- Todo `Depends on` no corpo deve ter seta correspondente no diagrama
- Toda seta no diagrama deve corresponder a `Depends on` na task de destino
- Tasks mostradas como paralelas (`[P]`) nao podem depender umas das outras

---

## Test Co-location Validation

Antes de aprovar tasks, verifique TODA task contra a Test Coverage Matrix do TESTING.md.
Hard gate - tasks que falham DEVEM ser corrigidas.

| Task | Camada criada/modificada | Matrix exige | Task diz | Status |
|---|---|---|---|---|
| T[N]: [name] | [camada] | [tipo de teste] | [campo Tests] | OK ou X VIOLACAO |

**Regras:**

- "Testado em outra task" NAO e justificativa valida para `Tests: none`. Isso e deferimento
  de teste - exatamente o anti-pattern que esta validacao previne.
- `Tests: none` so e valido quando a matrix diz "none" para aquela camada
- Se uma task cria MULTIPLAS camadas, use o tipo de teste mais alto exigido por qualquer uma
- Qualquer X VIOLACAO -> reestrutura a task para incluir testes exigidos

---

## Tips

- **[P] = Paralelo OK** - Marque tasks que podem rodar simultaneamente
- **Reutilizacao = poupa tokens** - Sempre referencie codigo existente
- **Ferramentas por task** - MCPs e Skills previnem abordagens erradas
- **Dependencias sao gates** - Deixe claro o que bloqueia o que
- **Done when = Testavel** - Se nao consegue verificar, reescreva
- **Requirement ID = Rastreavel** - Toda task volta a um requirement de spec
- **Um commit por task** - Planeje formato da commit message com antecedencia

---

## Padroes de verificacao de tasks

Toda task DEVE incluir:

**Done when checklist:**

- Resultados especificos e testaveis
- Criterio pass/fail
- Comando especifico do Gate Check Commands do TESTING.md
- Pass count esperado (previne deletes silenciosos)

**Verify section:**

- Comandos para provar funcionalidade
- Outputs esperados
- Indicadores de sucesso

**Quality check:**

- A task pode ser verificada sem julgamento humano?
- O criterio de sucesso e binario (pass/fail)?
- A verificacao pode ser automatizada?

---

## Adaptacoes especificas Hapvida

- **Conventional Commits + prefixo `WI-####:`**:
  ```
  WI-12345: feat(comercial): adicionar validacao de carencia
  WI-12345: refactor(plsql): extrair logica de calculo de proposta
  WI-12345: fix(auth): corrigir refresh de token expirado
  ```

- **Para CVS (PL/SQL)**: como commit message do CVS e fraco, a convencao e replicada no
  cabecalho de comentario do procedure ou package:

  ```sql
  /*
   * WI-12345 / SPEC-2026-COM-0001
   * feat(comercial): adicionar validacao de carencia
   * Refs: ADR-22 (Padrao Repositorio)
   * [ANS] Lei 9.656/98 art. 12 - carencias maximas
   * Author: <nome>
   * Date: YYYY-MM-DD
   */
  ```

- **Para Java/.NET (ADO Repos Git)**: commit message + PR linkado ao work item.

- **Tasks em refatoracao PL/SQL** carregam tipicamente:
  - `Reutiliza:` baseline da tag PRODUCAO + ADRs aplicaveis
  - `[MIGRACAO]` em pontos especificos
  - Skill `plsql-oracle-expert` para code review

- **Sub-agent delegation via Copilot Agent Mode**: cada task `[P]` pode ser executada num
  Agent Mode do Copilot configurado com tools restritas (so as MCPs necessarias para a task).
