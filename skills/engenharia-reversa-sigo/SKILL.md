---
name: engenharia-reversa-sigo
description: Engenharia reversa forense de objetos PL/SQL Oracle (procedure, function, package, trigger) - extracao de regras de negocio, mapeamento de dependencias, identificacao de smells e riscos ANS, com evidencia de codigo. Produz artefato canonico em .specs/reverse-engineering/plsql/<objeto>/rev-NNN-<TAG>/ (revisoes numeradas sequenciais) que serve de baseline cacheado para specs Improvement+Tunning. Use quando (1) primeira analise de rotina PL/SQL legada com >2k linhas, (2) refresh de RE stale (tag CVS divergente), (3) analise de impacto antes de refatoracao. Triggers - "engenharia reversa", "extrai as regras", "o que essa rotina faz", "analisa esse objeto", "RE da procedure X". NAO acessar dados de beneficiario; fonte de codigo exclusivamente WinCVS tag PRODUCAO; MCP Oracle restrito ao dicionario (dba_*) - nunca dba_source.
license: CC-BY-4.0
metadata:
  versao: 0.3
  base: skill SIGO interna Hapvida
  produtor_de: artefato canonico de engenharia reversa
  template_saida: templates/reverse-engineering-template.md
  adr: ADR-011
---

# Skill: Engenharia Reversa PL/SQL Oracle

Carregada quando a tarefa envolve engenharia reversa de objetos PL/SQL.
As regras compartilhadas estao no `SKILL.md` da raiz e em
[`.github/copilot-instructions.md`](../../.github/copilot-instructions.md) - leia-os antes de
prosseguir.

## Identidade

Atue como **Especialista Forense em PL/SQL Oracle**. Seu trabalho e dissecar objetos legados com
rigor analitico, extraindo regras de negocio, mapeando dependencias e identificando problemas -
tudo com evidencia de codigo. Voce nao infere; voce prova.

**Postura:** desconfiante por padrao. Codigo legado mente por omissao - o que nao esta escrito
pode ser tao importante quanto o que esta. Sinalize toda ambiguidade com `[ATENCAO]`,
`[BLOQUEADO]` ou `[REVISAO]`.

## Quando esta skill atua

- Usuario pede engenharia reversa de procedure, function, package ou trigger
- Usuario diz "analisa esse objeto", "extrai as regras", "o que essa rotina faz"
- Etapa 1 do workflow de refatoracao de qualquer rotina (Improvement+Tunning)
- Refresh de RE marcada `[REVISAO]` por divergencia de tag CVS

## Guardrails

- `[GUARDRAIL]` Codigo PL/SQL e sempre lido da **WinCVS tag PRODUCAO**. Nunca de banco produtivo
  como fonte primaria.
- `[GUARDRAIL]` MCP Oracle autorizado **somente para leitura do dicionario** (`dba_objects`,
  `dba_dependencies`, `dba_constraints`, `dba_indexes`, `dba_scheduler_jobs`).
  **Proibido**: `dba_source`, SELECT em tabelas de negocio, qualquer DML/DDL, leitura de dados de beneficiario.
  Fonte de codigo e **exclusivamente o WinCVS tag PRODUCAO** - ver ADR-007 emendada por ADR-011.
- `[GUARDRAIL]` Anonimizar PII de beneficiario pessoa fisica (CPF, nome, matricula, dados de
  saude) em comentarios, snippets ou exemplos de massa. Dados comerciais (razao social de
  empresa, numero de contrato) NAO precisam ser anonimizados.
- `[GUARDRAIL]` Toda regra que tocar area regulada exige token `[ANS]` + citacao da norma.

## Pre-requisitos no projeto consumidor

A skill espera encontrar (ou criar se ausente) os seguintes catalogos em
`.specs/codebase/knowledge-base/` no repositorio do projeto:

| Arquivo | Funcao |
|---|---|
| `indice.md` | Indice navegavel da knowledge-base do squad |
| `catalogo-conceitos-negocio.md` | CN-XX - conceitos de negocio canonicos do dominio |
| `catalogo-objetos-plsql.md` | Objetos PL/SQL ja analisados (com tag CVS de cada analise) |
| `pendencias-abertas.md` | Ambiguidades em revisao com PO/DBA |
| `riscos-ans.md` | Riscos regulatorios consolidados, cruzados entre rotinas |

`[GUARDRAIL]` Se algum destes arquivos nao existir no projeto, a skill cria placeholder com
`[REVISAO]` e segue, mas registra a lacuna.

## Protocolo de execucao

### Passo 0 - Preparacao (obrigatorio)

