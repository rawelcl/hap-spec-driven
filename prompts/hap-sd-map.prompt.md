---
mode: 'agent'
description: 'Mapear codebase existente em 7 documentos em .specs/codebase/ (brownfield mapping)'
---

> **[HAP-SDD]** Hapvida Desenvolvimento Spec-Driven · [`SKILL.md`](../SKILL.md)

# Tarefa

Executar o brownfield mapping do codebase atual, produzindo os 7 documentos canônicos em
`.specs/codebase/` para que o framework opere com contexto real do projeto.

# Input esperado (peca ao TL antes de analisar)

1. **Stack predominante** - PLSQL | Java | DotNet | Mista
2. **Raiz do codebase** - caminho ou repo a analisar (padrao: workspace atual)
3. **Para PL/SQL**: confirmar qual TAG DE PRODUCAO usar no WinCVS (`cvs log` ou explicita)
4. **Areas de foco** - modulos, packages ou servicos prioritarios (opcional)

# Passos

1. **Verificar pre-condicoes**
   - Estamos na raiz de um repositorio Git (ou workspace configurado)? Se nao, alerte.
   - `.specs/codebase/` ja existe com conteudo? Confirme com o TL antes de sobrescrever.

2. **Analisar o codebase** (graceful degradation: `ast-grep` > `ripgrep` > `grep`)
   - Identifique linguagens, frameworks, estrutura de diretorios, padroes de naming
   - Para PL/SQL: identifique packages, procedures, functions, triggers - **via WinCVS tag PRODUCAO**
   - Para Java/.NET: identifique modulos, servicos, dependencias do build tool

3. **Gerar os 7 documentos em `.specs/codebase/`**

   | # | Arquivo | Foco |
   |---|---|---|
   | 1 | `STACK.md` | Linguagens, frameworks, libraries, versoes |
   | 2 | `ARCHITECTURE.md` | Componentes principais, fluxo de dados, dependencias |
   | 3 | `STRUCTURE.md` | Layout de pastas, convencoes de naming |
   | 4 | `CONVENTIONS.md` | Padroes de codigo, estilo, comentarios, idiomas Hapvida |
   | 5 | `TESTING.md` | Frameworks de teste, Test Coverage Matrix, Gate Check Commands |
   | 6 | `INTEGRATIONS.md` | APIs externas, ServiceNow, Lecom, GMUD, SACTI |
   | 7 | `CONCERNS.md` | Tech debt, areas frageis, gaps, ADRs ausentes |

4. **Para projetos com legado PL/SQL**: criar tambem a knowledge base

   ```
   .specs/codebase/knowledge-base/
     indice.md
     catalogo-conceitos-negocio.md
     catalogo-objetos-plsql.md
     pendencias-abertas.md
     riscos-ans.md
   ```

   E criar o esqueleto de `.specs/reverse-engineering/README.md` com instrucao para
   executar [`/hap-sd-re-plsql`](hap-sd-re-plsql.prompt.md)
   antes de qualquer spec de refatoracao ([ADR-011](../adr/011-engenharia-reversa-como-baseline.md)).

5. **Marcar areas de incerteza** com `[REVISAO]` onde a analise automatica nao for conclusiva.
   Nao invente comportamentos - prefira `[REVISAO] confirmar com DBA/Arquiteto`.

6. **Resumo final ao TL**
   - Liste os 7 arquivos criados e tamanho estimado de cada
   - Destaque os `[CONCERNS]` mais criticos encontrados
   - Proximos passos: validar com Arquiteto, iniciar specs de feature, ou executar
     `/hap-sd-re-plsql` para rotinas PL/SQL prioritarias
   - Commit sugerido: `WI-XXXX: docs(codebase): brownfield mapping inicial`
