---
mode: 'agent'
description: 'Criar spec.md a partir de um documento Lecom (BPM corporativo)'
---

> **[HAP-SDD]** Hapvida Desenvolvimento Spec-Driven · [`SKILL.md`](../SKILL.md)

# Tarefa

Criar spec.md a partir de um documento Lecom anexado pelo TL.

# Input esperado

- Path do documento Lecom (PDF, DOCX, ou texto colado pelo TL)
- ID do work item ADO destino

# Passos

1. Leia o documento Lecom (use skills `pdf` ou `docx` se disponiveis)
2. Extraia: contexto, regras de negocio, criterios de aceitacao, stakeholders, anexos referenciados
3. Aplique Knowledge Verification Chain - citar ADRs aplicaveis
4. Gere spec.md no template aplicavel (matriz Demand Type x Value Area)
5. Vincule ao work item via campo `rastreio.lecom_id` no frontmatter

# Guardrails

- `[GUARDRAIL]` Marcar `[REVISAO]` em interpretacoes que nao estao explicitas no Lecom

# Output

Arquivo spec.md gerado + confirmacao + proximos passos.
