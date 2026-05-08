---
mode: 'agent'
description: 'Criar spec.md a partir de um work item ADO existente'
---

> **[HAP-SDD]** Hapvida Desenvolvimento Spec-Driven · [`SKILL.md`](../SKILL.md)

# Tarefa

Criar `.specs/features/[feature]/spec.md` a partir do work item ADO especificado.

# Input esperado

- ID do work item (`work_item_id`)
- Nome da feature (slug, sera usado como diretorio)

# Passos

1. Use o MCP `@azure-devops/mcp` (`wit_get_work_items_by_id`) para obter o work item completo
2. Extraia: titulo, descricao, demand_type, value_area, area_solicitante, criticidade,
   campos customizados (Lecom ID, ServiceNow INC, etc), Acceptance Criteria
3. Determine o template aplicavel pela matriz Demand Type x Value Area
4. Crie diretorio `.specs/features/[feature]/`
5. Gere `spec.md` usando o template, preenchendo:
   - Frontmatter YAML com metadados extraidos
   - Secoes do template ate onde os dados do work item permitem
   - Marcacoes `[REVISAO]` em secoes que exigem input adicional do TL
6. Aplique a Knowledge Verification Chain (`references/knowledge-verification.md`)
7. Confirme com o TL: "Spec inicial criada em `.specs/features/[feature]/spec.md`. Posso comecar
   a fazer perguntas para preencher as lacunas?"

# Guardrails

- `[GUARDRAIL]` Citar ADRs aplicaveis via `[REF: ADR-XX]` - se decisao sem ADR, marcar `[ADR-AUSENTE]`

# Output

Arquivo `.specs/features/[feature]/spec.md` criado, com confirmacao ao TL e proximos passos.
