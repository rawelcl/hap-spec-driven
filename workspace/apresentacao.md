# Apresentacao — Framework Spec-Driven Hapvida

**Versao:** 0.5.x  
**Repositorio:** https://github.com/rawelcl/hap-spec-driven  
**Audiencia:** Tech lead ou dev que vai adotar o framework

---

## O que e

Uma **camada fina e auditavel** sobre o Agile Hapvida 2.0 que coloca a
**spec como artefato de primeira classe** — versionada em Git, ancorada no
work item Azure DevOps e orquestrada pelo GitHub Copilot com Claude.

Nao substitui o processo. Adiciona disciplina de especificacao antes de codar.

---

## Por que usar

| Sem o framework | Com o framework |
|---|---|
| Entendimento na cabeca do dev | Spec versionada em Git |
| Escopo descoberto no meio da task | Criterios de aceite antes de codar |
| Code review sem contexto | Design documentado, tasks rastreadas |
| Engenharia reversa ad-hoc | RE estruturada com baseline WinCVS |
| PL/SQL alterado sem registro | Spec + commit `WI-####:` linkados ao WI |

---

## Como funciona — as 4 fases

```
SPECIFY  ->  DESIGN  ->  TASKS  ->  EXECUTE
```

Cada fase tem um comando `/` no VS Code Chat:

| Fase | Comando | O que faz |
|---|---|---|
| Specify | `/hap-sd-specify` | Gera spec.md a partir do work item |
| Design | `/hap-sd-design` | Gera design.md (quando necessario) |
| Tasks | `/hap-sd-tasks` | Decompoe em tasks e sincroniza no ADO |
| Execute | `/hap-sd-implement` | Implementa task por task com contexto |

### Quando pular fases

| Tamanho | Regra |
|---|---|
| Pequeno (ate 3 arquivos) | Spec inline, skip Design |
| Medio (feature clara) | Spec completa, Design pode ser inline |
| Grande / Complexo | Todas as fases obrigatorias |

---

## Diferenciais Hapvida

### 1. Vinculo bidirecional spec ↔ work item
A spec e versionada em `.specs/features/<feature>/spec.md` no repo do squad.
Quando aprovada, um snapshot PDF e anexado ao WI via MCP Azure DevOps.

### 2. Bi-VCS — WinCVS + ADO Repos
- **PL/SQL (legado):** codigo canônico esta na **TAG PRODUCAO do WinCVS**
- **Java/.NET:** codigo no ADO Repos com Conventional Commits `WI-####:`
- `[GUARDRAIL]` Nunca use banco produtivo como fonte de codigo PL/SQL

### 3. Guardrails inegociaveis
- `[GUARDRAIL]` Acesso ao banco produtivo proibido — dicionario Oracle read-only (`dba_*`) apenas
- `[GUARDRAIL]` RE de PL/SQL e Forms sempre parte da **TAG PRODUCAO no WinCVS**
- `[GUARDRAIL]` Dados de beneficiario pessoa fisica exigem anonimizacao (CPF, nome, matricula)
- `[ANS]` Qualquer toque em area regulada exige citacao de norma ANS

---

## Onde fica cada artefato do squad

```
<repo-do-squad>/
  .specs/
    project/
      PROJECT.md      <- visao, escopo, constraints do projeto
      ROADMAP.md      <- evolucao planejada
      STATE.md        <- estado atual (obrigatorio, ver ADR-009)
    codebase/         <- mapeamento brownfield (stack, arquitetura, etc)
    features/
      <feature>/
        spec.md       <- especificacao da feature
        context.md    <- contexto tecnico e dependencias
        design.md     <- design tecnico (quando gerado)
        tasks.md      <- tasks decompostas
    reverse-engineering/
      <objeto>/
        README-<objeto>.md          <- ficha do objeto (nivel do objeto)
        v<VERSAO>-rev-001/          <- pasta de cada revisao
          re-<objeto>.md
```

---

## Stack de IA necessaria

- **VS Code** com extensoes GitHub Copilot + GitHub Copilot Chat
- **MCP Azure DevOps** configurado localmente (`@azure-devops/mcp`)
- Acesso ao repositorio `rawelcl/hap-spec-driven` (ou mirror em ADO)

---

## Proximos passos

1. Leia o [Guia Rapido](guia-rapido.md) para os comandos do dia a dia
2. Siga o [TUTORIAL-NEW-PROJECT.md](TUTORIAL-NEW-PROJECT.md) para iniciar seu repo
3. Abra o `SKILL.md` no chat com `@workspace` para o agente ter contexto completo
