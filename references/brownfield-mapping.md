# Brownfield Mapping

**Goal:** Mapear codebase existente em 7 documentos para que o framework opere com contexto real.

**Trigger:** "Map codebase", "analyze existing code", "document our system"

## Adaptacoes Hapvida em relacao ao TLC

| Item | TLC | Hapvida |
|---|---|---|
| 7 documentos em `.specs/codebase/` | Idem | Idem |
| Codigo PL/SQL legado | Generico | `[ADAPTACAO]` Use skill `sigo-modernizacao-plsql` quando disponivel; baseline da tag PRODUCAO |
| Stack analysis | Generico | `[ADAPTACAO]` Identifica explicitamente bi-VCS (CVS para PL/SQL, Git para Java/.NET) |

## Os 7 documentos

| # | Arquivo | Foco | Tamanho tipico |
|---|---|---|---|
| 1 | `STACK.md` | Linguagens, frameworks, libraries, versoes | 1-3k tokens |
| 2 | `ARCHITECTURE.md` | Componentes principais, fluxo de dados, dependencias entre modulos | 3-5k tokens |
| 3 | `STRUCTURE.md` | Layout de pastas, convencoes de naming, organizacao de modulos | 2-4k tokens |
| 4 | `CONVENTIONS.md` | Padroes de codigo, estilo, comentarios, idiomas Hapvida | 2-4k tokens |
| 5 | `TESTING.md` | Frameworks de teste, Test Coverage Matrix, Gate Check Commands, Parallelism Assessment | 3-5k tokens |
| 6 | `INTEGRATIONS.md` | APIs externas, integracoes (ServiceNow, Lecom, GMUD, sistemas internos) | 2-4k tokens |
| 7 | `CONCERNS.md` | Tech debt, areas frageis, gaps de cobertura, ADRs ausentes | 2-4k tokens |

## Process

1. **Analisar o codebase** - usando `ast-grep` > `ripgrep` > `grep` (graceful degradation)
2. **Para PL/SQL legado**: skill `sigo-modernizacao-plsql` para extracao de regras e mapeamento
3. **Para Java/.NET**: usar AST do tooling de cada stack
4. **Gerar os 7 documentos** com descobertas
5. **Identificar lacunas** -> criar `[REVISAO]` markers em areas confusas
6. **Validar com TL e Arquiteto** antes de marcar como base de trabalho

## TESTING.md - estrutura especial (matriz hibrida stack-agnostic)

A estrutura abaixo segue o modelo definido em
[ADR-013](../adr/013-modelo-testes-co-localizado-por-task.md). Cada squad declara seu
**tooling especifico** por approach; o schema (Approach / Coverage Matrix / Gate Check /
Parallelism) e estavel.

