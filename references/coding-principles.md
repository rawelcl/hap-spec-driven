# Coding Principles

**Bias comportamental, nao checklist. Leia antes de cada implementacao.**

## Adaptacoes Hapvida em relacao ao TLC original

- Mantemos integralmente os principios do TLC
- Adicionamos principios PL/SQL especificos
- Adicionamos guardrails Hapvida (LGPD, ANS, anonimizacao, sigilo medico)
- Adicionamos diretrizes de uso de skills SIGO

---

## Antes de codar

- **Declare premissas explicitamente.** Se incerto, pergunte.
- **Multiplas interpretacoes existem?** Apresente todas - nao escolha silenciosamente.
- **Abordagem mais simples existe?** Diga. Empurre de volta quando justificavel.
- **Algo nao claro?** Pare. Nomeie o que esta confuso. Pergunte.
- **A abordagem do usuario parece errada?** Discorde honestamente. Nao seja sycophant.
- **Cheque ADRs aplicaveis** - se decisao arquitetural sem ADR, marque `[ADR-AUSENTE]` antes de avancar.

---

## Durante implementacao

### Simplicidade

- Sem features alem do solicitado
- Sem abstracoes para codigo de uso unico
- Sem "flexibilidade" ou "configurabilidade" nao solicitada
- Sem tratamento de erro para cenarios impossiveis
- 200 linhas que poderiam ser 50? Reescreva.

### Mudancas cirurgicas

- Nao "melhore" codigo, comentarios ou formatacao adjacentes
- Nao refatore coisas que nao estao quebradas
- Bata com estilo existente, mesmo que voce faria diferente
- Codigo morto nao relacionado notado? Mencione - nao delete
- Remova APENAS imports/variaveis/funcoes que SUAS mudancas orfanaram
- Nao remova codigo morto pre-existente a menos que pedido

### Integridade de testes

- NUNCA enfraqueca uma assertion existente para passar
- NUNCA delete um teste para reduzir contagem de falhas
- NUNCA use o mecanismo skip/disable/pending do framework para contornar teste falhando
- NUNCA modifique tests escritos na fase RED durante a fase GREEN
- Se um teste esta genuinamente errado, PARE e confirme com usuario antes de mudar
- Tests sao a spec - implementacao se conforma aos tests, nao o contrario

### Goal-driven

- Transforme tasks vagas em goals verificaveis
- Trabalho multi-step? Declare plano breve com checkpoints de verificacao
- Cada linha alterada deve traçar diretamente ao request do usuario

---

## Apos cada mudanca

Pergunte: "Engenheiro senior chamaria isso de overcomplicado?"
Se sim -> simplifique antes de prosseguir.

---

## Principios PL/SQL (especifico Hapvida)

### Performance

- **Bulk operations sao default em manipulacao de massa.** `BULK COLLECT INTO` + `FORALL` em vez de
  cursor row-by-row. Mas marque `[MIGRACAO]` se for codigo a ser modernizado.
- **Bind variables sempre** - nunca concatene strings em SQL dinamico (vulnerabilidade SQL injection)
- **Indexes apropriados** - cheque plano de execucao para queries criticas
- **Hints com cuidado** - so quando otimizador realmente esta errado e voce pode provar

### Tratamento de erro

- **EXCEPTION blocks** explicitos por tipo de erro - nunca `WHEN OTHERS THEN NULL`
- **Logging via skill `plsql-oracle-expert`** quando disponivel
- **Rollback explicito** em handlers - nunca confiar em rollback implicito
- **`SQLCODE` e `SQLERRM`** sempre registrados no log de erro

### Transactions

- `COMMIT` apenas quando voce e o "owner" da transacao - bibliotecas/utility procedures NAO devem
  commitar
- `PRAGMA AUTONOMOUS_TRANSACTION` apenas para logging de auditoria - nunca para logica de negocio
- Marque `[MIGRACAO]` em pontos de COMMIT/ROLLBACK disperso pelo codigo legado

### Codigo legado a refatorar

