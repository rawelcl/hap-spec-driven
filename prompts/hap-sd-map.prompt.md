---
mode: 'agent'
description: 'Mapear codebase existente em 7 documentos em .specs/codebase/ (brownfield mapping)'
---

> **[HAP-SDD]** Hapvida Desenvolvimento Spec-Driven · [`SKILL.md`](../SKILL.md)

# Tarefa

Executar o brownfield mapping do codebase atual, produzindo os 7 documentos canônicos em
`.specs/codebase/` para que o framework opere com contexto real do projeto.

# Input obrigatorio - se ausente, PARE e pergunte ao TL antes de qualquer analise

Antes de executar qualquer passo abaixo, confirme os itens 1-5 em **uma unica mensagem** ao TL e
aguarde resposta. **Nao prossiga com defaults silenciosos** - se o TL nao respondeu ou respondeu
parcialmente, repita a pergunta apenas para os campos faltantes.

| # | Campo | Obrigatorio? | Default permitido |
|---|---|---|---|
| 1 | **Stack predominante** (PLSQL \| Java \| DotNet \| Mista) | Sim | Nenhum - sempre perguntar |
| 2 | **Raiz do codebase** (caminho relativo) | Sim | `.` (workspace atual) - so usar se TL confirmar |
| 3 | **Paths a IGNORAR** alem do `.gitignore` | Sim | Nenhum - mas sugerir `.specs/`, `workspace/`, `examples/`, `templates/`, `prompts/`, `references/` quando o repo for o proprio framework |
| 4 | **Para PL/SQL**: TAG DE PRODUCAO no WinCVS (`cvs log` ou explicita) | Sim se stack=PLSQL/Mista | Nenhum |
| 5 | **Areas de foco** (modulos, packages, servicos prioritarios) | Nao | Vazio = varrer tudo dentro da raiz |

Formato sugerido de pergunta ao TL (envie em uma so mensagem):

> Para rodar o brownfield mapping, preciso confirmar:
> 1. Stack predominante? (PLSQL | Java | DotNet | Mista)
> 2. Raiz do codebase? (padrao `.` - confirma?)
> 3. Paths a ignorar alem do `.gitignore`? (ex: `examples/`, `workspace/`)
> 4. [se PL/SQL] Qual tag PRODUCAO do WinCVS usar como baseline?
> 5. Areas de foco prioritarias? (opcional)

# Passos

1. **Verificar pre-condicoes** (apos receber os inputs)
   - Estamos na raiz de um repositorio Git (ou workspace configurado)? Se nao, alerte.
   - `.specs/codebase/` ja existe com conteudo? Confirme com o TL antes de sobrescrever.
   - Os paths informados em "Raiz" e "Areas de foco" existem no disco? Se nao, alerte e pare.

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