```markdown
# Testing

## Tooling por approach

Declarar **por stack do squad**. Exemplos validos:

| Approach | Stack | Tooling sugerido | Default artifact path |
|---|---|---|---|
| `automated` | PL/SQL | Scripts `.sql` executaveis via MCP Oracle (DEV) | `.specs/features/[feature]/tests/verifica_<nome>.sql` |
| `automated` | Java/Spring | JUnit 5 + Mockito (`Test*.java`); RestAssured/MockMvc (`*IT.java`) | `.specs/features/[feature]/tests/<Nome>Test.java` |
| `automated` | .NET | xUnit + Moq (`<Nome>Tests.cs`); WebApplicationFactory (`<Nome>IntegrationTests.cs`) | `.specs/features/[feature]/tests/<Nome>Tests.cs` |
| `automated` | Frontend | Jest/Vitest + Testing Library (`<nome>.test.tsx`); Playwright/Cypress (`*.spec.ts`) | `.specs/features/[feature]/tests/<nome>.test.tsx` |
| `manual` | Qualquer | Procedimento documentado em markdown com passos numerados | `.specs/features/[feature]/tests/procedimento_<nome>.md` |
| `hybrid` | Qualquer | Combinacao: script automated + procedimento manual | Ambos paths |
| `none` | Qualquer | Sem artifact (doc / refactor sem mudanca de comportamento) | `N/A` no campo Tests Artifact |

## Test Coverage Matrix

Define qual **Approach** e exigido por camada de mudanca. Substitui o schema antigo
`unit/integration/e2e/none`.

| Camada de mudanca | Approach default | Co-located? | Notas |
|---|---|---|---|
| [ex: Service / Business Logic Java] | `automated` | Sim | JUnit 5 + Mockito |
| [ex: API Controllers] | `automated` | Sim | RestAssured ou MockMvc |
| [ex: Persistencia / Repository] | `automated` | Sim | Testcontainers (banco real isolado) |
| [ex: Stored Procedures / Packages PL/SQL] | `automated` | Sim | Script `.sql` executavel via MCP Oracle |
| [ex: Trigger / Constraint / Indice PL/SQL] | `automated` | Sim | Script `.sql` confirmando estado pos-DDL |
| [ex: Forms `.fmb` / UI Oracle] | `manual` | Sim | Procedimento `.md` com screenshot |
| [ex: UI Web (Thymeleaf / React / Blazor)] | `manual` ou `automated` | Sim | Procedimento OU Playwright/Cypress |
| [ex: Configuracao / DTOs / Constantes] | `none` | - | Justificar em Evidence |

## Gate Check Commands

Comandos executaveis para approach `automated`. Manual usa "Evidence registrada".

| Nivel | Approach | Comando / Verificacao |
|---|---|---|
| Quick | automated | `[comando que roda subset rapido — ex: ./mvnw test -Dtest='*Spec*' -q]` |
| Full | automated | `[comando que roda suite completa — ex: ./mvnw verify]` |
| Build | automated | `[comando final pre-merge — ex: ./mvnw clean verify -P all-tests]` |
| Quick/Full/Build | manual | Evidence anexada em tasks.md (screenshot path + assinatura do dev) |
| Quick/Full/Build | hybrid | Comando automated retorna exit 0 **E** Evidence manual anexada |
| Quick/Full/Build | none | Justificativa em Evidence (refactor/doc sem mudanca de comportamento) |

## Parallelism Assessment

Tipo de teste que **executa concorrentemente em CI/MCP/maquina do dev sem race condition**.

| Approach + escopo | Parallel-Safe |
|---|---|
| automated unit (sem estado compartilhado) | Yes |
| automated integration com banco mock / em memoria | Yes |
| automated integration com banco real compartilhado (DEV unico) | No |
| automated end-to-end (UI compartilhada) | No |
| automated PL/SQL via MCP em schema compartilhado | No (banco unico) |
| manual | No (humano sequencial) |
| hybrid | Dominado pelo lado nao-paralelo |
```

> **Stack-agnostic:** as linhas da `Test Coverage Matrix` acima sao exemplos. Cada squad popula
> a sua matriz com as camadas reais que existem em seu repo, usando o tooling do `Tooling por
> approach`. O **schema** (colunas + valores de Approach + path padronizado em `tests/`) e
> estavel e nao depende de stack.

## Adaptacoes especificas Hapvida

- Para PL/SQL: STACK.md identifica versao Oracle, packages corporativos, DBMS_*/UTL_* usados
- Para Java/.NET: STACK.md identifica versoes, frameworks, libraries da ADR 24 homologadas
- INTEGRATIONS.md cobre obrigatoriamente: ServiceNow (Incidents), Lecom (BPM), GMUD (CHG), SACTI

## Camada complementar - Knowledge base e RE por rotina

Alem dos 7 docs de mapeamento macro, projetos com legado PL/SQL devem materializar:

```
.specs/codebase/knowledge-base/
  indice.md                          # navegacao
  catalogo-conceitos-negocio.md      # CN-XX canonicos do dominio
  catalogo-objetos-plsql.md          # objetos PL/SQL ja analisados + tags CVS
  pendencias-abertas.md              # ambiguidades em revisao com PO/DBA
  riscos-ans.md                      # riscos regulatorios consolidados

.specs/reverse-engineering/
  README.md                          # convencao de naming
  plsql/                             # segregacao por tipo (ADR-011)
    <NOME_OBJETO>/                   # uma pasta por rotina mapeada
      README-rotina.md               # indice de revisoes
      rev-001-<TAG_CVS>/             # numeracao sequencial zero-padded
        reversa-<NOME_OBJETO>.md     # artefato canonico
  forms/                             # modulos Oracle Forms
    <MODULO>/
      README-modulo.md
      rev-001-<TAG_CVS>/
        raw/<MODULO>.xml             # Forms2XML
        parsed/<MODULO>_*.txt        # 12 relatorios (forms-extractor)
        reversa-<MODULO>.md
```

Esta camada e produzida pela skill
[`engenharia-reversa-sigo`](../skills/engenharia-reversa-sigo/SKILL.md) - ver
[`references/reverse-engineering.md`](reverse-engineering.md) e
[ADR-011](../adr/011-engenharia-reversa-como-baseline.md). Substitui releitura de monolitos
PL/SQL a cada nova spec.
- CONCERNS.md alinha com `[ADR-AUSENTE]` markers - decisoes nao formalizadas viram items de
  CONCERNS
