# Changelog

Todas as mudancas relevantes do framework sao documentadas neste arquivo.

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).
Versionamento segue [Semantic Versioning 2.0.0](https://semver.org/lang/pt-BR/).

---

## [0.2.0] - 2026-05-06

### Adicionado

- 4 fases adaptativas (Specify, Design, Tasks, Execute) com auto-sizing por escopo
- 6 templates de spec por matriz Demand Type x Value Area do Agile Hapvida 2.0:
  - `spec-project-business`, `spec-improvement-business`, `spec-improvement-tunning`,
    `spec-maintenance-business`, `spec-maintenance-tunning`, `spec-incident-fast-track`
- Spec versionada em ADO Repos Git (Opcao B) como fonte da verdade
- Snapshot da spec anexado ao work item via MCP do Azure DevOps em estado `Approved`
- Knowledge Verification Chain adaptada Hapvida (CVS PRODUCAO/Git -> Wiki Arq-Ref ADRs ->
  Context7 -> Web -> Flag)
- 9 ADRs do framework documentando decisoes arquiteturais
- 7 prompt files prontos para Copilot Agent Mode (`.prompt.md`)
- Glossario inicial com 4 secoes (geral, comercial, regulatorio ANS, mapeamento legado)
- STATE.md obrigatorio em projeto individual (memoria persistente)
- Conventional Commits 1.0.0 com prefixo `WI-####:` para Java/.NET e cabecalho de
  comentario padronizado para PL/SQL no CVS
- Tokens textuais sem emojis: `[ATENCAO]`, `[BLOQUEADO]`, `[REVISAO]`, `[ANS]`,
  `[REF: ...]`, `[ADR-AUSENTE]`, `[MIGRACAO]`, `[GUARDRAIL]`, `[OK]`, `[PREMISSA]`,
  `[ADAPTACAO]`
- `.github/copilot-instructions.md` e instructions especificas para specs e ADRs
- Exemplo end-to-end de feature `exemplo-cotacao-pme` (spec + context + design + tasks)
- Exemplos de codebase brownfield (STACK.md, CONCERNS.md, README.md)
- Validate adaptado para cadeia Hapvida: Resolved -> Homologation -> Ready for
  Production -> GMUD aprovada -> Closed
- Camada fina sobre Agile Hapvida 2.0 - sem alteracoes estruturais nos 211 projetos

### Adaptacoes em relacao ao TLC Spec-Driven 2.0.0 (base)

- Brownfield mapping menciona dois mundos VCS: WinCVS tag PRODUCAO (PL/SQL) e ADO
  Repos Git (Java/.NET)
- Quick Mode marcado como fora do escopo do piloto (ADR 008)
- Sub-agents do TLC mapeados para Copilot Agent Mode com MCP do Azure DevOps
- Skills SIGO recomendadas como prioridade no fluxo PL/SQL: `sigo-modernizacao-plsql`,
  `sigo-refatoracao-workflow`, `plsql-oracle-expert`
- Citacao obrigatoria de ADRs corporativas da Wiki "Arquitetura-Referencia" (96+ ADRs)
- LGPD e sigilo medico como guardrails inegociaveis em toda spec
- Marcadores `[ANS]` e `[MIGRACAO]` integrados a templates e validacoes

### Restricoes do piloto v0.2

- Sem pipeline ADO de validacao de spec (validacao via prompt file Copilot Agent)
- Sem migracao do PL/SQL para Git (mantido em WinCVS por decisao de plataforma)
- Sem alteracao no processo Agile Hapvida 2.0 (camada fina apenas)
- Quick Mode fora do escopo (reavaliar para v0.4)

---

## Roadmap

### v0.3 - Ajustes pos-piloto Onda 1 (Q3/2026)

Ajustes baseados em feedback dos ~30 tech leads do piloto Comercial.

### v0.4 - Escala Onda 2 (Q4/2026)

- Treinamento e enablement para ~120 devs+QAs
- Templates revisados com aprendizados da Onda 1
- Possivel reintroducao de Quick Mode (a confirmar com base no piloto)

### v0.5 - Pipeline ADO de validacao (TBD)

- Pipeline ADO que valida specs em PR (linter, schema do frontmatter, citacoes)
- Snapshot automatico em pipeline (alternativa ao acionamento via Copilot)

---

## Base

Este framework e uma adaptacao corporativa de **TLC Spec-Driven** (Tech Lead's Club),
versao base 2.0.0, sob licenca CC-BY-4.0. Repositorio original:
https://github.com/tech-leads-club
