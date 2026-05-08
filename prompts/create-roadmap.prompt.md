---
mode: 'agent'
description: 'Criar ou atualizar o roadmap do squad em .specs/project/ROADMAP.md'
---

Voce e o assistente do Framework Spec-Driven Hapvida v0.2.

# Tarefa

Criar ou atualizar `.specs/project/ROADMAP.md` com a visao de medio prazo do squad:
milestones, features no horizonte e status de execucao.

Referencias canonicas:

- [references/roadmap.md](../references/roadmap.md)
- [references/state-management.md](../references/state-management.md)

# Quando usar

Util quando o squad quer narrativa em prosa alem do ADO Boards, ou quando precisa comunicar
visao de longo prazo separada da execucao tatica. Muitos squads usam Epic + ADO Boards nativos
como roadmap; ROADMAP.md e complementar, nao obrigatorio.

# Input esperado

- **Milestone atual** e objetivo
- **Features planejadas** (Now / Next / Later ou por versao)
- **Links para work items ADO** (Epics/Features correspondentes)

# Passos

1. **Verificar se ROADMAP.md ja existe**:
   - Se sim: ler e perguntar o que atualizar (nova feature, mudanca de status, novo milestone)
   - Se nao: coletar informacoes do TL para construir do zero

2. **Consultar o ADO** via MCP (se disponivel) para confirmar:
   - Features/Epics ativos no board do squad
   - Status atual dos work items mencionados

3. **Estruturar ou atualizar o ROADMAP.md**:

   ```markdown
   # Roadmap - [Nome do Squad]

   **Current Milestone:** [Nome] - [status: Em andamento | Concluido]
   **Target:** [data ou sprint]

   ---

   ## v[N] - [Milestone Title]

   **Goal:** [o que sera entregue]

   ### Features

   **[Feature 1]** - [STATUS] ([ADO: WI-XXXX])
   - [bullet descricao]
   - [bullet descricao]

   **[Feature 2]** - [STATUS] ([ADO: WI-XXXX])
   - [bullet descricao]

   ---

   ## v[N+1] - [Proximo Milestone]

   **Goal:** [o que sera entregue]

   ### Features
   [mesma estrutura]

   ---

   ## Future Considerations

   - [Ideia capturada para avaliar depois]
   ```

4. **Vincular features do roadmap a work items ADO**:
   - Cada feature deve referenciar o Epic ou Feature ID no ADO (`WI-XXXX`)
   - Features em execucao: linkar tambem a `spec.md` em `.specs/features/`

5. **Atualizar STATE.md** → `Last Updated` se houver mudancas relevantes

6. **Confirmar ao TL** com resumo das atualizacoes feitas.

# Guardrails

- `[GUARDRAIL]` Anonimizar PII de beneficiario se mencionado como contexto
- `[GUARDRAIL]` Features que tocam regulacao ANS → marcar `[ANS]` no roadmap

# Output

`.specs/project/ROADMAP.md` criado ou atualizado com visao de medio prazo do squad.
