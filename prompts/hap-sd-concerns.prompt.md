---
mode: 'agent'
description: 'Documentar tech debt, areas frageis, gaps de cobertura e ADRs ausentes em CONCERNS.md'
---

> **[HAP-SDD]** Hapvida Desenvolvimento Spec-Driven · [`SKILL.md`](../SKILL.md)

# Tarefa

Analisar o codebase e produzir ou atualizar `.specs/codebase/CONCERNS.md` com tech debt,
areas frageis, gaps de testes e ADRs ausentes.

# Input esperado

- **Escopo da analise** - modulo, package, servico ou codebase completo
- **Stack** - para direcionar o tipo de analise (PL/SQL, Java, .NET)

# Passos

1. **Analisar o codebase** (graceful degradation: `ast-grep` > `ripgrep` > `grep`):
   - Identificar rotinas/classes sem testes
   - Identificar alto acoplamento, logica duplicada, tratamento de excecao inconsistente
   - Para PL/SQL: identificar packages sem utPLSQL, cursores implicitos, SQL nao-parametrizado
   - Para Java/.NET: identificar classes God Object, dependencias ciclicas, ausencia de interfaces

2. **Identificar touchpoints regulatorios** sem documentacao formal (`[ANS]` `[REVISAO]`)

3. **Verificar ADRs aplicaveis** - decisoes tecnicas em uso sem ADR corporativa → `[ADR-AUSENTE]`

4. **Produzir `.specs/codebase/CONCERNS.md`** com a estrutura:

   ```markdown
   # Concerns

   **Last updated:** YYYY-MM-DD

   ## Areas frageis (cuidado ao tocar)

   | Area | Por que fragil | Impacto se quebrar |
   |---|---|---|
   | [rotina/classe] | [motivo] | [consequencia] |

   ## Tech Debt

   ### TD-001: [titulo curto]
   - **Localizacao:** [path]
   - **Descricao:** [problema]
   - **Impacto:** [como afeta evolucao]
   - **Esforco estimado:** P/M/G
   - **Plano de pagamento:** [quando enderecar]

   ## Gaps de cobertura de testes

   | Componente | Cobertura atual | Desejada | Gap |
   |---|---|---|---|

   ## ADRs ausentes ([ADR-AUSENTE])

   | Decisao em uso | Sem ADR formal | Proposto |
   |---|---|---|

   ## Riscos regulatorios ([ANS])

   | Regra | Norma | Status |
   |---|---|---|
   ```

5. **Para PL/SQL**: atualizar tambem `.specs/codebase/knowledge-base/riscos-ans.md` se
   forem identificados novos riscos regulatorios.

6. **Resumo ao TL** com os 3-5 concerns mais criticos e recomendacoes de priorizacao.

# Guardrails

- `[GUARDRAIL]` Nao inventar comportamentos - prefira `[REVISAO] confirmar com DBA/Arquiteto`

# Output

`.specs/codebase/CONCERNS.md` criado/atualizado com tech debt catalogado e priorizado.
