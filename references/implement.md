# Execute (Implement)

**Goal:** Implementar UMA task por vez. Mudancas cirurgicas. Verificar. Commit. Repetir.

E aqui que codigo e escrito. Toda task segue o mesmo ciclo: planejar -> implementar -> verificar -> commit.
Verificacao e parte de toda task, nao uma fase separada.

## Adaptacoes Hapvida em relacao ao TLC original

| Item | TLC | Hapvida |
|---|---|---|
| Conventional Commits | Sim | `[ADAPTACAO]` Mantem + prefixo `WI-####:` |
| Test integrity | Mandatorio | Idem |
| Snapshot ao work item | Nao se aplica | `[ADAPTACAO]` Apos task que conclui spec aprovada, snapshot via MCP |
| Convencao para CVS | Nao se aplica | `[ADAPTACAO]` Cabecalho de comentario no procedure |

---

## OBRIGATORIO: Antes de comecar qualquer implementacao

**Leia [coding-principles.md](coding-principles.md) e declare:**

1. **Premissas** - O que estou assumindo? Qualquer incerteza?
2. **Arquivos a tocar** - Liste APENAS os arquivos que esta task exige
3. **Criterio de sucesso** - Como vou verificar que funciona?

**Nao prossiga sem declarar isso explicitamente.**

---

## Process

**Contexto sub-agent:** Quando esta task e executada por um sub-agent (Copilot Agent Mode), o
sub-agent recebe a definicao da task, principios de coding, TESTING.md e contexto relevante de
spec/design. Todos os passos abaixo se aplicam identicamente seja em contexto principal ou
sub-agent. A unica diferenca: sub-agents reportam resultados ao orquestrador em vez de continuar
para a proxima task.

### 0. Verificar tasks.md e IDs ADO (OBRIGATORIO)

`tasks.md` e **sempre obrigatorio** ([REF: ADR-010](../adr/010-tasks-obrigatorias-com-sync-ado.md))
e deve ter cada task com `ADO Task ID` preenchido antes de iniciar Execute.

Checklist nao-negociavel:

- [ ] `tasks.md` existe na pasta da feature
- [ ] Status do `tasks.md` esta `Synced` (ou `In Progress`)
- [ ] Toda task tem `ADO Task ID` preenchido (nao `<preenchido apos sync via MCP>`)
- [ ] Campo `Commit` de cada task usa `WI-<ADO Task ID>`, nao placeholder

Se algum item falhar: **PARE** e rode [`/hap-sd-tasks`](../prompts/hap-sd-tasks.prompt.md)
antes de prosseguir. Nao improvise plano inline - o processo Hapvida exige Task no ADO para
toda mudanca.

### 1. Escolher Task

Do `tasks.md` da feature em foco. Usuario especifica ("implementar T3") ou voce sugere a proxima
disponivel cujas dependencias estao satisfeitas.

### 2. Verificar Dependencias

Cheque dependencias declaradas em `tasks.md`.

X Se bloqueada: "T3 depende de T2 que nao esta feita. Faco T2 primeiro?"

### 3. Declarar Plano de Implementacao

Antes de escrever codigo:

```
Arquivos: [lista]
Abordagem: [descricao breve]
Sucesso: [como verificar]
```

### 4. Escrever Tests Primeiro (Tests Artifact — approach-aware)

Conforme `Tests Approach` declarado na task ([REF: ADR-013](../adr/013-modelo-testes-co-localizado-por-task.md)):

**`automated`** — fluxo RED-GREEN classico:

1. Escreva o `Tests Artifact` (script `.sql`, classe `Test*.java`, arquivo `*.test.ts`) ANTES da implementacao
2. O artifact codifica o comportamento esperado dos criterios de "Done when" + Edge Cases relevantes
3. Rode o comando de execucao - confirme que tests FALHAM (estado RED)
4. Se passar antes da implementacao existir, os tests sao fracos demais - reescreva

**`manual`** — procedimento documentado:

1. Escreva o `Tests Artifact` (`.md`) com passos numerados, dados de entrada e resultado esperado por passo
2. Inclua coluna `Status` por passo (Pass/Fail/Pending) que sera preenchida na execucao
3. Edge Cases do spec.md viram passos adicionais no procedimento

