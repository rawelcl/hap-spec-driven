# Tutorial - Iniciar novo projeto com o Framework Spec-Driven Hapvida

> **Versao:** v0.2 (com [ADR-012](adr/012-framework-como-submodule.md))
> **Audiencia:** Tech Lead de squad iniciando um novo repositorio que adota o framework

---

## 0. Pre-requisitos

- Git 2.30+
- PowerShell 5.1+ (Windows)
- VS Code com extensoes **GitHub Copilot** e **GitHub Copilot Chat**
- Acesso ao Azure DevOps `dev.azure.com/hapvida` (PAT ou login interativo)
- Acesso a `https://github.com/rawelcl/hap-spec-driven.git` (ou mirror em ADO)

---

## 1. Criar o repositorio do squad no Azure DevOps

No portal ADO da Hapvida:

1. Project: o do seu time (ex.: `Hapvida-Comercial`)
2. **Repos -> New repository**: ex. `sigo-comercial-cotacao-pme`
3. Inicialize com `README.md` (o init nao sobrescreve)

---

## 2. Clonar localmente

```powershell
cd C:\Users\<voce>\Documents\Repos
git clone https://dev.azure.com/hapvida/Hapvida-Comercial/_git/sigo-comercial-cotacao-pme
cd sigo-comercial-cotacao-pme
```

---

## 3. Baixar o init e executar

```powershell
iwr https://raw.githubusercontent.com/rawelcl/hap-spec-driven/main/scripts/init-spec-project.ps1 -OutFile init.ps1

.\init.ps1 `
  -SquadName "Comercial - Cotacao PME" `
  -Stack PLSQL `
  -AreaAtuacao "Comercial - venda de planos PME" `
  -AdoOrg hapvida `
  -Brownfield `
  -WithProject `
  -WithRoadmap
```

Parametros principais:

| Param | Quando usar |
|---|---|
| `-Stack` | `PLSQL` \| `Java` \| `DotNet` \| `Mista` |
| `-Brownfield` | Codigo legado existente (cria `.specs/codebase/` e, se PL/SQL, `.specs/reverse-engineering/`) |
| `-WithProject` | Cria `PROJECT.md` para vision/goals |
| `-WithRoadmap` | Cria `ROADMAP.md` com Now/Next/Later |
| `-FrameworkRef v0.4.0` | Pinar em tag especifica (default: `main`) |
| `-NoSubmodule` | Pular submodule (apenas teste) |

O que e criado:

```
sigo-comercial-cotacao-pme/
|-- .github/
|   |-- copilot-instructions.md
|   `-- pull_request_template.md
|-- .vscode/
|   |-- mcp.json                  # Azure DevOps MCP
|   |-- settings.json             # paths para .specs/framework/
|   `-- extensions.json
|-- .specs/
|   |-- framework/                # SUBMODULE read-only (ADR-012)
|   |-- .framework.json           # versao + commit hash
|   |-- project/
|   |   |-- STATE.md              # OBRIGATORIO (ADR-009)
|   |   |-- PROJECT.md
|   |   `-- ROADMAP.md
|   |-- codebase/                 # mapeamento brownfield
|   |-- reverse-engineering/      # baseline PL/SQL (ADR-011)
|   `-- features/                 # uma pasta por work item
|-- .gitmodules
|-- README.md                     # nao tocado
`-- init.ps1                      # apagar apos uso
```

---

## 4. Limpar e revisar

```powershell
Remove-Item init.ps1
code .
```

No VS Code, revisar:

- `.specs/project/STATE.md` -> ajustar squad/area se necessario
- `.specs/project/PROJECT.md` -> preencher Vision/Goals/Scope
- `.specs/project/ROADMAP.md` -> Now/Next/Later
- `.github/copilot-instructions.md` -> conferir contexto do squad
- `.vscode/mcp.json` -> confirmar `AdoOrg`

---

## 5. Autenticar MCP Azure DevOps

1. Abra o Copilot Chat (Agent Mode)
2. Faca uma pergunta que envolva ADO (ex.: "liste meus work items")
3. VS Code abre prompt de autenticacao -> entre com sua conta Hapvida
4. Confirme com a tool `mcp_azure-devops_wit_my_work_items`

---

## 6. Commit inicial

```powershell
git add .specs .vscode .github .gitmodules
git commit -m "WI-XXXX: chore(spec-driven): scaffold inicial v0.2 (ADR-012)"
git push
```

