# Context Limits

**Goal:** Manter o contexto carregado dentro de limites praticos.

**Alvo:** <40k tokens de carga ativa.

## Por que importa

LLMs tem janela de contexto finita. Encher o contexto com docs irrelevantes:
- Aumenta custo
- Aumenta latencia
- Reduz qualidade (lost in the middle)
- Aumenta risco de instrucao injetada

## Estrategia de carregamento

### Carga base (~15k tokens)

- `.specs/project/PROJECT.md` (se existir)
- `.specs/project/ROADMAP.md` (se existir e relevante)
- `.specs/project/STATE.md` (sempre)

### Sob demanda

| Quando | Carregar |
|---|---|
| Iniciando trabalho em projeto existente | `.specs/codebase/STACK.md`, `STRUCTURE.md`, `CONVENTIONS.md` |
| Tocando area fragil ou planejando refatoracao | `.specs/codebase/CONCERNS.md` |
| Criando tasks ou executando | `.specs/codebase/TESTING.md` |
| Trabalhando em uma feature | `.specs/features/[feature]/spec.md` |
| Designando ou implementando a partir de discussao | `.specs/features/[feature]/context.md` |
| Implementando | `.specs/features/[feature]/design.md` |
| Executando | `.specs/features/[feature]/tasks.md` |

## Nunca carregar simultaneamente

- Specs de multiplas features
- Multiplos docs de arquitetura conflitantes
- Documentos arquivados
- Codigo completo de modulos nao relacionados ao trabalho atual

## Tamanho de cada doc - alvos

| Doc | Alvo | Maximo aceitavel |
|---|---|---|
| spec.md | 3-5k tokens | 8k |
| context.md | 1-2k | 3k |
| design.md | 3-5k | 8k |
| tasks.md | 3-5k | 8k |
| STACK.md | 1-3k | 5k |
| ARCHITECTURE.md | 3-5k | 8k |
| TESTING.md | 3-5k | 8k |
| CONCERNS.md | 2-4k | 6k |
| STATE.md | <7k (verde) | 10k (vermelho - cleanup) |

## Adaptacoes Hapvida

- ADRs corporativas da Wiki Arquitetura-Referencia: **citadas** (`[REF: ADR-XX]`), nao
  carregadas por valor. So carregar conteudo da ADR especifica quando essencial para a decisao
  atual.
- Para refatoracao PL/SQL: o codigo do baseline carregado por demanda, nao integralmente. Use
  skills SIGO para extracao seletiva.