**`hybrid`** — combinacao:

1. Escreva ambos: script `.sql`/automated para parte verificavel mecanicamente + procedimento `.md`
   para parte que exige humano
2. Cada artifact cobre cenarios distintos (script confere dado; procedimento confere UX)

**`none`** — sem artifact:

1. Documente em `Evidence` por que a task nao exige artifact (refactor sem mudanca de comportamento,
   doc puro, etc.). Pule para Step 4b.

**Restricoes (todos approaches):**

- Tests definem comportamento correto independente de implementacao
- Cada criterio de "Done when" mapeia para pelo menos uma assertion (automated) ou passo (manual)
- Edge cases do spec.md que se aplicam a esta task tambem ganham cobertura no artifact
- O artifact vive em `.specs/features/[feature]/tests/` conforme path declarado em `Tests Artifact`

### 4b. Implementar (GREEN)

Escreva a implementacao MINIMA necessaria para satisfazer os criterios de sucesso da task: passar
todos os tests relevantes (quando presentes) e atender as verificacoes de gate quando nao ha
tests diretos.

**HARD CONSTRAINTS:**

- NAO modifique tests escritos no Step 4. Os tests sao a spec - implementacao se conforma a eles.
- NAO enfraqueca assertions (deixando-as menos especificas para passar mais facil)
- NAO delete ou pule casos de teste
- NAO use o mecanismo de skip/disable/pending do framework de teste para contornar tests falhando
- Codigo minimo para passar - guarde melhorias estruturais para uma task de refactor

Se um teste esta genuinamente errado (testa comportamento errado per spec), PARE e pergunte ao
usuario antes de modifica-lo. Nunca silenciosamente mude um teste.

Siga [coding-principles.md](coding-principles.md):

- Codigo mais simples que funciona
- Toque APENAS os arquivos listados
- Sem creep de escopo

### 5. Gate Check (VERIFY)

Rode o gate check do tasks.md / TESTING.md. OBRIGATORIO - nao "se aplicavel". O comportamento
depende do `Tests Approach` da task ([REF: ADR-013](../adr/013-modelo-testes-co-localizado-por-task.md)):

**Para `automated`:**

1. Olhe o comando para o nivel de Gate da task (quick/full/build) na secao Gate Check Commands do TESTING.md, depois rode
2. Codigo de saida diferente de zero = PARE. Conserte. Re-rode. Nao prossiga ate verde.
3. Confirme contagem de tests bate com o esperado (nenhum silenciosamente deletado/pulado)

**Para `manual`:**

1. Execute o procedimento documentado no `Tests Artifact` passo a passo
2. Anote o resultado de cada passo (Pass/Fail) na coluna `Status` do procedimento
3. Capture screenshot/log do passo final para anexar como Evidence
4. Qualquer Fail = PARE. Conserte. Re-execute.

**Para `hybrid`:**

1. Rode os passos `automated` (exit 0 obrigatorio)
2. Execute o procedimento `manual` (todos passos Pass)
3. Ambos lados precisam aprovar antes de avancar

**Para `none`:**

1. Rode apenas o gate `build` (compila? lint passa?) - sem rodar tests
2. Justificativa textual no campo `Evidence` da task

**Gates por nivel (do TESTING.md Gate Check Commands):**

| Task ambito | Nivel de gate | O que roda |
|---|---|---|
| Approach automated, escopo isolado | Quick | Comando rapido (subset) |
| Approach automated/hybrid, escopo broad | Full | Comando completo (unit + integration + e2e quando houver) |
| Ultima task de uma fase | Build | Build + lint + todos tests (automated) ou Build + lint (none) |

O gate check e deterministico para `automated`/`hybrid`. Para `manual`, a evidencia (screenshot/log)
substitui o exit code — mas a obrigacao de registrar a Evidence permanece.

### 5b. Registrar Evidence em tasks.md (OBRIGATORIO antes do commit)

Apos o gate passar, **edite a task no `tasks.md`** preenchendo o campo `Evidence` com a saida real:

