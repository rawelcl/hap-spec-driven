# Knowledge Verification Chain

**Cadeia de verificacao explicita do framework Hapvida.**

Antes de qualquer afirmacao tecnica, decisao de design, geracao de codigo ou pesquisa, o agente
DEVE percorrer esta cadeia EM ORDEM. **Nunca pular passos.**

```
Passo 1: Codebase
  ├── PL/SQL
  │   ├── 1a. .specs/reverse-engineering/plsql|forms/<obj>/rev-NNN-<TAG>/  (RE cacheada - rev mais recente, se TAG bate com PRODUCAO)
  │   └── 1b. WinCVS tag PRODUCAO                              (se RE ausente/stale)
  │       [GUARDRAIL] NUNCA banco produtivo para dados de negocio
  │       [GUARDRAIL] MCP Oracle so para dicionario (dba_*) e dba_source - ver ADR-007 emendada
  └── Java/.NET: ADO Repos branch main

Passo 2: Project docs
  ├── .specs/codebase/ (brownfield mapping)
  ├── .specs/features/ (specs anteriores)
  ├── .specs/project/STATE.md, PROJECT.md
  └── Wiki Arquitetura-Referencia (>96 ADRs corporativas)

Passo 3: Context7 MCP
  └── Para libraries, frameworks, APIs (resolve library ID -> query API/patterns atuais)

Passo 4: Web search
  └── Documentacao oficial ANS, padroes, fontes reputadas

Passo 5: Flag uncertain
  └── "Nao sei" ou "Nao encontrei" - SEMPRE [REVISAO] ou [BLOQUEADO]
```

## Regras inegociaveis

1. **Nunca pular para Step 5** se Steps 1-4 sao acessiveis
2. **Step 5 e SEMPRE marcado** como `[REVISAO]` ou `[BLOQUEADO]` - nunca apresentado como fato
3. **NUNCA assumir ou fabricar.** Se nao encontrar resposta, diga explicitamente "nao sei" ou
   "nao encontrei documentacao para isso". Inventar API, padrao ou comportamento que nao existe e
   muito pior do que admitir incerteza.
4. **Incerteza propaga em cascata.** Premissa errada na fase Specify se torna codigo errado em
   Execute. Cuide na origem.

## Adaptacoes Hapvida em relacao ao TLC

| Step | TLC | Hapvida (adaptacao) |
|---|---|---|
| 1 - Codebase | Generico (codebase do projeto) | Bi-VCS explicito: WinCVS tag PRODUCAO (PL/SQL) ou ADO Repos main (Java/.NET). Para PL/SQL: priorizar RE cacheada em `.specs/reverse-engineering/` (ADR-011) antes de ler CVS bruto. MCP Oracle autorizado apenas para dicionario (ADR-007 emendada) |
| 2 - Project docs | `.specs/`, README, docs/ | Adiciona Wiki Arquitetura-Referencia como RAG primario (>96 ADRs corporativas) |
| 3 - Context7 MCP | Idem | Idem - so adiciona que MCP do ADO local complementa para metadados ADO |
| 4 - Web search | Sources reputadas | Inclui explicitamente sites oficiais ANS (gov.br/ans), Lei 9.656/98, RNs |
| 5 - Flag uncertain | "I don't know" | Idem + tokens textuais Hapvida (`[REVISAO]`, `[BLOQUEADO]`) |

## Como aplicar em cada fase

### Specify

- **Step 1**: Existe spec/codigo similar? Sim -> referenciar.
- **Step 2**: Existe ADR sobre essa decisao? Existe `.specs/codebase/CONCERNS.md` apontando area
  fragil tocada por essa feature?
- **Step 3-4**: Apenas se necessario para entender contexto tecnico (raramente em Specify)
- **Step 5**: Premissas explicitas como `[PREMISSA]` no template da spec

### Design

- **Step 1**: Reuso de codigo (Code Reuse Analysis)
- **Step 2**: ADRs aplicaveis citadas via `[REF: ADR-XX]`
- **Step 3**: Para framework/library novo, Context7 resolve patterns atuais
- **Step 4**: Para dominio regulatorio, oficial ANS
- **Step 5**: Decisoes nao baseadas em fonte clara -> `[REVISAO]` exigida

### Tasks

- **Step 1**: TESTING.md, padroes de testes existentes
- **Step 2**: Convencoes de commit (per ADR e este framework)
- **Step 3-4**: Raramente
- **Step 5**: Tasks com dependencias incertas -> `[BLOQUEADO]`

### Execute

