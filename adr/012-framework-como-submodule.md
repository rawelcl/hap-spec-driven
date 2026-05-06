# ADR 012: Framework distribuido como git submodule em `.specs/framework/`

**Status:** Accepted
**Data:** 2026-05-06
**Decisores:** Thiago RC
**Tipo:** framework

## Contexto

O framework Spec-Driven Hapvida v0.2 estava sendo consumido pelos squads via **referencia por
URL** ([SKILL.md](https://github.com/rawelcl/hap-spec-driven/blob/main/SKILL.md) remoto no
`copilot-instructions.md`). Esse modelo apresentou problemas:

- **Sem reprodutibilidade**: spec criada em fev/2026 referencia prompts/templates de `main`
  movel - se o framework muda em mar/2026, a spec antiga vira inconsistente.
- **Sem suporte offline**: ambientes restritos (rede Hapvida sem GitHub publico, WinCVS) nao
  conseguem resolver o `SKILL.md`.
- **Sem versao explicita**: nao ha forma do squad declarar "estou na v0.2.3 do framework".
- **Drift silencioso**: squads acabam copiando trechos de prompts e editando, divergindo.
- **Conflito com [ADR-002](002-spec-versionada-em-git-snapshot-no-workitem.md)**: ADR-002 ja
  prega snapshot da spec no work item para auditoria. O mesmo principio deve valer para o
  framework consumido por aquela spec.

Tres opcoes foram avaliadas:

- **Opcao A**: manter referencia por URL (status quo v0.2)
- **Opcao B**: copia inline (`init.ps1` copia `prompts/`, `templates/`, etc para o repo do squad)
- **Opcao C**: git submodule do `hap-spec-driven` em `.specs/framework/`

## Decisao

**Opcao C**: framework e adicionado como **git submodule read-only** em `.specs/framework/` do
repo do squad, pinado em um commit/tag especifico.

Estrutura resultante no repo do squad:

```
meu-squad-pilot/
??? .github/
?   ??? copilot-instructions.md    [BOILERPLATE] gerado pelo init
?   ??? pull_request_template.md   [BOILERPLATE] gerado pelo init
??? .vscode/
?   ??? mcp.json                   [BOILERPLATE] gerado pelo init
?   ??? settings.json              [FRAMEWORK]   paths para .specs/framework/
?   ??? extensions.json            [FRAMEWORK]   extensoes recomendadas
??? .specs/
?   ??? framework/                 [SUBMODULE]   *** READ-ONLY ***
?   ?   ??? SKILL.md
?   ?   ??? prompts/
?   ?   ??? templates/
?   ?   ??? references/
?   ?   ??? adr/
?   ?   ??? skills/
?   ?   ??? glossario/
?   ??? .framework.json            [FRAMEWORK]   versao + commit hash
?   ??? project/
?   ?   ??? STATE.md               [USUARIO]     atualizado vivo
?   ?   ??? PROJECT.md             opcional
?   ?   ??? ROADMAP.md             opcional
?   ??? codebase/                  [USUARIO]     se Brownfield
?   ??? reverse-engineering/       [USUARIO]     se PL/SQL ([ADR-011](011-engenharia-reversa-como-baseline.md))
?   ??? features/
?       ??? WI-12345-<slug>/       [USUARIO]
?           ??? spec.md
?           ??? design.md
?           ??? tasks.md
?           ??? context.md
??? src/                           [USUARIO]     codigo do squad (Java/.NET)
??? PROJECT.md                     [BOILERPLATE]
??? STATE.md                       (link para .specs/project/STATE.md)
??? README.md                      [USUARIO]     nao tocado se ja existir
```

## Justificativa

- **Reprodutibilidade**: commit do submodule e parte do tree do squad. Spec de fev/2026 sempre
  resolve para a versao do framework daquele momento.
- **Auditoria regulatoria**: rastreio cripto-forte do framework usado em qualquer release
  (consistente com [ADR-002](002-spec-versionada-em-git-snapshot-no-workitem.md)).
- **Sem duplicacao**: submodule referencia, nao copia (ao contrario da Opcao B). Repo do squad
  fica leve.
- **Atualizacao controlada**: `git submodule update --remote` + `update-framework.ps1` faz refresh
  explicito, com PR de squad.
- **Read-only por design**: o `.specs/framework/` aponta para outro repositorio Git - nao se
  edita por acidente.
- **Offline funciona**: apos o `git submodule update --init`, o conteudo esta local.

## Alternativas consideradas

- **Opcao A (URL remota)**: status quo. Falha em reprodutibilidade e offline.
- **Opcao B (copia inline)**: `init.ps1` copia arquivos do framework para `.specs/framework/`.
  Funciona mas duplica conteudo, exige hash-check para detectar drift, e cada `update` e um
  diff grande no repo do squad. Aumenta tamanho do repo proporcionalmente ao numero de squads.

## Consequencias

**Positivas:**
- Reprodutibilidade total (commit do framework esta no tree do squad)
- Auditoria regulatoria reforcada
- Suporte offline natural
- Atualizacao do framework e PR explicito (review obrigatorio)
- Repo do squad permanece leve (nao copia conteudo)
- Compatibilidade com [ADR-002](002-spec-versionada-em-git-snapshot-no-workitem.md)

**Negativas/Riscos:**
- Squads precisam aprender `git submodule update --init --recursive` apos clone
  (mitigado por hint no `README.md` boilerplate e por `init.ps1` que faz no scaffold inicial)
- `git clone --depth 1` sem `--recurse-submodules` deixa `.specs/framework/` vazio
- Squads em rede restrita precisam de acesso ao remote do framework (via Azure DevOps mirror
  se GitHub publico nao estiver acessivel)
- Submodules tem reputacao ruim em times pouco familiarizados com Git - exige documentacao

## Implementacao

1. **Atualizar `init-spec-project.ps1`**: adicionar passo `git submodule add` apontando para
   `https://github.com/rawelcl/hap-spec-driven.git .specs/framework`, gerar `.specs/.framework.json`
   com `version` + `commit` + `pinned_at`.
2. **Criar `scripts/update-framework.ps1`**: wrapper para `git submodule update --remote
   .specs/framework`, atualiza `.framework.json`, gera commit `WI-XXXX: chore(framework): update
   to vX.Y.Z`.
3. **Atualizar `.vscode/settings.json` boilerplate**: paths fixos para `.specs/framework/prompts`,
   `.specs/framework/templates`, etc.
4. **Atualizar `SKILL.md` e `references/`**: substituir referencias a URL pelo path local
   `.specs/framework/...` quando aplicavel.
5. **Mirror em Azure DevOps**: garantir mirror do `hap-spec-driven` em ADO da Hapvida para squads
   sem acesso a GitHub publico (deferred para WI separado).
6. **`pull_request_template.md` e `extensions.json`**: novos boilerplates gerados pelo init
   (parte do escopo desta ADR).

## Relacionamento com outras ADRs

- **Reforca [ADR-002](002-spec-versionada-em-git-snapshot-no-workitem.md)**: snapshot do framework
  vira parte do snapshot da spec.
- **Compativel com [ADR-009](009-state-md-obrigatorio-projeto-individual.md)**: STATE.md continua
  em `.specs/project/STATE.md` (nao no submodule).
- **Compativel com [ADR-011](011-engenharia-reversa-como-baseline.md)**: `.specs/reverse-engineering/`
  fica fora do submodule (e conteudo do squad).
