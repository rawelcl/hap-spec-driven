# Discuss - Capturar Gray Areas

**Goal:** Capturar COMO o usuario imagina a feature quando a spec tem areas ambiguas. Esta NAO e
uma fase separada - e disparada dentro de Specify quando o agente detecta gray areas que precisam
input do usuario.

**Trigger:** Automaticamente quando gray areas sao detectadas durante criacao da spec, ou
explicitamente via "discuss feature", "how should this work?", "capture context"

**Quando disparar (auto-detect):** A spec tem comportamento user-facing que pode ir de varias
formas E o usuario nao expressou preferencia. Se a spec esta clara e nao-ambigua, pule.

**Quando NAO disparar:** Trabalho de infraestrutura, operacoes CRUD, contratos de API bem-definidos,
qualquer coisa onde o "como" e obvio do "o que".

## Adaptacoes Hapvida em relacao ao TLC

| Item | TLC | Hapvida |
|---|---|---|
| Disparo | Auto durante Specify | Idem |
| Output | `.specs/[feature]/context.md` | Idem |
| Aplicabilidade | Generico | `[ADAPTACAO]` Para refatoracao PL/SQL pura geralmente nao se aplica; para mudancas regulatorias estritas tambem nao |

## Por que esta fase existe

Specs capturam O QUE construir. Design captura arquitetura. Mas nenhum captura a visao do usuario
para areas ambiguas - preferencias de layout, padroes de interacao, tom de erro, conteudo. Sem isso,
o agente adivinha. Com isso, o agente constroi o que o usuario realmente imaginou.

O output - `context.md` - alimenta diretamente Design e Tasks:

- **Design le** para saber que decisoes estao locked vs flexiveis
- **Tasks le** para incluir comportamentos especificos nas definicoes de tasks

## Process

### 1. Analisar a Feature

Leia `.specs/features/[feature]/spec.md` e identifique o dominio:

| Dominio | Gray areas a explorar |
|---|---|
| Algo que usuarios **VEEM** | Layout, densidade, interacoes, estados vazios, hierarquia visual |
| Algo que usuarios **CHAMAM** (API) | Formato de resposta, erros, auth, versionamento, rate limiting |
| Algo que usuarios **RODAM** (CLI) | Formato de output, flags, modos, error handling, verbosidade |
| Algo que usuarios **LEEM** | Estrutura, tom, profundidade, fluxo, navegacao |
| Algo sendo **ORGANIZADO** | Criterios de agrupamento, naming, duplicates, excecoes |

Gere 3-4 gray areas **especificas a feature**. Nao categorias genericas, mas decisoes concretas
para ESTA feature.

### 2. Apresentar Gray Areas

Apresente o boundary da feature (do spec.md) e as gray areas ao usuario. Deixe escolher quais
discutir. NAO inclua opcao "skip all" - usuario invocou esta fase para discutir.

### 3. Deep-Dive Em Cada Area

Para cada area selecionada:

1. Faca 3-4 perguntas concretas com opcoes especificas (nao categorias vagas)
2. Apos as perguntas, cheque: "Mais sobre [area], ou seguir?"
3. Se mais -> faca mais 3-4
4. Apos todas as areas -> "Pronto para criar context?"

**Design das perguntas:**

- Opcoes devem ser concretas ("Layout em cards" nao "Opcao A")
- Cada resposta deve informar a proxima
- Inclua "Voce decide" como opcao quando razoavel - captura discricao do agente

### 4. Scope Guardrail (CRITICO)

O boundary da feature do spec.md e **fixo**. Discussao clarifica COMO implementar, nunca SE
adicionar novas capacidades.

**Permitido:** "Como posts deveriam ser exibidos?" (clarifica ambiguidade)
**Nao permitido:** "Devemos adicionar tambem comments?" (nova capacidade)

Quando usuario sugere scope creep: "Isso parece feature separada. Vou anotar em Deferred Ideas.
Volta para [area atual]."

### 5. Escrever context.md

---

## Template: `.specs/features/[feature]/context.md`

```markdown
# [Feature] Context

**Gathered:** [data]
**Spec:** `.specs/features/[feature]/spec.md`
**Status:** Ready for design

---

## Feature Boundary

[Statement claro do que esta feature entrega - o anchor de escopo do spec.md]

---

## Implementation Decisions

### [Area 1 que foi discutida]

- [Decisao especifica feita]
- [Outra decisao se aplicavel]

### [Area 2 que foi discutida]

- [Decisao especifica feita]

### [Area 3 que foi discutida]

- [Decisao especifica feita]

### Agent's Discretion

[Areas onde o usuario explicitamente disse "voce decide" - agente tem flexibilidade aqui durante
design/implementacao]

---

## Specific References

[Quaisquer momentos "Quero como X", referencias de produto, comportamentos especificos, padroes
de interacao mencionados durante discussao]

[Se nenhum: "Sem requisitos especificos - aberto a abordagens padrao"]

---

## Deferred Ideas

[Ideias que surgiram durante discussao mas pertencem a outras features/fases. Capturadas aqui
para nao serem perdidas, mas explicitamente fora de escopo]

[Se nenhum: "Nenhum - discussao ficou dentro do escopo da feature"]
```

---

## Adaptacoes especificas Hapvida

- Para features Comerciais com decisoes de UX (formularios de cotacao, fluxos de venda),
  Discuss e tipicamente disparado
- Para refatoracao PL/SQL pura (Improvement+Tunning), Discuss raramente se aplica - regras vem do
  baseline
- Para mudancas regulatorias estritamente especificadas em RN ANS, Discuss raramente se aplica -
  comportamento e ditado pela norma
- Demand Type ajuda a inferir quando Discuss e relevante:
  - Project + Business + ambiguidade UX -> tipicamente Discuss
  - Improvement + Tunning -> raramente
  - Maintenance -> raramente
