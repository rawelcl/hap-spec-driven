# Arquitetura do Framework Spec-Driven Hapvida

**Versao:** 0.2 (piloto Comercial)
**Status:** Documento descritivo - reflete o estado atual do repositorio
**Base:** TLC Spec-Driven 2.0 adaptado ao ecossistema Hapvida

> Este documento descreve a arquitetura logica do framework: como as pecas
> se relacionam, qual o fluxo de dados/artefatos, onde estao os pontos de
> integracao com o ecossistema Hapvida (ADO, WinCVS, Wiki, MCP) e onde
> ficam os guardrails inegociaveis (ANS, LGPD, banco produtivo).

---

## 1. Visao em uma frase

> Uma **camada fina, adaptativa e auditavel** sobre o Agile Hapvida 2.0,
> que coloca a **spec como artefato de primeira classe** versionado em Git,
> orquestrada por **GitHub Copilot + MCPs**, ancorada no **work item ADO**,
> respeitando **bi-VCS (WinCVS + ADO Repos)** e **regulacao ANS**.

---

## 2. Visao em camadas (logical layers)

```mermaid
flowchart TB
    subgraph L0["L0 - Governanca e Guardrails (cross-cutting)"]
        direction LR
        G1["[GUARDRAIL] Banco produtivo proibido"]
        G2["[ANS] / LGPD / sigilo medico"]
        G3["[ADR-AUSENTE] bloqueia avanco"]
        G4["Anonimizacao PII obrigatoria"]
    end

    subgraph L1["L1 - Processo (Agile Hapvida 2.0 - inalterado)"]
        direction LR
        WI["Work Item ADO<br/>Epic/Feature/US/Task"]
        DT["Matriz<br/>Demand Type x Value Area"]
        EST["Estados nativos<br/>In Refinement / Approved /<br/>Resolved / Homologation / Closed"]
    end

    subgraph L2["L2 - Framework (este repositorio)"]
        direction TB
        SKILL["SKILL.md<br/>(ponto de entrada do agente)"]
        FASES["4 fases adaptativas<br/>Specify -> Design -> Tasks -> Execute"]
        AUTOSZ["Auto-sizing<br/>Pequeno / Medio / Grande / Complexo"]
        KVC["Knowledge Verification Chain<br/>(5 passos)"]
        TEMPL["Templates<br/>(spec/design/tasks/ADR/context)"]
        REFS["References<br/>(17 docs de pratica)"]
        PROMPTS["Prompts<br/>(7 arquivos .prompt.md)"]
        ADR["ADRs do framework<br/>(9 decisoes)"]
        GLOSS["Glossario<br/>(Comercial / ANS / Legado)"]
    end

    subgraph L3["L3 - Artefatos do squad (em .specs/ do repo do squad)"]
        direction TB
        PROJ["project/<br/>PROJECT.md / ROADMAP.md / STATE.md / HANDOFF.md"]
        CB["codebase/ (brownfield)<br/>STACK / ARCHITECTURE / CONVENTIONS /<br/>STRUCTURE / TESTING / INTEGRATIONS / CONCERNS"]
        FEAT["features/[feature]/<br/>spec.md / context.md / design.md / tasks.md"]
    end

    subgraph L4["L4 - Agente IA"]
        direction LR
        COP["GitHub Copilot<br/>Claude Opus / Sonnet"]
        SKILLS_SIGO["Skills internas<br/>(engenharia-reversa-sigo /<br/>plsql-oracle-expert /<br/>engenharia-reversa-forms)"]
        TOOLS_LOCAL["Tools executaveis<br/>(tools/ - parsers, extracoes)"]
        SKILLS_SIGO -.invoca.-> TOOLS_LOCAL
    end

    subgraph L5["L5 - Integracoes (MCP)"]
        direction LR
        MCP_ADO["MCP Azure DevOps<br/>(@azure-devops/mcp)"]
        MCP_C7["Context7 MCP<br/>(libs/frameworks)"]
    end

    subgraph L6["L6 - Sistemas Hapvida (sources of truth)"]
        direction LR
        ADO_REPOS["ADO Repos<br/>Java/.NET + .specs"]
        WIKI["Wiki<br/>Arquitetura-Referencia<br/>(96+ ADRs corporativas)"]
        ADO_WI["ADO Work Items<br/>+ Test Cases"]
        WINCVS["WinCVS<br/>tag PRODUCAO<br/>(PL/SQL legado)"]
        DBPROD[("Banco Oracle<br/>PRODUTIVO")]:::forbidden
    end

    L0 -.aplica-se a tudo.-> L1
    L0 -.aplica-se a tudo.-> L2
    L0 -.aplica-se a tudo.-> L4

    L1 --> L2
    L2 --> L3
    L4 --> L2
    L4 --> L5
    L5 --> L6
    L3 --> L6

    L4 -. "PROIBIDO" .-x DBPROD

    classDef forbidden fill:#5a1a1a,stroke:#ff6b6b,stroke-width:2px,color:#fff;
```