| Approach | Conteudo esperado em Evidence |
|---|---|
| `automated` | Comando real executado + exit code + contagem de tests + path do report (JUnit XML / coverage / log) |
| `manual` | Path do screenshot/log final + assinatura do dev (ex: "tests/screenshots/cadastro_passo5.png + dev: rawelcl") |
| `hybrid` | Ambos (comando automated + screenshot manual) |
| `none` | Justificativa textual final (ex: "refactor de renomeacao em UserRepository - sem mudanca de comportamento") |

**Sem Evidence registrada = nao prossiga para commit.** O campo `Evidence` materializa o
Done When objetivo da task; sem ele, TL nao consegue validar na fase Validate (§2.5 AC Coverage
Check) e a task fica de fato pendente mesmo que o codigo esteja pronto.

### 6. Post-Gate Review

Apos o gate check passar:

1. Verifique contagem de testes: ha pelo menos a mesma quantidade de casos que antes? (previne
   delecao silenciosa)
2. Verifique sem SPEC_DEVIATION: se a implementacao divergiu da spec/design, adicione marcador:

```
// SPEC_DEVIATION: [o que divergiu]
// Reason: [por que a divergencia foi necessaria]
```

3. Quick complexity check: "Engenheiro senior chamaria isso de overcomplicado?"
   - Sim -> simplifique, re-rode gate
   - Nao -> prossiga para commit

### 7. Atomic Git Commit

Cada task ganha seu proprio commit imediatamente apos verificacao. Nunca agrupe multiplas tasks
em um commit.

