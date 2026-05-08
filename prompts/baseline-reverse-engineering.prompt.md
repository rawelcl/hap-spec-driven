---
mode: 'agent'
description: 'Disparar engenharia reversa de objeto PL/SQL e persistir em .specs/reverse-engineering/ como baseline cacheado'
---

Voce e o assistente do Framework Spec-Driven Hapvida v0.3.

# Tarefa

Produzir o **artefato canonico de engenharia reversa** de uma rotina PL/SQL Oracle, persistido
em `.specs/reverse-engineering/plsql/<NOME>/rev-NNN-<TAG>/` para servir de baseline cacheado em
futuras specs (ver [ADR-011](../adr/011-engenharia-reversa-como-baseline.md)).

`NNN` e numero sequencial zero-padded (`001`, `002`, ...) - calcular listando revs existentes
no diretorio do objeto e incrementando 1.

# Quando usar

- Primeira analise de rotina PL/SQL com >2.000 linhas ou complexidade ciclomatica alta
- Refresh de RE existente marcada `[REVISAO]` (tag CVS divergente da PRODUCAO atual)
- Antes de Specify de Improvement+Tunning sobre rotina ainda nao mapeada

# Input esperado

- Nome do objeto (`SCHEMA.NOME`)
- Tipo (procedure, function, package, trigger)
- (Opcional) ID do work item ADO destino - se ja houver demanda associada

# Passos

1. **Verificar guardrails**:
   - `[GUARDRAIL]` Codigo lido **exclusivamente do CVS tag PRODUCAO** - se nao localizado: `[BLOQUEADO]` (sem fallback)
   - `[GUARDRAIL]` MCP Oracle so para dicionario (dba_*) - `dba_source` proibido como fonte de codigo
2. **Invocar a skill** [`engenharia-reversa-sigo`](../skills/engenharia-reversa-sigo/SKILL.md)
   seguindo seu protocolo de execucao (Passos 0 a 6)
3. **Materializar pre-requisitos** se ausentes em `.specs/codebase/knowledge-base/`:
   - `indice.md`, `catalogo-conceitos-negocio.md`, `catalogo-objetos-plsql.md`,
     `pendencias-abertas.md`, `riscos-ans.md`
4. **Resolver tag CVS PRODUCAO** e gravar no frontmatter do artefato
5. **Calcular NNN** - sequencial zero-padded da revisao (listar `rev-*` em
   `.specs/reverse-engineering/plsql/<NOME>/`, incrementar 1; primeira analise = `001`)
6. **Gerar artefato** a partir de
   [`templates/reverse-engineering-template.md`](../templates/reverse-engineering-template.md)
   em `.specs/reverse-engineering/plsql/<NOME>/rev-NNN-<TAG>/reversa-<NOME>.md`
7. **Atualizar indice** `.specs/reverse-engineering/plsql/<NOME>/README-rotina.md`
8. **Atualizar catalogos** em `.specs/codebase/knowledge-base/`
9. **Apresentar para aprovacao** o Painel de Decisao (secao 11 do artefato)

# Output

- Artefato canonico de RE
- Atualizacoes nos catalogos do projeto
- Lista de `[ATENCAO]`/`[BLOQUEADO]`/`[ANS]` para validacao com PO/DBA
- Confirmacao final com caminhos dos arquivos criados/atualizados

# Handoff

Apos aprovacao no Painel de Decisao, a RE pode ser referenciada por specs Improvement+Tunning
via `[REF: .specs/reverse-engineering/plsql/<NOME>/rev-NNN-<TAG>/]` - elimina necessidade de
releitura do codigo bruto na fase Specify.
