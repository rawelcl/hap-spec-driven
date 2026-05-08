---
mode: 'agent'
description: 'Registrar decisao, blocker ou todo no STATE.md do squad'
---

> **[HAP-SDD]** Hapvida Desenvolvimento Spec-Driven · [`SKILL.md`](../SKILL.md)

# Tarefa

Atualizar `.specs/project/STATE.md` com uma nova decisao local (AD-NNN), blocker (B-NNN),
licao aprendida (L-NNN) ou item de acompanhamento.

# Input esperado

Diga o que quer registrar - o agente identifica o tipo automaticamente:

- **"Decidimos usar X porque Y"** → Decisao local (AD-NNN)
- **"Estou bloqueado por X"** → Blocker (B-NNN)
- **"Aprendi que X causa Y"** → Licao aprendida (L-NNN)
- **"Ideia para depois: X"** → Deferred Idea
- **"Feito: X (commit: Y)"** → Quick Task Completed

# Passos

1. **Ler `.specs/project/STATE.md`** para entender o contexto atual e obter o proximo
   numero sequencial (AD-NNN, B-NNN, L-NNN)

2. **Identificar o tipo de registro** pelo input do TL

3. **Redigir a entrada** com a estrutura adequada:

   Para decisao (AD-NNN):
   ```markdown
   ### AD-[NNN]: [titulo] ([data])
   **Decision:** [o que foi decidido]
   **Reason:** [por que]
   **Trade-off:** [o que foi sacrificado]
   **Impact:** [como afeta implementacao]
   **Tipo:** local | escalar-para-corporativo
   ```

   Para blocker (B-NNN):
   ```markdown
   ### B-[NNN]: [descricao]
   **Discovered:** [data]
   **Impact:** [severidade e escopo]
   **Workaround:** [solucao temporaria]
   **Resolution:** [caminho para fix]
   **Owner:** [quem resolve]
   ```

   Para licao aprendida (L-NNN):
   ```markdown
   ### L-[NNN]: [descricao]
   **Context:** [situacao que ocorreu]
   **Problem:** [o que deu errado]
   **Solution:** [como foi resolvido]
   **Prevents:** [o que esse aprendizado previne]
   ```

4. **Inserir a entrada** na secao correta do STATE.md e atualizar `Last Updated`

5. **Verificar** se a decisao merece escalar para ADR corporativa:
   - Se impacto for cross-squad ou arquitetural → marcar `Tipo: escalar-para-corporativo`
   - Se decisao tecnica sem ADR existente → incluir `[ADR-AUSENTE]` e orientar sobre proposta

6. **Confirmar** ao TL: "Registrado como [AD/B/L]-NNN em STATE.md."

# Output

STATE.md atualizado com o novo registro. `Last Updated` atualizado para hoje.
