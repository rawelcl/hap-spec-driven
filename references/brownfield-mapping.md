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

## TESTING.md - estrutura especial

```markdown
# Testing

## Frameworks
- Java: JUnit 5
- .NET: xUnit
- PL/SQL: utPLSQL (quando disponivel)

## Test Coverage Matrix

| Camada | Tipo de teste | Co-located? |
|---|---|---|
| Service / Business Logic | Unit | Sim |
| API Controllers | Integration | Sim |
| Persistencia | Integration | Sim |
| Stored Procedures (PL/SQL) | utPLSQL ou test manual | Sim quando viavel |
| End-to-end UI | E2E | Separado |
| Configuracao / DTOs | none | - |

## Gate Check Commands

| Nivel | Comando |
|---|---|
| Quick | `./mvnw test -Dtest='*Spec*' -q` |
| Full | `./mvnw verify` |
| Build | `./mvnw clean verify -P all-tests` |

## Parallelism Assessment

| Tipo de teste | Parallel-Safe |
|---|---|
| Unit | Yes |
| Integration (com banco mock) | Yes |
| Integration (com banco real compartilhado) | No |
| E2E | No |
| utPLSQL | No (banco compartilhado) |
```

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
  <NOME_OBJETO>/                     # uma pasta por rotina mapeada
    README-rotina.md                 # indice de revisoes
    rev-<TAG_CVS>/
      reversa-<NOME_OBJETO>.md       # artefato canonico (template)
```

Esta camada e produzida pela skill
[`engenharia-reversa-sigo`](../skills/engenharia-reversa-sigo/SKILL.md) - ver
[`references/reverse-engineering.md`](reverse-engineering.md) e
[ADR-011](../adr/011-engenharia-reversa-como-baseline.md). Substitui releitura de monolitos
PL/SQL a cada nova spec.
- CONCERNS.md alinha com `[ADR-AUSENTE]` markers - decisoes nao formalizadas viram items de
  CONCERNS