**Leitura das camadas:**

- **L0** sao regras inegociaveis que permeiam tudo (nao sao etapas, sao filtros).
- **L1** e o processo corporativo existente - o framework **nao** modifica.
- **L2** e o conteudo deste repositorio: padroes, instrucoes e prompts.
- **L3** sao os artefatos vivos produzidos por squad, dentro do repo do squad.
- **L4** e o agente que orquestra o uso do framework (Copilot + skills).
- **L5** sao os MCPs que dao bracos ao agente para alcancar os sistemas reais.
- **L6** e a verdade absoluta - codigo e metadados que ja existem no Hapvida.

---

## 3. Fluxo das 4 fases adaptativas

```mermaid
flowchart LR
    START([Work Item ADO<br/>Feature/Incident/Defect/US]) --> CLASS{Classificar<br/>complexidade}

    CLASS -->|Pequeno| S1[Specify<br/>spec inline]
    CLASS -->|Medio| S2[Specify<br/>spec completa]
    CLASS -->|Grande| S3[Specify<br/>+ traceability]
    CLASS -->|Complexo| S4[Specify<br/>+ Discuss/context.md]

    S1 --> T1[Tasks minimas<br/>1-3 itens + sync ADO]
    S2 --> T2[Tasks padrao<br/>3-10 itens + sync ADO]
    S3 --> D3[Design<br/>arquitetura + componentes]
    S4 --> D4[Design<br/>+ pesquisa via KVC]

    D3 --> T3[Tasks<br/>decomposicao + dependencias + sync ADO]
    D4 --> T4[Tasks<br/>decomposicao paralela + sync ADO]

    T1 --> EX1[Execute]
    T2 --> EX2[Execute]
    T3 --> EX3[Execute<br/>commit atomico por task]
    T4 --> EX4[Execute<br/>+ UAT interativo]

    EX1 --> VAL[Validate]
    EX2 --> VAL
    EX3 --> VAL
    EX4 --> VAL

    VAL --> SNAP[[spec-publish-snapshot<br/>anexa snapshot ao Work Item]]
    SNAP --> CLOSE([Resolved -> Homologation -><br/>Ready for Production -> Closed])

    %% Valvula de seguranca
    EX2 -. ">5 passos? PARE,<br/>crie design.md formal" .-> D3
```

**Regras essenciais:**

- **Specify, Tasks e Execute sao sempre obrigatorios.** Design e auto-skip por escopo.
- **Tasks sempre obrigatorio + sync ADO 1:1** ([REF: ADR-010](adr/010-tasks-obrigatorias-com-sync-ado.md)).
- **Discuss** so e disparado dentro de Specify para gray areas user-facing.
- **UAT interativo** so dentro de Execute, em features user-facing complexas.
- **Quick Mode** (atalho TLC) **fora do piloto** (ADR 008).
- **Valvula de seguranca:** se Tasks revelar >5 passos com dependencias complexas em escopo onde Design foi pulado, retroceder e criar `design.md` formal.

---

## 4. Knowledge Verification Chain (KVC) - filtro antes de afirmar

