---
mode: 'agent'
description: 'Capturar gray areas de uma feature - produz context.md com decisoes de comportamento user-facing'
---

> **[HAP-SDD]** Hapvida Desenvolvimento Spec-Driven · [`SKILL.md`](../SKILL.md)

# Tarefa

Capturar COMO o usuario imagina a feature nas areas ambiguas, produzindo
`.specs/features/[feature]/context.md`. Normalmente disparado automaticamente durante Specify,
mas pode ser invocado diretamente via "discuss feature" ou "capture context".

# Quando usar

- Spec tem comportamento user-facing que pode ir de multiplas formas E o usuario nao expressou
  preferencia
- NAO usar para: trabalho de infraestrutura, CRUD simples, contratos de API bem-definidos,
  refatoracao PL/SQL pura, mudancas regulatorias estritas

# Input esperado

- **Feature em foco** (nome/slug ou path do `spec.md`)
- `spec.md` deve existir em `.specs/features/[feature]/`

# Passos

1. **Ler `.specs/features/[feature]/spec.md`** e identificar areas ambiguas por dominio:
   - Algo que usuarios **VEEM**: layout, estados vazios, hierarquia visual
   - Algo que usuarios **CHAMAM** (API): formato de resposta, erros, auth
   - Algo que usuarios **RODAM** (CLI): flags, output, verbosidade
   - Algo sendo **ORGANIZADO**: criterios de agrupamento, naming, duplicates

2. **Apresentar 3-4 gray areas especificas** a esta feature (nao categorias genericas).
   Deixar o usuario escolher quais discutir.

3. **Deep-dive em cada area selecionada**:
   - Apresente o tradeoff real (nao opcoes falsas)
   - Compartilhe sua perspectiva com razao
   - Registre a decisao do usuario

4. **Criar `.specs/features/[feature]/context.md`** com as decisoes capturadas:

   ```markdown
   # Context - [feature]

   **Data:** YYYY-MM-DD
   **Participantes:** [TL, usuarios consultados]

   ## Decisoes de gray areas

   ### GA-001: [titulo da gray area]

   **Contexto:** [por que e ambiguo]
   **Opcoes consideradas:** [A vs B vs C]
   **Decisao:** [o que foi escolhido]
   **Razao:** [motivacao]
   **Implicacoes para Design/Tasks:** [como impacta a implementacao]

   [repetir para cada gray area]
   ```

5. **Confirmar com o TL** e orientar: "context.md criado. Proximo passo: Design ou Tasks."

# Guardrails

- `[GUARDRAIL]` Decisoes de `context.md` alimentam Design e Tasks - nao improvise alem do que
  o usuario expressou

# Output

Arquivo `.specs/features/[feature]/context.md` criado com decisoes documentadas.
