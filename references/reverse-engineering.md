# Reverse Engineering - Camada de baseline cacheada

**Goal:** Eliminar releitura de monolitos PL/SQL a cada nova demanda - persistir engenharia
reversa por rotina como artefato versionado, cacheado, com gate de staleness contra a tag CVS.

**Trigger:** "engenharia reversa", "RE da procedure X", "extrai as regras", "primeira analise
da rotina", "refresh da RE"

**ADR:** [ADR-011](../adr/011-engenharia-reversa-como-baseline.md)

## Principio

Boa parte do legado Hapvida sao packages PL/SQL de 5k a 20k linhas. Reler esse codigo a cada
spec estoura context window e desperdica tokens. A camada de RE produz um **artefato estruturado
de 3-8k tokens** que substitui a leitura bruta nas fases Specify e Design.

## Quando aplicar

| Situacao | Acao |
|---|---|
| Rotina alvo com >2.000 linhas | RE obrigatoria antes da spec |
| Rotina alvo com sub-rotinas encadeadas (>3 niveis) | RE obrigatoria antes da spec |
| Rotina ja com RE em `.specs/reverse-engineering/plsql/<X>/rev-NNN-<TAG>/` e tag bate com PRODUCAO atual | Usar RE direto - pular leitura de codigo |
| RE existente com tag divergente da PRODUCAO atual | Marcar `[REVISAO]`, disparar refresh via prompt baseline-reverse-engineering |
| Rotina pequena (<500 linhas, sem sub-rotinas) | Skip RE - leitura inline na spec |

## Estrutura no projeto consumidor

A pasta `reverse-engineering/` e segregada por **tipo de objeto** e cada revisao recebe
**numero sequencial zero-padded** (`001`, `002`, ...) prefixando a tag CVS:

```
<repo-do-projeto>/
.specs/
+-- codebase/
|   +-- knowledge-base/                          # Catalogos compartilhados (vivo)
|       +-- indice.md
|       +-- catalogo-conceitos-negocio.md        # CN-XX
|       +-- catalogo-objetos-plsql.md            # objetos analisados + tags
|       +-- pendencias-abertas.md                # ambiguidades em revisao
|       +-- riscos-ans.md                        # riscos consolidados
+-- reverse-engineering/
    +-- README.md                                # convencao de naming + indice
    +-- plsql/                                   # procedures, functions, packages, triggers
    |   +-- <NOME_OBJETO>/
    |       +-- README-rotina.md                 # indice de revisoes
    |       +-- rev-001-<TAG_CVS>/
    |       |   +-- reversa-<NOME_OBJETO>.md
    |       +-- rev-002-<TAG_CVS>/               # nova rev quando tag PRODUCAO divergir
    |           +-- reversa-<NOME_OBJETO>.md
    +-- forms/                                   # modulos Oracle Forms (.fmb)
        +-- <MODULO>/
            +-- README-modulo.md
            +-- rev-001-<TAG_CVS>/
                +-- raw/<MODULO>.xml             # Forms2XML (Etapa 1 do tool)
                +-- parsed/<MODULO>_*.txt        # 12 relatorios (Etapa 2 do tool)
                +-- reversa-<MODULO>.md          # artefato canonico
```

**Convencao da revisao:** `rev-NNN-<TAG_CVS>` onde `NNN` e sequencial zero-padded.
A skill calcula `NNN` listando revs existentes e incrementando 1. Revisao = imutavel.

## Pipeline

```
+----------+    +-------+    +---------+    +----------+    +----------+
| BASELINE | -> | SPEC  | -> | DESIGN  | -> |  TASKS   | -> | EXECUTE  |
|   (RE)   |    |       |    |         |    |          |    |          |
+----------+    +-------+    +---------+    +----------+    +----------+
   skill           cita           cita          decompoem      cita RE
engenharia-      [REF: RE]    [REF: RE]      em refatoracoes   no header
reversa-sigo                                  atomicas
```

