---
applyTo: ".specs/**/*.md"
---

# Instructions for files in .specs/

Para qualquer arquivo `.md` em `.specs/`:

- **Frontmatter YAML obrigatorio** em spec.md (ver templates/)
- **Tokens textuais** sem emojis - use `[ANS]`, `[REVISAO]`, `[BLOQUEADO]`, `[REF: ...]`, etc
- **Citacao de ADRs** via `[REF: ADR-XX]` aponta para Wiki Arquitetura-Referencia
- **Decisao sem ADR aplicavel** -> marcar `[ADR-AUSENTE]` e propor ADR antes de avancar
- **Regulatorio** -> `[ANS]` + citacao de norma especifica (Lei 9.656/98 art. X, RN ##### art. Y)
- **PII** -> anonimizar antes de salvar/commit
- **WHEN/THEN/SHALL** em Acceptance Criteria
- **IDs de Requirement Traceability** (FEAT-NN, EC-NN, RN-NN)