**Formato Hapvida ([Conventional Commits 1.0.0](https://www.conventionalcommits.org/) + prefixo WI):**

```
WI-<ADO Task ID>: <type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

**Importante:** o `<ADO Task ID>` no prefixo e o ID da **Task ADO filha** (criada via
`tasks-from-design`), nao o ID da User Story / Feature pai. Ver
[ADR 010](../adr/010-tasks-obrigatorias-com-sync-ado.md) e
[ADR 005](../adr/005-conventional-commits-com-prefixo-wi.md).

**Tipos:**

| Type | Quando usar |
|---|---|
| `feat` | Nova feature ou capacidade |
| `fix` | Bug fix |
| `refactor` | Mudanca de codigo que nem fix nem feat (ex: refatoracao Improvement+Tunning) |
| `docs` | So documentacao |
| `test` | Adicionando ou corrigindo tests |
| `style` | Formatacao, ponto e virgula faltando, etc (sem mudanca de codigo) |
| `perf` | Melhoria de performance |
| `build` | Sistema de build ou dependencias externas |
| `ci` | Arquivos e scripts de CI |
| `chore` | Tasks de manutencao que nao modificam src ou test |

**Scope:** Nome da feature ou modulo, lowercase. Ex: `comercial`, `cotacao`, `auth`, `plsql`.

**Description:**

- Imperativo ("adicionar", nao "adicionado" ou "adiciona")
- Lowercase primeira letra
- Sem ponto no final
- Complete a frase: "Se aplicado, este commit ira _[sua descricao]_"

**Breaking changes:** Append `!` apos type/scope E adicione footer `BREAKING CHANGE:`:

```
WI-12345: feat(api)!: mudar formato de resposta do endpoint de auth

BREAKING CHANGE: endpoint de login agora retorna JWT no body em vez de cookie
```

**Exemplos:**

```
WI-12345: feat(comercial): adicionar validacao de carencia
WI-12345: fix(cotacao): prevenir quantidade negativa em decremento
WI-12345: refactor(plsql): extrair logica de calculo de proposta para package
WI-12345: test(comercial): adicionar testes para edge cases de carencia
```

**Para CVS (PL/SQL)** - como commit message do CVS e fraco, a convencao e replicada no cabecalho:

```sql
/*
 * WI-12345 / SPEC-2026-COM-0001
 * refactor(plsql): extrair logica de calculo de proposta para package
 * Refs: ADR-22 (Padrao Repositorio), ADR-74 (DDD)
 * [ANS] Lei 9.656/98 art. 12 - carencias maximas
 * Author: <nome>
 * Date: YYYY-MM-DD
 * Original-Procedure: pkg_proposta.calcula_carencia (linhas 145-220 da PRODUCAO)
 */
```

**Regras:**

- Uma task = um commit
- Description referencia o que foi FEITO, nao o que foi planejado
- Inclua apenas arquivos listados na task - nunca "ja que estou aqui" mudancas extras
- Se tests sao parte da task, inclua no mesmo commit

### 8. Scope Guardrail

Durante implementacao, voce notara coisas que poderiam ser melhoradas, refatoradas ou adicionadas.
**Nao aja nelas.** Em vez disso:

- Se e um bug: anote no STATE.md como blocker (B-NNN) ou crie task separada
- Se e melhoria: anote no STATE.md sob "Deferred Ideas" ou "Lessons Learned"
- Se relacionado a task atual: so inclua se esta nos criterios de "Done when"

**Heuristica:** "Isso esta na minha definicao de task?" Se nao, nao toque.

### 9. Atualizar Status da Task

Marque task completa em tasks.md. Atualize traceability de requirements em spec.md se IDs sao
usados.

### 10. (Hapvida) Snapshot via MCP quando spec atinge Approved

Quando a feature inteira atinge estado `Approved` no work item ADO (todas as tasks da spec
completadas e gates passaram), o TL aciona o prompt file [`/hap-sd-snapshot`](../prompts/hap-sd-snapshot.prompt.md)
para anexar snapshot da spec/design/tasks ao work item via MCP do Azure DevOps.

Ver [`mcp-integration.md`](mcp-integration.md) para detalhes operacionais.

---

## Execution Template

```markdown
## Implementando T[X]: [Task Title]

**Lendo:** definicao da task em tasks.md
**Dependencias:** [Todas done? OK | Bloqueada por: TY]
**Tests:** [unit/e2e/integration/none]
**Gate:** [quick/full/build]

### Pre-Implementation (OBRIGATORIO)

- **Premissas:** [declarar explicitamente]
- **Arquivos a tocar:** [listar APENAS estes]
- **Criterio de sucesso:** [como verificar]

### RED: Escrever Tests

- Arquivo(s) de teste: [paths]
- Contagem de tests: [N casos de teste]
- Confirmado falhando: [Sim - todos N tests falham como esperado]

### GREEN: Implementar

[Escrever codigo minimo para passar tests]

- Tests modificados: Nenhum
- Tests skipped/deleted: Nenhum

### VERIFY: Gate Check

- Comando: [comando do gate check]
- Resultado: [X passed, 0 failed]
- Contagem de testes: [N - bate com fase RED]

### Post-Gate

- [x] Sem SPEC_DEVIATION (ou marcadores adicionados)
- [x] Sem mudancas desnecessarias
- [x] Bate com padroes existentes

**Status:** OK Complete | X Blocked | ATENCAO Partial
```

---

## Tips

- **Uma task por vez** - Foco previne erros
- **Ferramentas importam** - MCP errado = abordagem errada
- **Reutilizacoes poupam tokens** - Copie padroes, nao reinvente
- **Cheque antes de commit** - Verifique todos os criterios, depois commit
- **Mantenha cirurgico** - Toque apenas no necessario
- **Commit por task** - Historico git limpo permite bisect e rollback
- **Nunca "ja que estou aqui"** - Scope creep durante implementacao e o #1 quality killer
- **Aprenda dos erros** - Se algo deu errado, adicione Lesson Learned ao STATE.md

---

## Adaptacoes especificas Hapvida

- **Conventional Commits + prefixo `WI-####:`** - obrigatorio em Java/.NET; replicado no
  cabecalho do procedure em PL/SQL (CVS)
- **Snapshot via MCP no Approved** - apos completar todas as tasks da spec, TL aciona prompt file
  para anexar `spec.md`, `design.md` e `tasks.md` consolidados ao work item ADO
- **Skills SIGO** - quando implementando refatoracao PL/SQL, prefira skills `plsql-oracle-expert`
  para code review e `sigo-modernizacao-plsql` para validacao contra baseline
- **[GUARDRAIL] WinCVS tag PRODUCAO** - sempre como base code para PL/SQL; nunca consultar banco
  produtivo via MCP
- **[GUARDRAIL] Anonimizacao** - dados de beneficiario sempre anonimizados em tests, mock,
  fixtures, prompts