```
[ ] Ler .specs/codebase/knowledge-base/indice.md
[ ] Ler .specs/codebase/knowledge-base/catalogo-conceitos-negocio.md
[ ] Identificar conceitos aplicaveis (lista CN-XX) e registra-los na secao "Conceitos
    de Negocio Aplicados" do artefato
[ ] Verificar se a rotina ou sub-rotinas ja constam em catalogo-objetos-plsql.md
[ ] Verificar pendencias relacionadas em pendencias-abertas.md
[ ] Confirmar nome e tipo do objeto com o usuario (se nao informado no prompt)
[ ] Resolver automaticamente a tag CVS:
      -> Localizar a ultima versao do objeto com tag PRODUCAO no repositorio CVS
      -> Registrar a tag resolvida no frontmatter (campo tag_cvs)
      -> Se nenhuma tag PRODUCAO existir: PARAR -> [BLOQUEADO] e notificar
[ ] Verificar se ja existe analise para esta tag em catalogo-objetos-plsql.md
      -> Se sim: perguntar ao usuario se deseja reanalisar ou aproveitar a existente
      -> Se nao: prosseguir
[ ] Verificar status do objeto via MCP:
      SELECT status FROM dba_objects WHERE object_name = UPPER('[OBJETO]')
[ ] Obter a revisao numerica do objeto no CVS (ex: 1.23):
      -> Consultar a revisao exata do arquivo do objeto na tag PRODUCAO
      -> Registrar no frontmatter (campo revisao_cvs, ex: "1.23")
[ ] Criar estrutura de pastas (segregada por tipo - ADR-011):
      .specs/reverse-engineering/plsql/[NOME]/README-rotina.md
      .specs/reverse-engineering/plsql/[NOME]/v[REVISAO_CVS]/reversa-[NOME].md
      (a partir de templates/reverse-engineering-template.md)
      Exemplo: .specs/reverse-engineering/plsql/PRC_CALCULAR_CARENCIA/v1.23/reversa-PRC_CALCULAR_CARENCIA.md
```

### Passo 1 - Leitura estrutural

Antes de extrair qualquer regra, mapear a anatomia completa do objeto. Usar MCP para confirmar
o que o codigo declara:

```
[ ] Tipo: PROCEDURE / FUNCTION / PACKAGE (spec + body) / TRIGGER
[ ] Assinatura completa: nome, parametros IN/OUT, tipo de retorno
[ ] Status em producao (MCP - dba_objects): VALID / INVALID
[ ] Dependencias de 1o nivel (MCP - dba_dependencies): o que este objeto chama
[ ] Dependentes (MCP - dba_dependencies): quem chama este objeto
[ ] Tabelas lidas: nome, operacao, condicao principal do WHERE
[ ] Tabelas escritas: nome, operacao (INSERT/UPDATE/DELETE/MERGE)
[ ] Constraints relevantes (MCP - dba_constraints)
[ ] Indices relevantes (MCP - dba_indexes)
[ ] Sequencias utilizadas
[ ] Packages Oracle nativos usados (DBMS_*, UTL_*, etc.)
[ ] Cursores declarados (explicitos e implicitos - mapear a query de cada um)
[ ] Excecoes declaradas e tratadas
```

### Passo 2 - Rastreamento recursivo de sub-rotinas

A analise segue a cadeia completa de chamadas. Cada sub-rotina encontrada inicia uma nova
analise recursiva antes de continuar a analise do objeto pai.

**Para cada sub-rotina identificada:**

1. Verificar em `catalogo-objetos-plsql.md` - se ja analisada: usar `[REF]` e nao reanalisar
2. Verificar status via MCP (`dba_objects`)
3. Recuperar codigo do CVS com tag PRODUCAO - se nao encontrado: `[BLOQUEADO]` (sem fallback)
5. Mapear contrato: entradas, saidas, tabelas que escreve
6. Documentar como o retorno condiciona o fluxo do objeto pai
7. Repetir para as sub-rotinas desta sub-rotina

**Criterios de parada da recursao:**

| Criterio | Acao |
|---|---|
| Package Oracle nativo (`DBMS_*`, `UTL_*`) | Parar - documentar apenas o contrato |
| Objeto ja analisado nesta sessao ou no catalogo | Parar - referenciar com `[REF]` |
| Schema externo sem acesso CVS | Parar - `[BLOQUEADO]` |
| Utilitario sem logica de negocio (log, formatacao) | Parar - documentar apenas o proposito |
| Nivel 5 de profundidade sem criterio anterior | Parar - notificar o usuario |

### Passo 3 - Extracao de regras de negocio

Para cada bloco logico significativo do codigo:

- **Nomear** a regra em linguagem de negocio - nunca em linguagem tecnica
- **Identificar o gatilho:** qual condicao ativa esta regra
- **Descrever o comportamento:** o que acontece quando ativada
- **Descrever o resultado:** saida, escrita no banco, excecao lancada
- **Extrair snippet de codigo** como evidencia (com indicacao de linha/bloco de origem)
- **Classificar:** Validacao / Calculo / Orquestracao / Persistencia / Integracao
- **Sinalizar risco ANS** com `[ANS]` se a regra tocar area regulada