- **Preserve contratos publicos** - assinaturas de procedures publicos so mudam com aprovacao formal
- **Engenharia reversa parte da tag PRODUCAO** no WinCVS - nunca direto do banco
- **Mapeie sinonimos** legados para termos canonicos do glossario (`BNF` -> Beneficiario, `DT_VIG` ->
  Vigencia)
- **Use skill `sigo-modernizacao-plsql`** quando disponivel para extracao de regras

---

## Principios Java / .NET (especifico Hapvida)

- Siga ADRs de linguagem aplicaveis: ADR 24 (Java homologadas), ADR 25 (Frameworks frontend)
- Padrao Repositorio per ADR 22
- APIs REST per ADR 14
- Mensageria per ADR 18
- Notificacoes per ADR 19
- Front-end config per ADR 37
- Code Review per ADR 38

Se conflito entre principio do framework e ADR Hapvida, **ADR prevalece**.

---

## Guardrails inegociaveis

### [GUARDRAIL] Acesso a producao

- **NUNCA** use MCP de banco produtivo para verificar codigo. Sempre WinCVS tag `PRODUCAO`.
- MCP do Azure DevOps esta autorizado para metadados (work items, attachments, repos) - nao para
  acesso a dados de beneficiario.

### [GUARDRAIL] Anonimizacao

- Dados de beneficiario **nunca** entram em prompt, dataset, eval, anexo de spec ou test fixture
- Anonimizacao e responsabilidade do autor da spec/codigo, nao da infraestrutura
- Mock data deve ser sintetico ou usar massa de teste oficial homologada

### [GUARDRAIL] LGPD e sigilo medico

- Dados sensiveis tratados conforme Lei 13.709/18 (LGPD) e regulacao setorial
- Sigilo medico inegociavel mesmo em ambientes de teste / homologacao
- PII nunca aparece em arquivo aberto no editor durante uso de prompt file que envie contexto
  ao Copilot

### [GUARDRAIL] Calculo financeiro regulado

- Calculos de mensalidade, coparticipacao, reajuste, glosa e CPT **nao sao decididos por LLM**
- LLM pode sugerir, explicar e revisar
- **Codigo deterministico decide valor**
- Toda saida que afirme valor regulado leva `[ANS]` e exige citacao de fonte

### [GUARDRAIL] ADR como guardrail forte

- Decisao arquitetural sem ADR aplicavel: bloquear com `[ADR-AUSENTE]` e propor criacao da ADR
  antes de avancar
- Aproveita cultura ja consolidada Hapvida ("ADRs precisam ser seguidas")

### [GUARDRAIL] Skill SIGO quando disponivel

- Para tarefas PL/SQL relevantes (engenharia reversa, refatoracao, code review, validacao contra
  baseline), **prefira skills SIGO** sobre solucoes ad-hoc:
  - `sigo-modernizacao-plsql` - engenharia reversa, extracao de regras
  - `sigo-refatoracao-workflow` - fluxo completo de refatoracao
  - `plsql-oracle-expert` - code review com regras ANS
- Skills SIGO ja respeitam guardrails Hapvida internamente

---

## Tokens textuais padronizados

Use estes em codigo, comentarios, specs, ADRs e documentacao - nunca emojis em artefatos formais.

| Token | Uso |
|---|---|
| `[ATENCAO]` | Alerta importante mas nao bloqueante |
| `[BLOQUEADO]` | Falta informacao critica; nao avanca |
| `[REVISAO]` | Revisao humana exigida |
| `[ANS]` | Touche regulatorio; exige citacao de norma |
| `[REF: <id>]` | Citacao a ADR, work item, regra, regulamento |
| `[ADR-AUSENTE]` | Decisao arquitetural sem ADR; bloqueia |
| `[MIGRACAO]` | Ponto que precisa atencao em modernizacao futura |
| `[GUARDRAIL]` | Regra inegociavel |
| `[OK]` | Item validado / decisao tomada |
| `[PREMISSA]` | Hipotese assumida sujeita a contestacao |
| `[ADAPTACAO]` | Diferenca explicita em relacao ao framework TLC original |
