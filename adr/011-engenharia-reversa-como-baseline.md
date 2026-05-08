# ADR 011: Engenharia reversa por rotina como camada de baseline cacheada

**Status:** Accepted
**Data:** 2026-05-06

## Contexto

Boa parte do legado Hapvida sao monolitos PL/SQL de 5k a 20k linhas por package, com sub-rotinas
encadeadas, dependencias dinamicas e regras de negocio embutidas em SQL (DECODE, CASE, WHERE
correlacionados). Em cada nova demanda que toca essas rotinas, o agente IA precisa reler o codigo
do CVS, estourando context window e desperdicando tokens em redescoberta.

A skill `engenharia-reversa-sigo` ja extrai esse conhecimento de forma estruturada, mas hoje a saida
da skill alimenta a spec descartavelmente - sem persistencia, sem reuso entre features.

## Decisao

`[GUARDRAIL]` Toda rotina PL/SQL com **mais de 2.000 linhas** ou **complexidade ciclomatica alta**
(multiplas sub-rotinas encadeadas) deve ter sua engenharia reversa **persistida** como camada de
baseline antes de qualquer spec que a toque.

A camada de RE vive em estrutura **segregada por tipo de objeto** com revisoes numeradas:

```
.specs/reverse-engineering/
  README.md                          # convencao + indice
  plsql/                             # procedures, functions, packages, triggers
    <NOME_OBJETO>/
      README-rotina.md               # indice de revisoes da rotina
      v1.23-rev-001/                 # versao CVS do objeto + sequencial da analise
        reversa-<NOME_OBJETO>.md     # artefato canonico
      v1.24-rev-002/                 # nova versao CVS -> novo prefixo
        reversa-<NOME_OBJETO>.md
  forms/                             # modulos Oracle Forms (.fmb)
    <MODULO>/
      README-modulo.md
      v1.23-rev-001/
        raw/<MODULO>.xml             # Forms2XML (Etapa 1 do tools/forms-extractor)
        parsed/<MODULO>_*.txt        # 12 relatorios (Etapa 2)
        reversa-<MODULO>.md
```

**Convencao da pasta:** `v<VERSAO_CVS>-rev-NNN` onde `VERSAO_CVS` e a revisao numerica do
objeto na tag PRODUCAO do CVS (ex: `1.23`) e `NNN` e o numero sequencial zero-padded da analise
feita sobre aquela versao (`001`, `002`, ...). A skill calcula `NNN` listando `v*-rev-*`
existentes do objeto e somando 1. Cada pasta e **imutavel** - nunca editar; criar nova quando
a versao CVS divergir ou uma nova analise for necessaria.

A `Knowledge Verification Chain` Step 1 e atualizada para priorizar a RE cacheada antes de ler o
codigo cru no CVS. RE sera usada quando a versao CVS gravada no prefixo `v<VERSAO_CVS>-rev-NNN` (mais recente)
bate com a tag PRODUCAO atual; caso contrario, a RE e marcada `[REVISAO]` e refresh e disparado
gerando nova pasta com versao CVS atualizada.

## Justificativa

- **Context window**: rotina de 20k linhas + sub-rotinas estoura limite; RE estruturada cabe em
  3-8k tokens
- **Reuso**: mesma rotina e tocada por multiplas demandas ao longo do tempo
- **Auditoria**: artefato versionado (Git) + rastreavel a tag CVS especifica
- **Velocidade**: pular re-extracao acelera Specify e Design
- **Knowledge base viva**: RE serve tambem como onboarding e referencia para `[REF: arquivo:linha]`

## Trade-offs

| Beneficio | Custo |
|---|---|
| Reuso de extracao entre features | Manutencao do baseline RE quando CVS muda |
| Menor consumo de contexto | Risco de RE stale ser usada como verdade |
| Rastreabilidade auditavel | Esforco inicial de RE em rotinas grandes |

Mitigacao do risco de stale: gate obrigatorio comparando tag CVS gravada vs PRODUCAO atual; divergente
gera `[REVISAO]` automatico.

## Skill responsavel

`engenharia-reversa-sigo` (em [`skills/engenharia-reversa-sigo/SKILL.md`](../skills/engenharia-reversa-sigo/SKILL.md))
e o produtor canonico do artefato. O prompt
[`prompts/hap-sd-re-plsql.prompt.md`](../prompts/hap-sd-re-plsql.prompt.md)
e o gatilho.

## Relacao com outras ADRs

- `[REF: ADR-006]` Knowledge Verification Chain - Step 1 ganha sub-niveis (1a RE cacheada, 1b CVS)
- `[REF: ADR-007]` Guardrail acesso producao - emendado por esta ADR para liberar leitura
  read-only do **dicionario Oracle** (dba_*) durante a RE. Fonte de codigo permanece
  exclusivamente WinCVS tag PRODUCAO (dba_source proibido como fonte de codigo).

## Consequencias

- Squads passam a investir em RE inicial das rotinas core do escopo (uma vez por rotina)
- Specs do tipo Improvement+Tunning citam
  `[REF: .specs/reverse-engineering/plsql/<rotina>/v<VERSAO_CVS>-rev-NNN/]` (ou `forms/<modulo>/...`)
  como evidencia de baseline
- `references/brownfield-mapping.md` ganha referencia a esta camada
- `.specs/codebase/knowledge-base/` no projeto consumidor materializa catalogos compartilhados
  (catalogo-conceitos-negocio, catalogo-objetos-plsql, riscos-ans, pendencias-abertas)
