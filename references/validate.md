# Validate

**Goal:** Verificar que a implementacao atende a spec E os principios de coding. Esta NAO e uma fase
separada - verificacao e parte de cada task dentro de Execute.

**Dois niveis de verificacao:**

1. **Verificacao por task (sempre):** apos implementar cada task, verifique seus criterios de "Done
   when" antes de commitar. Mandatorio e automatico.

2. **Validacao em nivel de feature (na conclusao ou sob demanda):** apos todas as tasks da feature
   (ou grupo de prioridade) estarem feitas, rode validacao abrangente. Inclui check de criterios de
   aceitacao, code quality review e opcionalmente UAT interativo.

**UAT Interativo e disparado quando:** A feature tem comportamento user-facing complexo onde
julgamento humano importa (UI flows, padroes de interacao, design visual). Para trabalho backend
ou de infraestrutura, checks automatizados sao suficientes.

**Trigger para validacao explicita:** "Validate", "verify work", "UAT", "test with me",
"walk me through it"

## Adaptacoes Hapvida em relacao ao TLC original

| Item | TLC | Hapvida |
|---|---|---|
| Per-task verification | Mandatorio | Idem |
| Test Integrity Check | Sim | Idem |
| Severity inference | TLC tem | Idem |
| Generate Fix Plans | TLC tem | Idem |
| Cadeia ate producao | TLC para no merge | `[ADAPTACAO]` Cadeia: Resolved -> Homologation -> Ready for Production -> GMUD aprovada -> Closed |
| GMUD (CHG) | Nao se aplica | `[ADAPTACAO]` Numero da GMUD obrigatorio para transicao a Ready for Production |
| Test Cases ADO | Nao se aplica | `[ADAPTACAO]` Acceptance Criteria do work item -> Test Cases ADO 1:n |

---

## Process

### 1. Cheque Tasks Completadas

Va por tasks.md:

- [ ] Todas as tasks marcadas como done?
- [ ] Alguma blocked ou partial?

### 2. Verifique Criterios de Aceitacao

Para cada user story em spec.md:

```markdown
### P1: [Story Title]

**Acceptance Criteria:**

| ID | Criterio | Resultado |
|---|---|---|
| FEAT-01 | WHEN [X] THEN [Y] | OK PASS / X FAIL |
| FEAT-02 | WHEN [A] THEN [B] | OK PASS / X FAIL |
```

Sincronize com Test Cases ADO correspondentes.

### 3. Cheque Edge Cases

Do spec.md edge cases:

- [ ] [Edge case 1] tratado corretamente
- [ ] [Edge case 2] tratado corretamente

### 4. Rode Build-Level Gate Check (OBRIGATORIO)

Rode o gate check Build-level do TESTING.md. Isso NAO e opcional.

Se TESTING.md nao existe (projeto greenfield), use o comando de gate combinado com o usuario
durante a fase Tasks.

1. Rode: `[comando de gate Build do TESTING.md]`
2. Codigo de saida diferente de zero = PARE. Nao prossiga para Code Quality Check.
3. Registre resultados:
   - Contagem total de tests: [N]
   - Passados: [N]
   - Falhados: [lista]
   - Skipped: [lista - cada skip deve ter justificativa]

**Test Integrity Check:**

- Compare a contagem atual de tests com a contagem antes da feature ser implementada
- Se contagem DIMINUIU: investigue por que. Tests so devem ser deletados com justificativa
  explicita.
- Se assertions foram enfraquecidas (menos especificas que antes): flag como potencial regressao

### 5. Code Quality Check (OBRIGATORIO)

Para cada arquivo alterado, verifique contra [coding-principles.md](coding-principles.md):

| Check | Pass? |
|---|---|
| Sem features alem do solicitado | |
| Sem abstracoes para codigo de uso unico | |
| Sem "flexibilidade" desnecessaria | |
| So tocou arquivos exigidos pela task | |
| Nao "melhorou" codigo nao relacionado | |
| Bate com padroes/estilo existentes | |
| Engenheiro senior aprovaria? | |

X Algum "Nao"? -> Conserte antes de marcar completo.

### 6. UAT Interativo (se feature user-facing)

Para cada deliverable testavel, apresente um teste por vez:

```
Test [N]: [Nome do Teste]

Expected: [O que deveria acontecer - especifico e observavel]

-> Funciona? Descreva o que voce ve.
```

Aguarde resposta do usuario:

| Usuario diz | Interprete como |
|---|---|
| "yes", "pass", "works", "next" | OK Pass |
| "skip", "can't test", "n/a" | SKIP |
| Qualquer outra coisa | X Issue - log verbatim |

**Inferencia de severidade (nunca pergunte severidade ao usuario):**

| Descricao do usuario contem | Severidade inferida |
|---|---|
| crash, error, exception, fails, broken | Blocker |
| doesn't work, wrong, missing, can't | Major |
| slow, weird, off, minor, small | Minor |
| color, font, spacing, alignment, visual | Cosmetic |
| (nao claro) | Major (default) |

### 7. Gere Fix Plans (se issues encontradas)

Para cada issue encontrada durante UAT:

1. **Diagnose** - analise codebase para encontrar causa raiz
2. **Crie task de fix** - escreva uma definicao de task com:
   - O que: o fix especifico
   - Onde: paths de arquivo
   - Verify: como provar que o fix funciona
   - Done when: criterios de aceitacao para o fix
3. **Apresente fix plan** - mostre todas as fix tasks ao usuario para aprovacao