- **Step 1**: Codigo a estender, padroes a seguir (cabecalho de comentario PL/SQL)
- **Step 2**: ADR aplicavel para padrao de implementacao
- **Step 3**: Documentacao de API/library especifica
- **Step 4**: Stack overflow, blogs reputados quando necessario
- **Step 5**: SPEC_DEVIATION quando implementacao precisa divergir

## Exemplos praticos

### Exemplo 1: Refatoracao PL/SQL (Improvement+Tunning)

**Pergunta:** Como otimizar a procedure `pkg_proposta.calcula_carencia` que esta com performance ruim?

**Cadeia:**

1. **Step 1** (Codebase WinCVS PRODUCAO): le o codigo atual de `pkg_proposta` na tag PRODUCAO via
   skill `sigo-modernizacao-plsql`. Identifica cursor row-by-row em loop interno.
2. **Step 2** (Wiki ADRs): consulta `[REF: ADR-22]` (Padrao Repositorio) e identifica padrao
   homologado para data access. Verifica se existe ADR sobre uso de BULK COLLECT/FORALL.
3. **Step 3** (Context7): nao se aplica (PL/SQL Oracle nativo, sem framework externo)
4. **Step 4** (Web): nao se aplica (resposta esta nos passos anteriores)
5. **Decisao:** refatorar usando BULK COLLECT/FORALL conforme padrao homologado, citando ADR 22.

### Exemplo 2: Feature regulatoria nova

**Pergunta:** Como implementar nova regra de carencia maxima por faixa etaria conforme RN ANS recente?

**Cadeia:**

1. **Step 1** (Codebase): verifica como carencia atual e calculada (`pkg_proposta` na PRODUCAO)
2. **Step 2** (Wiki ADRs + ANS knowledge): consulta `[REF: ADR-21]` (Linguagem Onipresente) para
   termos canonicos. **`[ANS]`** Lei 9.656/98 art. 12 + RN ##### art. Y.
3. **Step 3-4** (Web search ANS gov.br): busca o texto oficial da RN especifica
4. **Step 5**: se ainda incerto sobre interpretacao -> `[REVISAO]` por Compliance/Juridico/Atuarial.
5. **Decisao:** spec com `[ANS]` em todas as regras, citando RN especifica.

### Exemplo 3: Integracao com novo framework Java

**Pergunta:** Como integrar nova library de cache distribuido ao servico Java?

**Cadeia:**

1. **Step 1** (ADO Repos): existe servico Java similar usando cache? Sim -> seguir padrao.
2. **Step 2** (Wiki ADRs): `[REF: ADR-24]` (Linguagens e Frameworks Homologados para Backend) -
   library esta na lista homologada?
3. **Step 3** (Context7 MCP): `mcp_context7_resolve-library-id` + `get-library-docs` para padroes
   atuais
4. **Step 4** (Web): documentacao oficial da library
5. **Decisao:** se library nao homologada -> `[ADR-AUSENTE]` proposta de inclusao na ADR 24 antes
   de avancar.

## Antipatterns a recusar

| Antipattern | Por que recusar |
|---|---|
| Pular para Step 5 sem tentar Steps 1-4 | Inventar e o pior pecado |
| Apresentar Step 4 como certo sem citar fonte | Fontes reputadas precisam citacao explicita |
| Marcar `[REVISAO]` ou `[BLOQUEADO]` e seguir mesmo assim | Marcadores existem para BLOQUEAR avanco |
| Citar ADR sem ler o conteudo | Citacao deve refletir entendimento real do que a ADR diz |
| Assumir que codigo PL/SQL no banco esta na PRODUCAO tag | `[GUARDRAIL]` Pode haver drift; sempre WinCVS PRODUCAO como fonte |
| Usar dados reais de beneficiario para "testar" no Copilot | `[GUARDRAIL]` Anonimizacao obrigatoria |

## Output esperado quando aplicado

Toda spec, design ou decisao tecnica gerada pelo framework deve mostrar a cadeia percorrida (mesmo
que brevemente). Padrao recomendado:

```markdown
## Pesquisa realizada (Knowledge Verification Chain)

| Topico | Step alcancado | Fonte | Confianca |
|---|---|---|---|
| Calculo de carencia atual | Step 1 (CVS PRODUCAO) | `pkg_proposta.calcula_carencia` | Alta |
| Padrao de data access | Step 2 (ADR) | `[REF: ADR-22]` | Alta |
| Patterns BULK COLLECT atuais | Step 3 (Context7) | Oracle docs PL/SQL Performance | Alta |
| RN ANS aplicavel | Step 4 (Web ANS gov.br) | `[ANS]` RN ##### art. Y | Media - validar com Compliance |
| Interpretacao de "faixa etaria" para novo plano coletivo | Step 5 | - | `[REVISAO]` exigida |
```
