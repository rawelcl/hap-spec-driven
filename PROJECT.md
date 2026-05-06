# Framework Spec-Driven Hapvida

**Vision:** Padronizar o desenvolvimento de software no Hapvida em torno de spec como artefato de primeira classe, ancorada no Azure DevOps, respeitando regulacao ANS e a infraestrutura bi-VCS existente.

**For:** Tech leads, desenvolvedores e QAs que atuam com desenvolvimento de software no Hapvida.

**Solves:** Inconsistencia na producao de specs, dispersao de RFC e Design doc com baixa adesao, falta de rastreabilidade ponta a ponta entre regra de negocio, codigo e evidencia de validacao, e ausencia de pratica disciplinada de IA assistida (GitHub Copilot) que respeite os guardrails regulatorios.

## Goals

- [ ] **Adocao gradual em duas ondas:** Onda 1 com ~30 tech leads no piloto Comercial; Onda 2 escala para ~120 devs e QAs em 30+ squads (~150 pessoas total)
- [ ] **Reducao de retrabalho** em features que passam por engenharia reversa de PL/SQL legado (especialmente Improvement+Tunning)
- [ ] **Rastreabilidade 100%** entre regra de negocio (spec), codigo (PL/SQL CVS ou Java/.NET Git) e evidencia (Test Cases ADO)
- [ ] **Zero violacao** de guardrails regulatorios (ANS, LGPD, sigilo medico) em conteudo gerado por IA
- [ ] **Posicionamento de adocao:** o framework e a forma disciplinada de cumprir o DoR existente, nao processo novo concorrente

## Tech Stack

**Core:**

- Spec versionada em **ADO Repos (Git)** + **snapshot anexado ao work item** via MCP do Azure DevOps
- Codigo PL/SQL em **WinCVS** com tag `PRODUCAO` como base code unico permitido
- Codigo Java/.NET Core em **ADO Repos (Git)** com Conventional Commits + prefixo `WI-####:`

**Camada de IA:**

- **GitHub Copilot** (Claude Opus / Sonnet) em VSCode
- **Local Azure DevOps MCP Server** (`@azure-devops/mcp`) - GA, configurado por `.vscode/mcp.json`
- **Wiki Arquitetura-Referencia** como RAG primario (>96 ADRs corporativas)

**Processo:**

- **Agile Hapvida 2.0** (211 projetos no ADO Cloud) - sem modificacao no processo default
- Hierarquia ativa: Epic → Feature → User Story → Task (Iniciativa desabilitada)
- Tipos com spec: Feature (canonico), Incident, Defect (criticidade media/alta), User Story standalone

## Scope

**v0.2 (piloto) inclui:**

- 4 fases adaptativas: Specify → Design → Tasks → Execute
- 5 templates de spec por matriz Demand Type x Value Area
- Spec de emergencia para Incidents fast-track
- Brownfield Mapping (7 docs) para projetos com codigo existente
- Catalogo de prompt files para GitHub Copilot
- Knowledge Verification Chain explicita
- 10 ADRs do framework consolidando decisoes
- Glossario de dominio Comercial + Regulatorio ANS + Mapeamento legado PL/SQL
- Integracao MCP Azure DevOps para snapshot de spec ao work item
- Camada fina sobre Agile Hapvida 2.0 (sem modificar processo default)

**v0.2 (piloto) explicitamente fora de escopo:**

- Quick Mode (atalho TLC para tarefas pequenas) - reavaliavel apos piloto
- Pipelines ADO de validacao automatizada de spec - validacao no piloto e local + Copilot + humano
- Integracao com Lecom (BPM corporativo) alem de leitura como fonte de input - automacao bidirecional fica para v0.3+
- Customizacao do processo Agile Hapvida 2.0 (211 projetos) - se necessario, processo filho derivado apenas para piloto
- Refatoracao automatica de codigo PL/SQL pelo agente - Copilot sugere, humano decide

## Constraints

- **Timeline:** piloto inicia apos publicacao da v0.2 e ADR 001 ratificada na wiki Arquitetura-Referencia
- **Tecnicos:**
  - Bi-VCS estrutural (WinCVS + ADO Repos Git) - nao transitorio
  - Sem pipeline CI/CD para PL/SQL (deploy manual via DBA, sem Liquibase/Flyway)
  - **[GUARDRAIL]** Acesso a banco produtivo Oracle proibido para qualquer agente IA - sempre WinCVS tag PRODUCAO
  - **[GUARDRAIL]** Anonimizacao obrigatoria de PII de beneficiario antes de qualquer prompt
  - LGPD + sigilo medico inegociaveis
- **Recursos:**
  - Sem time dedicado de plataforma de IA - framework precisa funcionar com ferramentas existentes
  - Adesao depende de TLs como multiplicadores na Onda 1
  - GitHub Copilot homologado corporativamente com Claude Opus / Sonnet
- **Politicos:**
  - Nao tocar processo default do Agile Hapvida 2.0 (211 projetos)
  - ADRs corporativas existentes prevalecem sobre decisoes do framework