```mermaid
flowchart TB
    Q[Pergunta tecnica<br/>ou decisao de design] --> P1{Passo 1<br/>Codebase}
    P1 -->|PL/SQL| WCVS[WinCVS tag PRODUCAO]
    P1 -->|Java/.NET| ADOR[ADO Repos main]
    P1 -.-x DB[("Banco produtivo")]:::forbidden

    WCVS --> P2{Passo 2<br/>Project docs}
    ADOR --> P2
    P2 --> SPECS[".specs/codebase/<br/>.specs/features/"]
    P2 --> WIKI2["Wiki Arquitetura-<br/>Referencia (ADRs corp)"]

    SPECS --> P3{Passo 3<br/>Context7 MCP}
    WIKI2 --> P3
    P3 -->|libs/frameworks/APIs| C7[Context7]

    C7 --> P4{Passo 4<br/>Web}
    P4 -->|docs oficiais ANS, padroes| WEB[Web search]

    WEB --> P5[Passo 5<br/>FLAG UNCERTAIN]
    P5 --> TOK["Marcar com<br/>[REVISAO] ou [BLOQUEADO]"]

    classDef forbidden fill:#5a1a1a,stroke:#ff6b6b,stroke-width:2px,color:#fff;
```

**Inegociaveis:**

- Nao pular para Passo 5 se Passos 1-4 sao acessiveis.
- Passo 5 nunca e apresentado como fato - sempre tokenizado.
- "Nao sei" e preferivel a inventar.

---

## 5. Bi-VCS + ancoragem no Work Item

A peca mais delicada: o framework **convive** com dois VCS diferentes, e
mantem o work item ADO como ponto unico de rastreabilidade.

```mermaid
flowchart LR
    subgraph DEV["Estacao do dev / TL"]
        VSC[VSCode + GitHub Copilot]
        VSC --> SPECF[".specs/features/[feature]/<br/>spec.md / design.md / tasks.md"]
    end

    subgraph PLSQL["Trilho PL/SQL legado"]
        WCVS2[(WinCVS<br/>tag PRODUCAO)]
        PROC["Procedure<br/>cabecalho cita<br/>WI-#### / SPEC-####"]
        WCVS2 --> PROC
    end

    subgraph JAVAQ[".NET / Java"]
        ADOREPO[(ADO Repos Git)]
        COMMIT["Conventional Commits<br/>WI-####: feat(scope): ..."]
        ADOREPO --> COMMIT
    end

    subgraph ADO["Azure DevOps Cloud"]
        WORKITEM["Work Item<br/>(Feature/Incident/...)"]
        ATTACH["Snapshot anexado<br/>(spec.md/design.md/tasks.md)"]
        TC["Test Cases<br/>(evidencia)"]
    end

    SPECF -- "git push" --> ADOREPO
    SPECF -- "spec-publish-snapshot<br/>(prompt + MCP ADO)" --> ATTACH
    ATTACH --> WORKITEM
    COMMIT -- "WI-#### linka" --> WORKITEM
    PROC -- "WI-#### linka" --> WORKITEM
    TC --> WORKITEM
```

**Pontos-chave:**

- A spec **vive em Git** (`.specs/features/[feature]/spec.md`).
- Quando a spec vai para `Approved`, um **snapshot** e anexado ao work item via prompt `spec-publish-snapshot` que aciona o MCP ADO.
- Em **PL/SQL**, a rastreabilidade volta para o work item pelo cabecalho da procedure (`WI-####`/`SPEC-####`).
- Em **Java/.NET**, pelos Conventional Commits com prefixo `WI-####:`.
- **Banco Oracle produtivo nao entra na cadeia.** Ponto.

---

## 6. Mapa de artefatos do framework -> consumo pelo agente

```mermaid
flowchart LR
    subgraph REPO["hapvida-spec-driven-framework (este repo)"]
        ENTRY["SKILL.md<br/>(entry point)"]
        INSTR[".github/copilot-instructions.md"]
        REFS2["references/*<br/>(specify, design, tasks,<br/>implement, validate, KVC,<br/>brownfield, state, handoff,<br/>code-analysis, mcp, ...)"]
        PROMPTS2["prompts/*.prompt.md<br/>(spec-from-workitem,<br/>spec-from-baseline-plsql,<br/>spec-from-lecom, design-from-spec,<br/>tasks-from-design, spec-validator,<br/>spec-publish-snapshot)"]
        TEMPL2["templates/*<br/>(6 specs por matriz<br/>+ design/tasks/ADR/context)"]
        ADRS2["adr/*<br/>(9 decisoes do framework)"]
        GLOSS2["glossario/*<br/>(comercial / ANS / legado)"]
        SKILLS2["skills/*<br/>(engenharia-reversa-sigo,<br/>plsql-oracle-expert,<br/>engenharia-reversa-forms)"]
        TOOLS2["tools/*<br/>(parsers/extracoes invocados<br/>pelas skills)"]
        SKILLS2 -.invoca.-> TOOLS2
    end

    subgraph SQUAD["repo do squad (.specs/)"]
        STATE["STATE.md<br/>(memoria persistente)"]
        FEAT2["features/[feature]/*"]
        CB2["codebase/* (brownfield)"]
    end

    AGT["Copilot Agent<br/>(Claude Opus/Sonnet)"]

    ENTRY -->|carrega primeiro| AGT
    INSTR -->|comportamento default| AGT
    REFS2 -->|sob demanda por fase| AGT
    PROMPTS2 -->|gatilhos do TL| AGT
    TEMPL2 -->|estrutura de saida| AGT
    ADRS2 -->|decisoes vinculantes| AGT
    GLOSS2 -->|termos canonicos| AGT
    SKILLS2 -->|carregadas por trigger| AGT
    TOOLS2 -.disparados pela skill.-> AGT

    AGT <-->|le/grava| STATE
    AGT <-->|gera/atualiza| FEAT2
    AGT <-->|le no inicio| CB2
```

