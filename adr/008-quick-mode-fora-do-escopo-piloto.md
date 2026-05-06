# ADR 008: Quick Mode fora do escopo do piloto v0.2

**Status:** Accepted (deferred to v0.3+)
**Data:** 2026-05-06

## Contexto

O framework TLC original tem um "Quick Mode" - atalho que permite tarefas pequenas (1-3 arquivos)
serem feitas sem cerimonia de spec/design/tasks, registradas em STATE.md como `Quick Tasks`.

## Decisao

**Quick Mode esta FORA do escopo do piloto v0.2.** Reavaliavel para v0.3 apos coleta de metricas.

Razoes:
- O piloto e prototipo experimental - todas as features piloto passam pelo fluxo completo para
  gerar dados sobre adesao ao framework integral
- Permitir Quick Mode no piloto pode levar TLs a usa-lo demais, comprometendo a coleta de feedback
  sobre o fluxo completo
- A tabela `Quick Tasks` em STATE.md existe para futuro uso e tasks de manutencao pequena que nao
  se encaixam em fluxo completo

## Reavaliacao

Para v0.3+, considerar Quick Mode se:
- Feedback do piloto indicar que features <X% sao bem servidas pelo fluxo completo (overhead)
- TLs reportarem fricao com features de manutencao pequenas
- Padronizar criterios objetivos para entrar em Quick Mode (ex: <3 arquivos, <1 dia de trabalho,
  sem mudanca regulatoria)

## Relacao com ADR 010

[ADR 010](010-tasks-obrigatorias-com-sync-ado.md) tornou `tasks.md` **sempre obrigatorio** com
sync 1:1 ao Azure DevOps. Isso reforca o veto a Quick Mode: nao ha mais como burlar a Task ADO
via atalho - toda mudanca, por menor que seja, exige Task no ADO. Eventual reintroducao de
Quick Mode em v0.4+ tera de respeitar essa obrigatoriedade.

## Consequencias

**Positivas no piloto:**
- Disciplina maxima
- Coleta de dados consistente
- Evita "pulo do gato" prematuro

**Negativas no piloto:**
- Overhead percebido em features pequenas
- Risco de TLs fazerem fora do framework "porque e simples demais"

Mitigacao: documentar claramente que features muito pequenas seguem o caminho default Hapvida
(sem framework) durante o piloto, e o framework entra apenas quando ha spec real.
