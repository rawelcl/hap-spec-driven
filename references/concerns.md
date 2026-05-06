# Concerns Documentation

**Goal:** Documentar tech debt, areas frageis, gaps de cobertura e ADRs ausentes.

**Trigger:** "Document concerns", "find tech debt", "what's fragile here?"

**Output:** `.specs/codebase/CONCERNS.md`

## Adaptacoes Hapvida

- Foco especial em codigo PL/SQL legado (idade, ausencia de testes, acoplamento)
- ADRs Hapvida ausentes flagged como `[ADR-AUSENTE]`
- Touchpoints regulatorios sem documentacao flagged como `[ANS]` `[REVISAO]`

## Estrutura

```markdown
# Concerns

**Last updated:** YYYY-MM-DD

---

## Areas frageis (cuidado ao tocar)

| Area | Por que fragil | Impacto se quebrar |
|---|---|---|
| `pkg_proposta.calcula_carencia` | 600+ linhas, sem testes, regra ANS critica | Bloquear venda de plano |
| `RecebimentoController.processarPagamento` | Acoplamento com 5 servicos externos | Falha em fluxo de pagamento |

---

## Tech Debt

### TD-001: [titulo curto]

- **Localizacao:** [arquivo/path]
- **Descricao:** [o que esta errado / desatualizado]
- **Impacto:** [como afeta evolucao]
- **Esforco estimado:** [P/M/G]
- **Plano de pagamento:** [quando endereçar]

---

## Gaps de cobertura de testes

| Componente | Cobertura atual | Cobertura desejada | Gap |
|---|---|---|---|
| `pkg_beneficiario` | 0% | 60% | 60pp |

---

## ADRs ausentes (`[ADR-AUSENTE]`)

| Decisao em uso | Sem ADR formal | Proposto |
|---|---|---|
| Padrao de logging em PL/SQL | Cada package faz diferente | Propor ADR de logging unificado |
| Estrategia de cache em Java | Variavel | Propor ADR de cache distribuido |

---

## Touchpoints regulatorios sem documentacao (`[ANS]` `[REVISAO]`)

| Area | Norma aplicavel | Documentacao atual |
|---|---|---|
| Calculo de carencia | Lei 9.656/98 art. 12 | Codigo - sem spec formal |
| Reajuste anual | RN ##### | Comentarios em PL/SQL apenas |
```

## Como gerar CONCERNS.md

1. Pergunte ao TL e devs senior: "Quais areas voces evitam mexer? Por que?"
2. Verifique idade dos arquivos no VCS (CVS log para PL/SQL, git log para Java/.NET)
3. Identifique acoplamento alto via analise estatica
4. Cruze com lista de Incidents recorrentes no ServiceNow
5. Compare ADRs corporativas existentes com decisoes em uso
