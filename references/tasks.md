# Tasks

**Goal:** Quebrar em tasks GRANULARES e ATOMICAS. Dependencias claras. Ferramentas certas. Plano de execucao paralela.

**Pular esta fase quando:** Existem ≤3 passos obvios. Nesse caso, tasks sao implicitas - va direto
para Execute e liste-os inline no plano de implementacao.

## Adaptacoes Hapvida em relacao ao TLC original

| Item | TLC | Hapvida |
|---|---|---|
| Local | `.specs/[feature]/tasks.md` | Idem |
| Test Coverage Matrix | TLC tem em `.specs/codebase/TESTING.md` | Idem - mas para PL/SQL no piloto adaptado (sem CI/CD) |
| Parallelism Assessment | TLC tem | Idem - mas Java/.NET geralmente parallel-safe; PL/SQL legado pode nao ser |
| Sub-agent delegation | TLC sugere Task tool | `[ADAPTACAO]` GitHub Copilot Agent Mode com tools restritas |
| Conventional Commits | TLC obriga | `[ADAPTACAO]` Mantem + adiciona prefixo `WI-####:` antes do tipo |
| Convencao para CVS | Nao se aplica TLC | `[ADAPTACAO]` Cabecalho de comentario no procedure cita `WI-####` e `SPEC-####` |

## Por que tasks granulares?

| Vague Task (RUIM) | Granular Tasks (BOM) |
|---|---|
| "Criar formulario" | T1: Criar componente de input email |
| | T2: Adicionar validacao de email |
| | T3: Criar botao submit |
| | T4: Adicionar gerenciamento de estado do form |
| | T5: Conectar form a API |
| "Implementar autenticacao" | T1: Criar interface de servico de auth |
| | T2: Implementar refresh de token |
| | T3: Criar componente de login |
| | T4: Adicionar protecao de rotas |

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

---

## Template: `.specs/[feature]/tasks.md`

```markdown
# [Feature] Tasks

**Design:** `.specs/[feature]/design.md`
**Status:** Draft | Approved | In Progress | Done

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
**Commit:** `WI-12345: feat(comercial): criar interface de servico de cotacao`

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
