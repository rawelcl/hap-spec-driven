---
objeto: <SCHEMA.NOME>
tipo: <PROCEDURE | FUNCTION | PACKAGE | TRIGGER>
schema: <schema>
tag_cvs: <PRODUCAO-X.Y.Z>
revisao_cvs: <X.YY>
tag_resolvida_em: YYYY-MM-DD
analista: <nome>
status_producao: <VALID | INVALID>
fonte_codigo: <C:\CVS\health_install\...>
linhas_aproximadas: <numero>
sub_rotinas_referenciadas: []
dependentes_referenciados: []
tabelas_lidas: []
tabelas_escritas: []
riscos_ans: []
versao_artefato: 0.1
ultima_atualizacao: YYYY-MM-DD
---

# Engenharia Reversa: <NOME_DA_ROTINA>

> Artefato gerado pela skill [`engenharia-reversa-sigo`](../../skills/engenharia-reversa-sigo/SKILL.md).
> Camada de baseline cacheada - ver [ADR 011](../adr/011-engenharia-reversa-como-baseline.md).
>
> `[GUARDRAIL]` Comparar `tag_cvs` deste artefato com tag PRODUCAO atual antes de usar como
> fonte de verdade. Divergente -> marcar `[REVISAO]` e disparar refresh.

---

## 1. Assinatura

| Atributo | Valor |
|---|---|
| Tipo | <PROCEDURE / FUNCTION / PACKAGE> |
| Schema | <schema> |
| Nome | <nome> |
| Parametros de Entrada | <lista> |
| Parametros de Saida | <lista> |
| Retorno (se function) | <tipo> |

---

## 2. Arvore de Dependencias

### 2.1 Sub-rotinas chamadas

| Sub-rotina | Tipo | Schema | Responsabilidade | Impacto no fluxo | Status |
|---|---|---|---|---|---|
| <nome> | Procedure | <schema> | <o que faz> | <como condiciona o pai> | [OK] / [BLOQUEADO] / [REF] |

### 2.2 Dependentes (quem chama esta rotina)

| Objeto | Tipo | Schema | Fonte |
|---|---|---|---|
| <nome> | <tipo> | <schema> | MCP `dba_dependencies` |

### 2.3 Tabelas acessadas

| Tabela | Operacao | Condicao principal (WHERE) | Observacao |
|---|---|---|---|
| <nome> | SELECT/INSERT/UPDATE/DELETE/MERGE | <where> | <obs> |

### 2.4 Outros objetos

| Objeto | Tipo | Finalidade |
|---|---|---|
| <sequence/package/dblink> | <tipo> | <para que> |

---

## 3. Conceitos de Negocio Aplicados

Conceitos de `.specs/codebase/knowledge-base/catalogo-conceitos-negocio.md` ativos nesta rotina:

- `[CN-01]` <nome do conceito> - <como aparece nesta rotina>
- `[CN-XX]` ...

---

## 4. Regras de Negocio

### RN01 - <Nome em linguagem de negocio>

- **Categoria:** Validacao / Calculo / Orquestracao / Persistencia / Integracao
- **Risco ANS:** `[ANS]` <descricao> ou N/A
- **Gatilho:** <condicao>
- **Comportamento:** <o que acontece>
- **Resultado:** <saida / escrita / excecao>
- **Ambiguidade:** `[ATENCAO]` <descricao> ou N/A

**Evidencia:**

```sql
-- Origem: <nome_do_objeto>, aprox. linha <N>
<snippet do codigo>
```

---

## 5. Fluxo de decisao (narrativa)

<Descricao textual do fluxo principal, em linguagem de negocio, na ordem de execucao.>

---

## 6. Matriz de regras

| ID | Gatilho | Logica | Resultado | Categoria | Risco ANS |
|---|---|---|---|---|---|
| RN01 | ... | ... | ... | Validacao | `[ANS]` / N/A |

---

## 7. Smells identificados

| ID | Tipo | Localizacao | Impacto | Sugestao |
|---|---|---|---|---|
| S01 | <tipo> | <bloco/linha> | Alto/Medio/Baixo | <sugestao> |

Categorias tipicas:

- Excecao engolida (`WHEN OTHERS THEN NULL`)
- Logica de negocio em SQL (DECODE/CASE com regras de dominio)
- Cursor N+1 (cursor dentro de loop de cursor)
- COMMIT em sub-rotina chamada
- Hardcode de valores que deveriam ser parametros
- Dependencia circular
- Logica duplicada entre rotinas
- `WHEN OTHERS THEN pkg_log.erro(...)` sem reraise

---

## 8. Tratamento de excecoes

| Excecao | ORA- | Quando ocorre | Tratamento atual | Recomendado |
|---|---|---|---|---|
| <nome> | <codigo> | <condicao> | <o que faz> | <o que deveria> |

---

## 9. Riscos ANS

| ID | Area | Descricao | Regras | Severidade | Acao |
|---|---|---|---|---|---|
| ANS01 | Carencia / Portabilidade / Cobertura / Prazos / Reajuste / Nota tecnica | <descricao> | RN0X | Alta/Media/Baixa | <acao> |

Cada risco ANS tambem deve ser registrado em `.specs/codebase/knowledge-base/riscos-ans.md`.

---

## 10. Ecossistema

- **Input:** <tabelas/sistemas de origem>
- **Output:** <tabelas/sistemas de destino>

---

## 11. Painel de decisao (PO)

Ambiguidades e pendencias para validacao com PO/DBA:

| ID | Descricao | Tipo | Acao |
|---|---|---|---|
| A01 | <descricao> | `[ATENCAO]` / `[CRITICO]` / `[ANS]` | Validar com PO/DBA |

**Aprovacao:**

- [ ] Aprovado - seguir com as regras extraidas
- [ ] Aprovado com ressalvas: <detalhar>
- [ ] Reprovado - redesenhar antes de continuar

Pendencias abertas devem ser registradas em `.specs/codebase/knowledge-base/pendencias-abertas.md`.

---

## 12. Mapa de dependentes (analise de impacto)

| Objeto | Tipo | Schema | Como usa | Impacto | Acao necessaria |
|---|---|---|---|---|---|
| <nome> | Procedure / Job | <schema> | <como chama> | Nenhum / Contrato / Recompilacao | <acao> |

- **Total de dependentes:** <N>
- **Dependentes criticos:** <N>

---

## 13. Impacto em dados

| Tabela | Comportamento atual | Risco em refatoracao | Volume estimado |
|---|---|---|---|
| <T_XXXX> | INSERT sem idempotencia | Medio: dependentes esperam efeito colateral | <N registros/dia> |

---

## 14. Jobs e integracoes

| Job / sistema | Frequencia / canal | Impacto | Acao necessaria |
|---|---|---|---|
| <JOB_EFETIVACAO> | Diario 02:00 | Nenhum | - |

---

## 15. Riscos ANS ampliados

Cruzamento dos riscos da secao 9 com o mapa de dependentes da secao 12:

| Risco ANS | Rotinas dependentes afetadas | Severidade ampliada | Acao |
|---|---|---|---|
| ANS01 | <lista> | `[CRITICO]` | <acao urgente> |

---

## 16. Handoff

- [ ] Artefato aprovado para servir de baseline em specs Improvement+Tunning
- [ ] Catalogo `.specs/codebase/knowledge-base/catalogo-objetos-plsql.md` atualizado com este objeto
- [ ] Pendencias registradas em `pendencias-abertas.md`
- [ ] Riscos ANS registrados em `riscos-ans.md`
