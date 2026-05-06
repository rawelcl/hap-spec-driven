# Codebase - Exemplo Brownfield

Esta pasta corresponde ao output do **brownfield mapping** quando aplicado a um codigo
legado existente (ex: pacote PL/SQL grande, sistema .NET legado, modulo Java antigo).

## Quando esta pasta e usada

- Projeto **brownfield** (codigo legado existente que sera modificado/refatorado)
- Disparado pelo comando: "Map codebase" ou "Analise this codebase"
- Output do agente seguindo `references/brownfield-mapping.md`

## Quando NAO e usada

- Projeto **greenfield** (codigo novo do zero) - pular brownfield mapping
- Esta pasta nao e criada se nao houver codigo legado a documentar

## Arquivos esperados (7 documentos)

| Arquivo | Propsito |
|---|---|
| `STACK.md` | Stack tecnologico detectado (versoes, libs, banco) |
| `ARCHITECTURE.md` | Padroes arquiteturais identificados, fluxo de dados |
| `CONVENTIONS.md` | Convencoes de naming, organizacao de codigo, estilo |
| `STRUCTURE.md` | Layout de diretorios e organizacao de modulos |
| `TESTING.md` | Frameworks de teste, cobertura, gate commands |
| `INTEGRATIONS.md` | Servicos externos, APIs, webhooks |
| `CONCERNS.md` | Tech debt, bugs conhecidos, riscos, fragilidades [ANS] |

## Exemplo Hapvida - PL/SQL legado

Para um sistema com baseline em CVS tag PRODUCAO:

- `STACK.md` documenta versao Oracle, packages mais usados, tipos proprietarios
- `ARCHITECTURE.md` mapeia o fluxo da proposta entre packages
- `CONCERNS.md` cataloga god procedures, COMMIT/ROLLBACK disperso, dependencias circulares

## Exemplo Hapvida - .NET/Java moderno

Para um sistema versionado em ADO Repos Git:

- `STACK.md` documenta .NET 8, frameworks, NuGets criticos
- `ARCHITECTURE.md` documenta padrao Repository (ADR 22), DDD (ADR 74)
- `TESTING.md` documenta xUnit, JUnit, gate commands de PR

---

**Nota para o piloto v0.2:** brownfield mapping e **opcional** - so use se a feature
realmente vai modificar codigo legado significativo. Para features novas em sistemas
ja conhecidos pelo time, pular.
