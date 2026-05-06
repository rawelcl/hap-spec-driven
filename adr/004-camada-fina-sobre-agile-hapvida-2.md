# ADR 004: Framework como camada fina sobre Agile Hapvida 2.0

**Status:** Accepted
**Data:** 2026-05-06

## Contexto

Agile Hapvida 2.0 e processo customizado usado em 211 projetos do ADO Cloud. Ele ja tem:
- Hierarquia: Epic > Feature > User Story > Task
- Tipos de work item: 11 ativos, 4 desabilitados
- Estados ricos: New, In Refinement, Approved, Committed, Active, Resolved, Homologation, Ready for Production, Closed
- Datas automaticas (Refinement Date, Approved Date, Readiness Date)
- DoR de User Story com 14 itens
- Regras nativas (Required-Demand Type-X, Required-LECOM-X, Set-Approved Date, etc)

## Decisao

O framework opera como **camada fina** sobre o processo default. **Sem modificar** o processo
Agile Hapvida 2.0 - sem fork, sem processo filho.

Adicoes minimas permitidas:
- 2-3 campos customizados opcionais (`Spec Path`, `Spec Version Atual`, `Refatoracao Tipo`)
- 2-3 itens novos em DoR/DoD existentes (sem renumerar os 14 itens atuais)

## Justificativa

- **Risco politico**: tocar processo default afeta 211 projetos
- **Risco tecnico**: customizacoes proprias do processo dificultam upgrade do ADO
- **Reuso**: Demand Type x Value Area, estados existentes, DoR/DoD ja sao ricos
- **Posicionamento de adocao**: framework e a **forma disciplinada de cumprir o DoR existente**,
  nao processo novo concorrente

## Consequencias

**Positivas:**
- Adesao acelerada (TLs nao precisam aprender processo novo)
- Compatibilidade com 211 projetos existentes
- Upgrade do ADO mais simples
- Manutencao do framework desacoplada do processo

**Negativas:**
- Algumas integracoes "ideais" ficam fora (ex: estado custom para "Spec Approved")
- Diferenca entre `Approved` (DoR atendido) e "Spec Approved" (snapshot anexado) - mitigada por
  campos customizados e comentarios via MCP

## Implementacao

- Framework documenta como aproveitar matriz Demand Type x Value Area para roteamento de templates
- Estado `In Refinement` mapeado para fase Specify/Design/Tasks
- Estado `Approved` mapeado para fim de Specify (spec aprovada + snapshot anexado)
- Estado `Active` mapeado para fase Execute
- Estado `Resolved` em diante mapeado para Validate ate Closed
