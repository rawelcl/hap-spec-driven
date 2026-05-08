# Guia Rapido — Framework Spec-Driven Hapvida

Cheat sheet para o dia a dia. Todos os comandos sao digitados no **GitHub Copilot Chat** em modo Agent.

---

## Comandos `/` disponiveis

### Inicializacao e contexto

| Comando | Quando usar |
|---|---|
| `/hap-sd-init` | Inicializar estrutura `.specs/` no repo do squad |
| `/hap-sd-map` | Mapear codebase brownfield existente |
| `/hap-sd-discuss` | Discutir/explorar feature antes de especificar |

### Ciclo principal

| Comando | Fase | Quando usar |
|---|---|---|
| `/hap-sd-specify` | Specify | Gerar spec a partir de work item ADO |
| `/hap-sd-design` | Design | Gerar design tecnico (features medias/grandes) |
| `/hap-sd-tasks` | Tasks | Decompor design em tasks e sincronizar no ADO |
| `/hap-sd-implement` | Execute | Implementar task com contexto da spec |
| `/hap-sd-validate` | Validate | Validar spec gerada contra criterios do framework |

### Especializados

| Comando | Quando usar |
|---|---|
| `/hap-sd-spec-wi` | Spec a partir de work item ADO (alternativo ao specify) |
| `/hap-sd-spec-plsql` | Spec a partir de baseline de engenharia reversa PL/SQL |
| `/hap-sd-spec-lecom` | Spec a partir de fluxo Lecom |
| `/hap-sd-re-plsql` | Engenharia reversa de procedure/function/package PL/SQL |
| `/hap-sd-re-forms` | Engenharia reversa de Oracle Forms (.fmb) |
| `/hap-sd-snapshot` | Publicar snapshot da spec no work item ADO |
| `/hap-sd-roadmap` | Gerar/atualizar ROADMAP.md do projeto |
| `/hap-sd-concerns` | Documentar concerns tecnicas e riscos |
| `/hap-sd-decision` | Registrar ADR (Architectural Decision Record) |
| `/hap-sd-handoff` | Gerar HANDOFF.md ao final da sessao |

---

## Fluxo tipico por tamanho

### Feature pequena (bug fix, ajuste simples, ≤ 3 arquivos)

```
1. /hap-sd-specify     <- gera spec inline
2. /hap-sd-tasks       <- gera tasks e sincroniza no ADO
3. /hap-sd-implement   <- implementa
4. /hap-sd-snapshot    <- publica snapshot no WI ao ir para Approved
```

### Feature media (nova funcionalidade, modulo)

```
1. /hap-sd-discuss     <- opcional, alinhar entendimento
2. /hap-sd-specify     <- spec completa
3. /hap-sd-design      <- design tecnico
4. /hap-sd-tasks       <- tasks decompostas + sync ADO
5. /hap-sd-implement   <- task por task
6. /hap-sd-validate    <- validar spec
7. /hap-sd-snapshot    <- publicar snapshot
```

### Engenharia reversa de PL/SQL

```
1. /hap-sd-re-plsql    <- analisar objeto (parte da TAG PRODUCAO WinCVS)
2. /hap-sd-spec-plsql  <- gerar spec a partir do baseline RE
3. /hap-sd-design      <- design da refatoracao/alteracao
4. /hap-sd-tasks       <- tasks + sync ADO
```

---

## Convencoes de commit

```
WI-1234: feat(comercial): adiciona calculo de carencia PME
WI-1234: fix(cotacao): corrige arredondamento de mensalidade
WI-1234: refactor(pkg_contrato): extrai procedure de validacao
WI-1234: docs(specs): atualiza spec.md com criterios ANS
```

Formato: `WI-<id>: <type>(<scope>): <descricao em portugues ou ingles>`

---

## Estrutura de pastas RE (engenharia reversa)

```
.specs/reverse-engineering/
  <nome-do-objeto>/
    README-<nome-do-objeto>.md         <- ficha do objeto (FORA da versao)
    v1.23-rev-001/                     <- v<VERSAO_CVS>-rev-<NNN>
      re-<nome-do-objeto>.md
    v1.24-rev-002/
      re-<nome-do-objeto>.md
```

`[GUARDRAIL]` A versao (`v1.23`) vem da TAG DE PRODUCAO no WinCVS — nunca do banco.

---

## Tokens de sinalizacao no chat

| Token | Significado |
|---|---|
| `[GUARDRAIL]` | Restricao inegociavel — nao prosseguir sem resolver |
| `[ANS]` | Toque em area regulada — citar norma ANS obrigatorio |
| `[BLOQUEADO]` | Avancar requer decisao/informacao externa |
| `[ADR-AUSENTE]` | ADR aplicavel nao existe — criar antes de prosseguir |
| `[ATENCAO]` | Ponto que exige revisao manual |
| `[REF: ...]` | Referencia a artefato (spec, ADR, WI) |

---

## Guardrails criticos

- **Nunca** acesse o banco produtivo para obter codigo PL/SQL
- **Nunca** use como baseline codigo que nao seja a TAG PRODUCAO do WinCVS
- **Nunca** exponha CPF, nome ou dados de saude de beneficiario pessoa fisica
- **Sempre** cite a norma ANS ao tocar em regras reguladas
