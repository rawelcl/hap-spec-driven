# Changelog

Todas as mudancas relevantes do framework sao documentadas neste arquivo.

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).
Versionamento segue [Semantic Versioning 2.0.0](https://semver.org/lang/pt-BR/).

---

## [0.5.1] - 2026-05-08

### Corrigido / Endurecido

- **`dba_source` explicitamente proibido como fonte de codigo** em todos os artefatos do
  framework. Codigo PL/SQL deve vir exclusivamente do WinCVS tag PRODUCAO. Se o CVS nao
  localizar a versao -> `[BLOQUEADO]` sem fallback. Arquivos atualizados:
  - `.github/copilot-instructions.md`
  - `SKILL.md` (raiz)
  - `adr/007-guardrail-acesso-producao.md` (excecao de `dba_source` removida)
  - `adr/011-engenharia-reversa-como-baseline.md`
  - `skills/engenharia-reversa-sigo/SKILL.md`
  - `prompts/baseline-reverse-engineering.prompt.md`
  - `prompts/baseline-reverse-engineering-forms.prompt.md`
  - `references/prompt-flow.md`, `references/prompt-flow.html`
  - `references/reverse-engineering.md`, `references/knowledge-verification.md`
  - `templates/reverse-engineering-template.md`, `scripts/init-spec-project.ps1`

- **Escopo de anonimizacao precisado**: anonimizacao obrigatoria restrita a **PII de
  beneficiario pessoa fisica** (CPF, nome, matricula, dados de saude). Dados comerciais
  (razao social de empresa, numero de contrato, CNPJ de empresa contratante) **nao precisam
  ser anonimizados**. Arquivos atualizados:
  - `.github/copilot-instructions.md`
  - `skills/engenharia-reversa-sigo/SKILL.md`
  - `prompts/spec-from-workitem.prompt.md`
  - `prompts/spec-from-lecom.prompt.md`
  - `prompts/spec-from-baseline-plsql.prompt.md`
  - `prompts/baseline-reverse-engineering-forms.prompt.md` (ambas as ocorrencias)
  - `references/prompt-flow.html`

---

## [0.5.0] - 2026-05-08

### Adicionado

- **Engenharia reversa de Oracle Forms** (experimental v0.1)
  - Skill `engenharia-reversa-forms` em [skills/engenharia-reversa-forms/SKILL.md](skills/engenharia-reversa-forms/SKILL.md), espelhando o padrao de `engenharia-reversa-sigo`
  - Prompt `/baseline-reverse-engineering-forms` em [prompts/baseline-reverse-engineering-forms.prompt.md](prompts/baseline-reverse-engineering-forms.prompt.md), orquestrando tool + skill end-to-end
- **Pasta `tools/`** para utilitarios executaveis disparados por skills (distinto de `scripts/` que sao executados pelo TL)
  - `tools/forms-extractor/Convert-FmbToXml.ps1` (.fmb -> .xml via Oracle Forms Developer 10g+ ou JARs)
  - `tools/forms-extractor/Extract-FormsMetadata.ps1` (.xml -> 12 relatorios estruturados em txt/md)
  - `tools/README.md` com convencao de naming + diferenciacao vs scripts/prompts/skills
- **Apresentacao HTML interativa** [references/prompt-flow.html](references/prompt-flow.html) com:
  - Diagrama Mermaid em swim-lanes mostrando atores (TL / LLM / MCP / GATE)
  - Auto-Sizing como cards lado a lado (Pequeno / Medio / Grande / Complexo)
  - Knowledge Verification Chain como passos visuais
  - Matriz Demand Type x Value Area, tabela de obrigatoriedade de spec, autorizacao de MCPs
  - Cards detalhados por comando (input, MCPs invocados, passos reais, artefatos, guardrails)

### Mudado (BREAKING)

- **`.specs/reverse-engineering/` segregada por tipo de objeto** (ADR-011 atualizada)
  - Antes: `.specs/reverse-engineering/<NOME>/rev-<TAG>/`
  - Depois: `.specs/reverse-engineering/<plsql|forms>/<NOME>/rev-NNN-<TAG>/`
- **Revisoes numeradas sequencial zero-padded** (`rev-001-<TAG>`, `rev-002-<TAG>`, ...) - permite ordenacao alfabetica = cronologica e marca cada rev como imutavel
- **Slug ADO corrigido** para `hapvidalabs` (default em `init-spec-project.ps1`, prompts, tutorial, README do mcp.json)

### Atualizado

- `scripts/init-spec-project.ps1` cria estrutura `.specs/reverse-engineering/{plsql,forms}/` com READMEs explicando convencao quando `-Brownfield -Stack PLSQL` ou `-Stack Mista`
- ADR-011 expandida com nova estrutura segregada e regra de imutabilidade de revisao
- Skills `engenharia-reversa-sigo` e `engenharia-reversa-forms` calculam `NNN` listando revs existentes
- `references/reverse-engineering.md`, `references/brownfield-mapping.md`, `references/knowledge-verification.md` atualizados com nova estrutura

### Pendente para v0.6

- Template `templates/reverse-engineering-forms-template.md` (sera criado na primeira RE end-to-end)
- ADR-013 formalizando Forms RE como subdominio paralelo a ADR-011
- Catalogo `catalogo-objetos-forms.md` em `knowledge-base/` (atualmente Forms reusa `catalogo-objetos-plsql.md` para dependencias)

---

## [0.4.0] - 2026-05-08

### Adicionado

- **Framework consumido como git submodule** ([ADR-012](adr/012-framework-como-submodule.md))
  - `init-spec-project.ps1` adiciona `.specs/framework/` como submodule pinado a tag/branch
  - Manifesto `.specs/.framework.json` registra `repo`, `ref`, `commit`, `pinned_at`
  - `scripts/update-framework.ps1` para bump controlado da versao do framework no projeto
- `.vscode/settings.json` configura `chat.promptFilesLocations` apontando para `.specs/framework/prompts`
- `.github/pull_request_template.md` com checklist Spec-Driven (KVC, ADR aplicavel, [ANS], anonimizacao, snapshot)
- Tutorial [TUTORIAL-NEW-PROJECT.md](TUTORIAL-NEW-PROJECT.md) end-to-end para TL adotando o framework

### Mudado

- Squads nao copiam mais `SKILL.md`/prompts/templates do framework - vinculam via submodule
- Atualizacoes do framework chegam via `scripts/update-framework.ps1` (PR proprio recomendado)

---

## [0.3.0] - 2026-05-06

### Mudado (BREAKING)

- Fase **Tasks deixa de ser auto-skip** e passa a ser **sempre obrigatoria** em todos os escopos
  do Auto-Sizing (Pequeno -> Complexo). Granularidade proporcional - escopo Pequeno pode ter
  apenas 1-3 tasks minimas e dispensar diagrama de fases. ([REF: ADR-010](adr/010-tasks-obrigatorias-com-sync-ado.md))
- Cada item de `tasks.md` passa a ser **sincronizado 1:1 com um work item Task no Azure DevOps**,
  criado automaticamente pelo prompt `tasks-from-design` via MCP `@azure-devops/mcp`, vinculado
  como filho da User Story / Feature pai.
- Prefixo `WI-####` em commits de implementacao agora se refere ao **ID da Task ADO filha**, nao
  ao ID da User Story / Feature. Commits de artefatos da spec continuam usando `wi_pai`.
  ([REF: ADR-005](adr/005-conventional-commits-com-prefixo-wi.md))

### Adicionado

- ADR 010 - Tasks obrigatorias com sync automatico ao Azure DevOps
- Campo `ADO Task ID` em `templates/tasks-template.md` e exemplos de `references/tasks.md`
- Bloco `Sync ADO` (`wi_pai`, `ado_project`, `ado_area_path`) no template de `tasks.md`
- Passos 9-11 em `prompts/tasks-from-design.prompt.md`: confirmar metadados, criar Tasks no
  ADO via MCP, gravar IDs de volta em `tasks.md`
- Guardrail: Execute nao inicia sem todos os `ADO Task ID` preenchidos em `tasks.md`
- Cross-reference ADR 008 -> ADR 010 (veto a Quick Mode reforcado)

### Removido

- Bloco "Pular esta fase quando" de `references/tasks.md`
- Step 0 de `references/implement.md` ("Listar passos atomicos quando fase Tasks foi pulada");
  substituido por checklist de verificacao de IDs ADO

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