> Substitua `WI-XXXX` por work item real (crie um `Task` "Bootstrap Spec-Driven" se nao tiver).

---

## 7. (Brownfield PL/SQL apenas) Baseline de engenharia reversa

**Obrigatorio antes de qualquer spec de refatoracao** ([ADR-011](adr/011-engenharia-reversa-como-baseline.md)).

1. No Copilot Chat, abra o prompt:
   ```
   /baseline-reverse-engineering
   ```
   (que vive em `.specs/framework/prompts/baseline-reverse-engineering.prompt.md`)
2. Informe a rotina-alvo (ex.: `PKG_COTACAO.calcular_premio`)
3. O Copilot usa a skill `engenharia-reversa-sigo` (MCP Oracle so para `dba_*` read-only)
4. Resultado em `.specs/reverse-engineering/<rotina>/rev-<TAG>/`
5. Commit:
   ```powershell
   git add .specs/reverse-engineering
   git commit -m "WI-XXXX: docs(re): baseline PKG_COTACAO.calcular_premio rev-PROD-2026-05-06"
   ```

---

## 8. (Brownfield) Mapeamento da codebase

1. No Chat: `/map-codebase` (ou consulte `.specs/framework/references/brownfield-mapping.md`)
2. Preenche os 7 docs em `.specs/codebase/knowledge-base/`
3. Commit `WI-XXXX: docs(codebase): mapeamento inicial`

---

## 9. Criar a primeira spec (a partir de work item ADO)

1. Tenha o ID do work item (ex.: `WI-12345`)
2. No Chat: `/spec-from-workitem` -> informe o ID
3. O Copilot:
   - Le o work item via MCP ADO
   - Identifica Demand Type x Value Area
   - Escolhe template em `.specs/framework/templates/`
   - Gera `.specs/features/WI-12345-<slug>/spec.md`
4. Itere ate aprovar
5. Validar: `/spec-validator`
6. Quando aprovada, snapshot ao ADO: `/spec-publish-snapshot` ([ADR-002](adr/002-spec-versionada-em-git-snapshot-no-workitem.md))

---

## 10. Design + tasks + implementacao

```
spec aprovada
   -> /design-from-spec       (gera design.md)
   -> /tasks-from-design      (gera tasks.md + 1 work item Task no ADO por item) (ADR-010)
   -> implementar             (commits com WI-<id>: <type>(<scope>): <descricao>)
   -> validar                 (Resolved -> Homologation -> Ready -> GMUD -> Closed)
```

---

## 11. Manutencao do framework no projeto

Quando uma nova versao do framework sair:

```powershell
# Atualizar para tag especifica
.\.specs\framework\scripts\update-framework.ps1 -Ref v0.5.0

# Ou para HEAD do main
.\.specs\framework\scripts\update-framework.ps1

# Revisar diff e commitar
git add .specs/framework .specs/.framework.json
git commit -m "WI-XXXX: chore(framework): bump para v0.5.0"
```

---

## Para outros devs do squad clonarem depois

```powershell
git clone --recurse-submodules https://dev.azure.com/hapvida/Hapvida-Comercial/_git/sigo-comercial-cotacao-pme
```

Ou se ja clonaram sem `--recurse-submodules`:

```powershell
git submodule update --init --recursive
```

---

## Checklist final

- [ ] Repo no ADO criado e clonado
- [ ] `init.ps1` rodado com flags corretas
- [ ] STATE.md com squad/area corretos
- [ ] MCP ADO autenticado e funcional
- [ ] Commit inicial com `WI-XXXX:`
- [ ] (PL/SQL) baseline RE da primeira rotina pronto
- [ ] (Brownfield) mapeamento codebase iniciado
- [ ] Time orientado sobre `git submodule update --init`

---

## Referencias

- [SKILL.md](SKILL.md) - ponto de entrada para Copilot Agent Mode
- [INDEX.md](INDEX.md) - navegacao por situacao/papel
- [ADR-002](adr/002-spec-versionada-em-git-snapshot-no-workitem.md) - spec em Git + snapshot ADO
- [ADR-009](adr/009-state-md-obrigatorio-projeto-individual.md) - STATE.md obrigatorio
- [ADR-010](adr/010-tasks-obrigatorias-com-sync-ado.md) - tasks sync ADO
- [ADR-011](adr/011-engenharia-reversa-como-baseline.md) - baseline RE PL/SQL
- [ADR-012](adr/012-framework-como-submodule.md) - framework como submodule
