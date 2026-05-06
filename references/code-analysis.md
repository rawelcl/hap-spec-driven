# Code Analysis

**Goal:** Usar ferramentas locais para analisar codebase com graceful degradation.

## Hierarquia de ferramentas

```
ast-grep (semantic, AST-aware)
   |
   v fallback se nao disponivel
ripgrep (rg - regex rapido)
   |
   v fallback se nao disponivel
grep (POSIX classico)
```

## Por que essa ordem

| Ferramenta | Vantagem | Limitacao |
|---|---|---|
| **ast-grep** | Entende sintaxe da linguagem; menos falso positivo | Nem todas as linguagens cobertas; PL/SQL especialmente limitado |
| **ripgrep** | Rapido, suporta regex moderno, respeita .gitignore | Nao entende sintaxe |
| **grep** | Universalmente disponivel | Lento, regex POSIX limitado |

## Padroes de uso

### Encontrar definicao de funcao Java

```bash
# ast-grep
ast-grep --pattern 'public $RET $NAME($$$_) { $$$_ }' --lang java

# ripgrep fallback
rg 'public.*\w+\s*\(' --type java
```

### Encontrar uso de procedure PL/SQL

```bash
# ast-grep nao suporta bem PL/SQL - usar rg
rg -i 'pkg_proposta\.calcula_carencia' --type sql
```

### Encontrar referencias cross-modulo

```bash
rg 'BeneficiarioService' src/
```

## Guardrails

- **`[GUARDRAIL]`** Analise sempre acontece em codigo local (workspace, baseline da tag PRODUCAO no
  CVS clonado, branch main do ADO Repos clonado)
- **`[GUARDRAIL]`** **NUNCA** acessar banco produtivo via MCP para "ver o codigo real" - codigo real
  vive na tag PRODUCAO

## Adaptacoes Hapvida

- Para PL/SQL: `rg` e o default na pratica (ast-grep limitado em PL/SQL)
- Para Java/.NET: `ast-grep` quando disponivel, `rg` fallback
- Skill `sigo-modernizacao-plsql` ja embutiu logica de busca em PL/SQL legado - prefira a skill
  quando aplicavel
