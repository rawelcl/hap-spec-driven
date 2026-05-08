# ADR 001: Adocao do Framework Spec-Driven Hapvida (adaptacao do TLC)

**Status:** Accepted
**Data:** 2026-05-06
**Decisores:** Tech leads piloto Comercial, Arquitetura Hapvida

## Contexto

Hapvida tem ~30 squads (~150 pessoas), processo Agile Hapvida 2.0 customizado em 211 projetos no
ADO Cloud, ambiente bi-VCS estrutural (WinCVS para PL/SQL, ADO Repos Git para Java/.NET), wiki
Arquitetura-Referencia com >96 ADRs corporativas.

Existe baixa adesao a praticas RFC e Design doc (4 artefatos fragmentados); spec PO e ADR ja
tem alta adesao mas nao ha framework que amarre disciplinadamente o ciclo
Spec → Design → Tasks → Execute usando IA (GitHub Copilot Claude).

## Decisao

Adotar como framework corporativo o **Spec-Driven Hapvida v0.2**, que e adaptacao do framework
TLC Spec-Driven (Tech Lead's Club, https://github.com/tech-leads-club, CC-BY-4.0) customizada para:

1. Acoplamento ao Azure DevOps (spec versionada em ADO Repos + snapshot anexado ao work item via MCP)
2. Convivencia bi-VCS (WinCVS para PL/SQL com tag PRODUCAO + ADO Repos Git para Java/.NET)
3. Camada fina sobre Agile Hapvida 2.0 (sem modificar processo default)

## Alternativas consideradas

- **Construir framework do zero**: descartado por reinventar pratica madura
- **Adotar TLC integralmente sem adaptacoes**: descartado pois TLC nao prescreve integracao com ADO,
  bi-VCS, ANS, Lecom, GMUD, ServiceNow
- **Adotar somente RFCs / Design docs existentes da wiki**: descartado por baixa adesao historica
- **Ferramenta proprietaria (RFC ADO + Design doc)**: descartado, mantem 4 artefatos fragmentados

## Consequencias

**Positivas:**
- Disciplina compartilhada entre squads
- Spec como artefato de primeira classe ancorado no work item
- Aproveita ADRs Hapvida existentes (>96) como RAG
- Reduz fragmentacao (4 artefatos -> 2: spec consolidada + ADR)
- Adesao gradual em duas ondas (30 TLs piloto -> 120 devs/QAs)
- Posicionamento como "forma disciplinada de cumprir DoR existente", nao processo novo concorrente

**Negativas/Riscos:**
- Curva de aprendizagem para TLs na Onda 1
- Manutencao continua do framework (precisa governance pos-piloto)
- Dependencia de GitHub Copilot homologado (mitigada por ja existir homologacao)
- Bi-VCS continua estrutural (nao resolvido pelo framework, apenas tratado)

## Implementacao

- v0.2 publicada em https://github.com/rawelcl/hap-spec-driven
- Onda 1: piloto Comercial com ~30 TLs
- Onda 2: escala para 30+ squads apos validacao da v0.3 (ajustes pos-piloto)
- Governance pos-piloto: forum/guild de TLs para evolucao