Fix tasks seguem o mesmo formato de tasks regulares e podem ser executadas com o fluxo Execute.

**Guardrail:** Maximo 3 iteracoes diagnosticas por issue. Se causa raiz nao for encontrada apos
3 tentativas, flag para investigacao humana.

### 8. (Hapvida) Validacao de cadeia ate producao

Para o framework Hapvida, a validacao se estende ate producao:

| Estado ADO | Validacao especifica |
|---|---|
| Resolved | Tasks completas, gate Build passou |
| Homologation | Test Cases ADO executados em ambiente HML, evidencias anexadas |
| Ready for Production | GMUD (CHG) aprovada e numero registrado no campo do work item; spec atendida |
| Closed | Em producao, monitoramento ok, ciclo encerrado |

A spec do framework esta **atendida** quando: estado = Closed + sem rollback + criterios de
aceitacao validados.

### 9. Reportar

Use o template abaixo.

---

## Template do Relatorio de Validacao

```markdown
# [Feature] Validacao

**Date:** YYYY-MM-DD
**Spec:** `.specs/features/[feature]/spec.md`

---

## Task Completion

| Task | Status | Notas |
|---|---|---|
| T1 | OK Done | - |
| T2 | OK Done | - |
| T3 | ATENCAO Partial | [Issue] |

---

## User Story Validation

### P1: [Story Title] - MVP

| Criterio | Resultado |
|---|---|
| FEAT-01 WHEN X THEN Y | OK PASS |
| FEAT-02 WHEN A THEN B | OK PASS |

**Status:** OK P1 Complete

### P2: [Story Title]

| Criterio | Resultado |
|---|---|
| FEAT-03 WHEN X THEN Y | X FAIL - [reason] |

**Status:** ATENCAO P2 Issues

---

## Interactive UAT Results (se realizado)

| # | Test | Result | Details |
|---|---|---|---|
| 1 | [Test name] | OK Pass | - |
| 2 | [Test name] | X Issue | [Verbatim user response] - Severidade: [inferida] |
| 3 | [Test name] | SKIP | [Reason] |

---

## Code Quality

| Principio | Status |
|---|---|
| Codigo minimo | OK |
| Mudancas cirurgicas | OK |
| Sem scope creep | OK |
| Bate com padroes | OK |

---

## Edge Cases

- [x] EC-01: Handled corretamente
- [ ] EC-02: NAO handled - precisa fix

---

## Tests

- **Gate command:** [comando completo]
- **Resultado:** [X] passed, [Y] failed, [Z] skipped
- **Contagem antes da feature:** [N]
- **Contagem apos feature:** [M]
- **Delta:** [+(M - N) novos tests]
- **Skipped tests:** [lista com justificativa]
- **Failures:** [lista com detalhes]

---

## Test Cases ADO mapeados

| Acceptance Criterion (spec) | Test Case ADO | Resultado |
|---|---|---|
| FEAT-01 | TC-#### | OK Passed |
| FEAT-02 | TC-#### | OK Passed |
| FEAT-03 | TC-#### | X Failed |

---

## Cadeia ate producao (Hapvida)

| Marco | Status | Data | Evidencia |
|---|---|---|---|
| Resolved | OK | YYYY-MM-DD | Build #N |
| Homologation iniciada | OK | YYYY-MM-DD | Pipeline ADO #N (Java/.NET) ou registro manual (PL/SQL) |
| Test Cases HML executados | OK | YYYY-MM-DD | Evidencia anexada ao work item |
| Ready for Production | OK | YYYY-MM-DD | GMUD CHG-##### aprovada |
| Closed | Pending | - | - |

---

## Fix Plans (se issues encontradas)

### Fix 1: [Descricao do issue]

- **Causa raiz:** [O que esta realmente errado]
- **Fix task:** [Definicao da task]
- **Prioridade:** [Blocker/Major/Minor/Cosmetic]

---

## Atualizacao de Requirement Traceability

Atualize statuses do spec.md:

| Requirement | Status anterior | Novo status |
|---|---|---|
| FEAT-01 | Implementing | OK Verified |
| FEAT-02 | Implementing | X Needs Fix |

---

## Resumo

**Geral:** OK Ready | ATENCAO Issues | X Not Ready

**O que funciona:** [Lista]

**Issues encontradas:** [Issue 1: Como consertar]

**Proximos passos:** [Acao]
```

---

## Tips

- **P1 primeiro** - MVP precisa funcionar antes de P2/P3
- **WHEN/THEN = Test** - Cada criterio e um caso de teste
- **Seja especifico** - "Nao funciona" nao ajuda
- **Recomende fixes** - Nao so reporte problemas, crie fix tasks
- **Quality check e mandatorio** - Nao opcional
- **Inferir severidade** - Nunca pergunte ao usuario "quao ruim e isso?"
- **Maximo 3 iteracoes diagnosticas** - Previne loops infinitos de investigacao
- **Atualize traceability** - Cada requirement verificado atualiza status do spec.md

---

## Adaptacoes especificas Hapvida

- Validacao se estende ate Closed (em producao), nao apenas Resolved
- GMUD (CHG) aprovada e gate especifico para Ready for Production
- Test Cases ADO sao a evidencia primaria de criterios atendidos
- Para refatoracao PL/SQL: a Ficha de Tunning (Tempo Pre/Pos-Melhoria) e validacao automatica do
  ganho - registre numeros reais ao validar
- Para Incident derivado de Implementacao Recente: o ciclo de validacao alimenta o loop de
  retroalimentacao do framework (atualizar template/checklist da Feature de origem se houver gap)