A fase BASELINE (RE) **nao e nova fase do framework** - e pre-requisito condicional, executado
**uma vez por rotina** (refrescado quando tag CVS muda).

## Gate de staleness

Toda spec/design que cite `[REF: .specs/reverse-engineering/plsql/<X>/rev-NNN-<TAG>/]` (ou `forms/<X>/...`) deve verificar:

```
tag_cvs_no_artefato == tag_PRODUCAO_atual_no_CVS
```

| Resultado | Acao |
|---|---|
| Igual | RE valida - usar como baseline |
| Diferente | Marcar `[REVISAO]`, disparar refresh, **nao prosseguir spec** ate refresh aprovado |
| RE inexistente para a rotina | Disparar prompt `baseline-reverse-engineering` antes da spec |

## Skill responsavel

[`skills/engenharia-reversa-sigo/SKILL.md`](../skills/engenharia-reversa-sigo/SKILL.md) e o
produtor canonico. Ela:

- Le codigo do CVS tag PRODUCAO (fonte unica - sem fallback para banco)
- Usa MCP Oracle somente para dicionario (dba_*)
- Faz rastreamento recursivo de sub-rotinas (max 5 niveis)
- Extrai regras de negocio em linguagem de negocio com evidencia de codigo
- Identifica smells, riscos ANS, dependentes
- Faz analise de impacto integrada (secoes 12-15 do artefato)

## Knowledge Verification Chain - Step 1 atualizada

Step 1 do [knowledge-verification](knowledge-verification.md) ganha sub-niveis para PL/SQL:

```
Passo 1: Codebase
  1a. .specs/reverse-engineering/plsql/<rotina>/rev-NNN-<TAG>/  <- PRIMEIRO se TAG bate
      .specs/reverse-engineering/forms/<modulo>/rev-NNN-<TAG>/  <- idem para Forms
  1b. WinCVS tag PRODUCAO                                        <- se RE ausente ou stale
  [GUARDRAIL] NUNCA banco produtivo para dados de negocio
  [GUARDRAIL] MCP Oracle so para dicionario (dba_*) - dba_source proibido como fonte de codigo
```

## Relacao com brownfield-mapping

A RE complementa os 7 documentos de [brownfield-mapping](brownfield-mapping.md):

| Camada | Granularidade | Quando criar |
|---|---|---|
| 7 docs em `.specs/codebase/` | Sistema inteiro | Uma vez no onboarding do squad |
| Catalogos `knowledge-base/` | Dominio do squad | Vivo - atualizado por cada RE |
| RE em `.specs/reverse-engineering/plsql\|forms/<X>/` | Por rotina ou modulo | Sob demanda quando objeto e tocado |

## Exemplo de uso

```
TL: "Vamos refatorar PKG_FATURAMENTO_INDIVIDUAL para reduzir tempo de fechamento"

Agent (Step 1a):
  - Verifica .specs/reverse-engineering/PKG_FATURAMENTO_INDIVIDUAL/
  - Existe rev-PRODUCAO-2.4.1, mas tag PRODUCAO atual e 2.4.3
  - [REVISAO] RE divergente - dispara prompt baseline-reverse-engineering

Agent (apos refresh):
  - Cria rev-PRODUCAO-2.4.3 com 47 regras extraidas, 8 smells, 3 riscos ANS
  - Painel de Decisao aprovado pelo PO
  - Spec Improvement+Tunning cita [REF: .specs/reverse-engineering/PKG_FATURAMENTO_INDIVIDUAL/rev-PRODUCAO-2.4.3/]
  - Nao precisa mais reler 14k linhas do package
```

## Pendencias / proximas evolucoes

- `[REVISAO]` Automatizar deteccao de tag stale via hook (compara HEAD do CVS vs `tag_cvs` do
  frontmatter) - hoje manual
- `[REVISAO]` Definir politica de retencao - manter todas as `rev-NNN-<TAG>` ou so as ultimas N
- `[REVISAO]` Cross-reference automatico entre RE de rotinas que se chamam (grafo)