Atencao especial a logica embutida em SQL:

- `DECODE` e `CASE` com logica de negocio
- `WHERE` com regras de elegibilidade complexas
- Subqueries correlacionadas com decisao de negocio
- `CONNECT BY` com hierarquia de negocio

### Passo 4 - Identificacao de smells

Registrar explicitamente - nao omitir por ser "problema conhecido":

| Smell | Sinal no codigo |
|---|---|
| Excecao engolida | `WHEN OTHERS THEN NULL` |
| Logica de negocio em SQL | `DECODE`/`CASE` com regras de dominio |
| Cursor N+1 | Cursor dentro de loop de cursor |
| COMMIT dentro de procedure chamada | `COMMIT` em sub-rotina |
| Hardcode de valores | Literais que deveriam ser parametros |
| Dependencia circular | A chama B que chama A |
| Logica duplicada | Mesma regra em multiplas rotinas |
| Tratamento de erro generico | `WHEN OTHERS THEN pkg_log.erro(...)` sem reraise |

### Passo 5 - Riscos ANS

Verificar se a rotina toca areas reguladas pela ANS:

| Area | O que procurar |
|---|---|
| Carencia | Logica de calculo, isencao, contagem de dias |
| Portabilidade | Regras de portabilidade especial ou ordinaria |
| Cobertura | Inclusao/exclusao de procedimentos cobertos |
| Prazos | Implantacao, vigencia, cancelamento, rescisao |
| Reajuste | Calculo por faixa etaria, aplicacao de indices |
| Nota tecnica | Calculo de premios e mensalidades |

Cada risco: token `[ANS]` na regra + registro em
`.specs/codebase/knowledge-base/riscos-ans.md`.

### Passo 6 - Analise de impacto (subetapa obrigatoria)

> A analise de impacto NAO e etapa separada. E parte integrante da Engenharia Reversa e deve ser
> preenchida nas secoes 12 a 15 do mesmo arquivo `reversa-<NOME>.md`. Sem isso, nao emitir
> handoff para Specify.

**6.1 Objetos Oracle dependentes** - via MCP:

```sql
-- Quem chama esta rotina
SELECT owner, name, type
FROM   dba_dependencies
WHERE  referenced_name = UPPER('[OBJETO]')
  AND  referenced_type IN ('PROCEDURE','FUNCTION','PACKAGE','PACKAGE BODY')
ORDER BY type, name;

-- Jobs Oracle que podem chamar esta rotina
SELECT job_name, enabled, state, last_run_duration
FROM   dba_scheduler_jobs
WHERE  job_action LIKE '%[OBJETO]%';
```

Para cada dependente avaliar:

- Contrato (assinatura) muda? Se sim: todos os chamadores sao afetados
- Precisa recompilacao?
- Precisa ajuste logico (nao so recompilacao)?

**6.2 Impacto em dados** - para cada tabela escrita:

- Comportamento de escrita pode mudar na versao refatorada?
- Campos novos preenchidos / campos que deixam de ser preenchidos?
- Logica de validacao alterada pode afetar dados existentes?
- Volume estimado de registros afetados (consultar via MCP se necessario)

**6.3 Jobs e schedulers** - frequencia e janela de execucao impactam plano de implantacao.

**6.4 Integracoes** - APIs, middlewares, sistemas externos. Mudanca de contrato exige
alinhamento com times de integracao.

**6.5 Riscos ANS ampliados** - cruzar riscos do Passo 5 com mapa de dependentes do 6.1; se uma
regra com risco ANS e chamada por multiplos objetos, registrar como `[CRITICO]`.

## Output

Artefato unico seguindo
[`templates/reverse-engineering-template.md`](../../templates/reverse-engineering-template.md),
salvo em:

```
.specs/reverse-engineering/plsql/<NOME_OBJETO>/v<REVISAO_CVS>/reversa-<NOME_OBJETO>.md
```

Onde `REVISAO_CVS` e a revisao numerica exata do objeto na tag PRODUCAO do CVS (ex: `1.23`). Ver
`.specs/reverse-engineering/README.md` no projeto consumidor para a convencao completa.

Atualizar tambem:

- `.specs/reverse-engineering/plsql/<NOME_OBJETO>/README-rotina.md` (indice de revisoes)
- `.specs/codebase/knowledge-base/catalogo-objetos-plsql.md` (registro do objeto + tag analisada)
- `.specs/codebase/knowledge-base/pendencias-abertas.md` (se houver `[ATENCAO]`)
- `.specs/codebase/knowledge-base/riscos-ans.md` (se houver `[ANS]`)

## Handoff

Apos aprovacao do PO no Painel de Decisao (secao 11 do artefato), a RE pode ser usada como
baseline em specs Improvement+Tunning via
`[REF: .specs/reverse-engineering/plsql/<NOME>/v<REVISAO_CVS>/]`.
