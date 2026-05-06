# Roadmap

**Current Milestone:** v0.2 - Piloto Comercial
**Status:** In Progress

---

## v0.2 - Piloto Comercial

**Goal:** Validar o framework com ~30 tech leads em features reais da area Comercial (venda de planos), durante 2-3 sprints, antes de escalar para Onda 2.

**Target:** Conclusao do piloto e ratificacao da v0.3 com ajustes baseados em metricas reais.

### Features

**Documentacao consolidada do framework** - COMPLETE

- 4 fases adaptativas (Specify, Design, Tasks, Execute)
- 5 templates de spec por matriz Demand Type x Value Area
- Spec de emergencia para Incidents fast-track
- Brownfield Mapping (7 docs)
- Catalogo de prompt files
- Knowledge Verification Chain
- 9 ADRs do framework
- Glossario seed (Comercial, ANS, mapeamento legado)
- Integracao MCP Azure DevOps documentada

**Onboarding dos tech leads da Onda 1** - PLANNED

- Sessao de kickoff (1h)
- Walkthrough do README, SKILL.md e ADRs principais
- Configuracao do MCP Azure DevOps no VSCode
- Selecao da primeira feature de cada TL

**Execucao do piloto em features Comercial** - PLANNED

- Cada TL escolhe 1-2 features no proprio backlog
- Aplicacao do fluxo Specify → Design → Tasks → Execute
- Snapshot de spec anexado ao work item via MCP
- Coleta de feedback semanal

**Coleta de metricas** - PLANNED

- % de Features com spec aprovada antes de codigo
- Tempo de elaboracao de spec (por Demand Type)
- Numero de Incidents derivados de Features recentes (qualidade da spec)
- Adesao por TL (qualitativo + quantitativo)

---

## v0.3 - Ajustes pos-piloto

**Goal:** Incorporar aprendizados do piloto e preparar materiais para Onda 2.

### Features

**Refinamento de templates** - PLANNED

- Ajustar templates de spec com base em feedback dos TLs
- Incluir variantes para tipos de demanda nao cobertos no piloto
- Possivel introducao de Quick Mode se feedback indicar necessidade

**Materiais para Onda 2 (devs e QAs)** - PLANNED

- Guia rapido para devs (consumidores de spec)
- Guia para QAs (criterios de aceitacao -> Test Cases ADO)
- Treinamento estruturado em modulos curtos

**Glossario expandido** - PLANNED

- Cobrir areas funcionais alem de Comercial: Autorizacao, Glosa, Mensalidade, Faturamento
- Mapeamento legado PL/SQL ampliado conforme refatoracoes acumulam baseline

**Catalogo de specs canonicas** - PLANNED

- Galeria de exemplos reais (anonimizados) para referencia

---

## v0.4 - Escala Onda 2

**Goal:** Distribuir framework para todas as 30+ squads (~120 devs e QAs).

### Features

**Onboarding em larga escala** - PLANNED

- Treinamento por capitulo / capitulo de TLs
- Suporte estruturado nas primeiras sprints

**Avaliar pipeline de validacao** - PLANNED

- Decisao baseada em metricas: introduzir pipeline ADO de validacao automatizada de spec?
- Se sim, escopo e abordagem

**Integracao bidirecional com Lecom** - PLANNED

- Sincronizacao spec ↔ documento Lecom (atualmente leitura como input apenas)

**Governanca distribuida** - PLANNED

- Forum/guild de TLs para evolucao do framework
- Curadoria do glossario corporativo
- Processo de proposta e aceitacao de ADRs do framework

---

## Future Considerations

- **Quick Mode** - reavaliavel apos piloto (ADR 008)
- **Customizacao do processo Agile Hapvida 2.0** - processo filho derivado se necessario apos piloto
- **Migracao PL/SQL → Git** - projeto separado; framework ja esta preparado
- **Generalizacao para outras areas funcionais** alem de Comercial
- **Integracao com plataformas de eval / observabilidade de IA** - para medir qualidade automatizada
- **Catalogo regulatorio ANS estruturado** - virar grafo de normas pesquisavel via RAG