**Estrategia de carga de contexto (alvo <40k tokens):**

| Sempre | Sob demanda | Nunca simultaneo |
|---|---|---|
| `PROJECT.md`, `ROADMAP.md`, `STATE.md` | `codebase/*`, `CONCERNS.md`, `TESTING.md`, `spec.md` da feature em foco, `context.md`, `design.md`, `tasks.md` | Specs de multiplas features, multiplos docs de arquitetura, arquivados |

---

## 7. Selecao de template (matriz Demand Type x Value Area)

```mermaid
flowchart TB
    WI2[Work Item criado] --> Q1{Tipo?}
    Q1 -->|Incident criticidade<br/>alta/media| INC[spec-incident-fast-track]
    Q1 -->|Feature/US/Defect| Q2{Demand Type?}

    Q2 -->|Project| Q3a{Value Area?}
    Q2 -->|Improvement| Q3b{Value Area?}
    Q2 -->|Maintenance| Q3c{Value Area?}

    Q3a -->|Business| TPB[spec-project-business]
    Q3b -->|Business| TIB[spec-improvement-business]
    Q3b -->|Tunning| TIT[spec-improvement-tunning<br/>refatoracao PL/SQL]
    Q3c -->|Business| TMB[spec-maintenance-business]
    Q3c -->|Tunning| TMT[spec-maintenance-tunning]

    TIT --> SKL[Aciona skills SIGO<br/>+ engenharia reversa<br/>WinCVS tag PRODUCAO]
```

---

## 8. Componentes que ainda **nao** existem (escopo explicitamente fora da v0.2)

Para evitar leitura indevida do diagrama, estes itens **nao** estao na arquitetura atual:

- **Quick Mode** (atalho TLC) - ADR 008.
- **Pipelines ADO** de validacao automatizada de spec - validacao e local + Copilot + humano.
- **Automacao bidirecional com Lecom** alem de leitura como input.
- **Customizacao do processo Agile Hapvida 2.0** (211 projetos) - mantido default.
- **Refatoracao automatica de PL/SQL** pelo agente - Copilot **sugere**, humano decide.
- **Acesso a banco Oracle produtivo via MCP** - proibido permanentemente (ADR 007).

---

## 9. Pontos de extensao previstos (v0.3+)

- Glossario expandido para Autorizacao, Glosa, Mensalidade, Faturamento.
- Catalogo de specs canonicas anonimizadas.
- Materiais Onda 2 (devs e QAs).
- Possivel introducao de Quick Mode mediante feedback do piloto.

---

## 10. Resumo executivo

| Pilar | Decisao registrada |
|---|---|
| Spec como artefato de 1a classe versionado em Git | ADR 002 |
| Snapshot ao work item via MCP ADO | ADR 003 |
| Camada fina sobre Agile Hapvida 2.0 | ADR 004 |
| Conventional Commits + prefixo WI | ADR 005 |
| Knowledge Verification Chain | ADR 006 |
| Guardrail acesso producao | ADR 007 |
| Quick Mode fora do piloto | ADR 008 |
| STATE.md obrigatorio em projeto individual | ADR 009 |
| Adocao do framework | ADR 001 |

> Os diagramas acima sao a **leitura visual** dessas 9 decisoes combinadas
> com a estrutura concreta deste repositorio.
