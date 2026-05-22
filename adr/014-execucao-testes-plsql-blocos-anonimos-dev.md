# ADR 014: Execucao de testes PL/SQL em DEV via blocos anonimos com rollback obrigatorio

**Status:** Accepted
**Data:** 2026-05-22
**Tipo:** framework
**Relaciona-se com:** [ADR 007](007-guardrail-acesso-producao.md) (Guardrail acesso a producao — emenda Excecao 3),
[ADR 013](013-modelo-testes-co-localizado-por-task.md) (Modelo de testes co-localizado),
[ADR 011](011-engenharia-reversa-como-baseline.md) (Engenharia reversa como baseline)

## Contexto

O ADR-013 estabeleceu que tasks de codigo declaram `Tests Approach: automated | manual | hybrid | none`
e que o artifact vive em `.specs/features/[feature]/tests/`. Para a stack PL/SQL — predominante no
piloto (squads Comercial + Cadastro) — `references/brownfield-mapping.md:52` ja indica como
default `Scripts .sql executaveis via MCP Oracle (DEV)`.

Faltam duas decisoes para tornar esse caminho realmente executavel:

1. **Formato concreto do `.sql` de teste.** Sem utPLSQL adotado em produto, qual estrutura o dev
   escreve? Pacote criado no schema? Script com `EXECUTE IMMEDIATE`? Bloco anonimo? Cada squad
   decidiria diferente, e o gate "Test Co-location Validation" do `hap-sd-tasks` voltaria a virar
   teatro por inconsistencia.

2. **Autorizacao para executar.** O ADR-007 Excecao 1 cobre apenas leitura read-only do dicionario
   Oracle em producao (`dba_objects`, `dba_dependencies`, etc.). A Excecao 2 cobre `SELECT` em
   dados de negocio de producao com anonimizacao. **Nenhuma das duas autoriza execucao de bloco
   PL/SQL em qualquer ambiente** — nem mesmo DEV. Sem decisao explicita, qualquer execucao via MCP
   Oracle DEV fica em zona cinzenta: tecnicamente possivel, formalmente nao autorizada.

Sem ADR explicita, o dev:

- Inventa o formato do teste (perde stack-agnosticidade do ADR-013).
- Executa em DEV "porque DEV nao e producao" — abre brecha implicita no guardrail.
- Pula o teste e marca `Tests Approach: manual` por default (defeats the purpose do ADR-013).

## Decisao

1. **Formato canonico:** todo `Tests Artifact` PL/SQL com `Approach: automated` ou `hybrid` e um
   **bloco anonimo PL/SQL** (`DECLARE ... BEGIN ... END;`) gravado em
   `.specs/features/[feature]/tests/verifica_<rotina>.sql`. Pacote standalone ou objeto criado
   no schema DEV nao e aceito como test artifact (poluiria o schema entre execucoes e exigiria
   limpeza explicita).

2. **Estrutura obrigatoria do bloco anonimo:**

   - `DECLARE` declara variaveis de entrada (parametros da rotina sob teste) e variaveis de
     saida esperadas.
   - `BEGIN` abre com `SAVEPOINT sp_test_start` para garantir rollback total.
   - Cada criterio de aceite (AC-NN da spec §9) vira **um sub-bloco nomeado** com:
     - comentario `-- AC-NN: <descricao curta>`
     - chamada da rotina sob teste com as entradas do AC
     - `IF condicao_esperada THEN dbms_output.put_line('PASS AC-NN'); ELSE raise_application_error(-20001, 'FAIL AC-NN: <motivo>'); END IF;`
   - `END` fecha com `ROLLBACK TO sp_test_start;` para garantir que nenhuma mudanca persista.
   - **Mapeamento 1:1 obrigatorio** entre AC-NN da spec e sub-bloco do `.sql`. AC sem sub-bloco
     ou sub-bloco sem AC = violacao do gate `AC Coverage Check` do `hap-sd-tasks`.

3. **Emenda ao ADR-007 — Excecao 3:** execucao de **bloco anonimo PL/SQL** em schemas DEV via
   MCP Oracle e autorizada **exclusivamente** para fins de teste de task, sob estas condicoes:

   - Bloco anonimo apenas — proibido criar/alterar objetos no schema DEV via MCP (`CREATE`,
     `ALTER`, `DROP` em qualquer objeto fora do escopo do bloco).
   - `SAVEPOINT` no inicio e `ROLLBACK` no fim sao **obrigatorios** — bloco que nao faz
     rollback total e violacao.
   - Apenas ambientes DEV — proibido execucao em HML/UAT/PRD via MCP Oracle.
   - Massa de teste anonimizada — proibido bloco anonimo manipular PII real (mesmo em DEV).
   - Resultado da execucao (output do `DBMS_OUTPUT` + exit status) e registrado como `Evidence`
     na task em `tasks.md`.

4. **Schema DEV declarado por squad:** cada squad declara em `TESTING.md` o schema/usuario DEV
   autorizado para execucao de blocos anonimos via MCP Oracle (`HUMASTER_DEV`, `CAD_DEV`, etc.).
   Skill `hap-sd-implement` valida que o MCP Oracle aponta para o schema declarado antes de
   executar — bloqueio hard se MCP estiver apontando para producao.

5. **Cobertura quando rotina nao existe ainda (TDD-like):** task que **cria** rotina nova
   pode declarar bloco anonimo que falha intencionalmente na primeira execucao (`ORA-04068:
   identifier ... must be declared`). `Evidence` registra a falha esperada e a transicao para
   PASS apos a rotina ser deployada em DEV no mesmo ciclo da task.

## Justificativa

- **Bloco anonimo elimina poluicao de schema:** nenhum objeto persiste entre execucoes; teste
  idempotente sem precisar de tear-down manual.
- **SAVEPOINT/ROLLBACK e barato e robusto:** mesmo se o `END` for atingido por exit anormal,
  Oracle reverte automaticamente a transacao da sessao. Custom de implementacao zero.
- **Mapeamento 1:1 AC<->sub-bloco fecha rastreabilidade ponta a ponta** que o ADR-013
  prometeu mas deixou para o stack do squad: agora `FEAT-NN` -> task -> `verifica_X.sql` ->
  sub-bloco AC-NN -> `Evidence` com `PASS/FAIL` por AC. Auditor (ANS) ve diretamente qual
  AC foi verificado.
- **Excecao 3 e cirurgica:** so autoriza o que o teste precisa (bloco anonimo em DEV),
  preserva todos os guardrails de PII, producao e DML/DDL fora do bloco.
- **Sem utPLSQL e estrategico, nao incidental:** ADR-013 ja registrou que adocao de utPLSQL
  esta fora de escopo. Este ADR concretiza o caminho alternativo sem reabrir essa decisao.

## Alternativas consideradas

- **Adotar utPLSQL:** descartado pelo ADR-013 (overhead de adocao em legado PL/SQL grande).
- **Criar pacote de testes standalone (`PK_TESTES_<FEATURE>`) no schema DEV:** descartado.
  Polui o schema entre execucoes, exige grants de criacao para o usuario MCP, e a limpeza
  fica como divida tecnica perene.
- **Executar testes apenas localmente via SQL*Plus/SQLcl:** descartado. Quebra a rastreabilidade
  do `Evidence` em `tasks.md` (saida fica na maquina do dev) e exclui o MCP do fluxo,
  retirando o gate executavel que o ADR-013 quer manter.
- **Manter zona cinzenta no ADR-007:** descartado. Auditoria ANS exigiria justificar
  posteriormente cada execucao MCP em DEV — mais barato declarar a excecao agora.

## Consequencias

**Positivas:**

- Definition of Done por task PL/SQL fica objetiva: bloco anonimo executou, `DBMS_OUTPUT`
  retornou `PASS AC-NN` para cada AC, `Evidence` registrada.
- Rastreabilidade `FEAT-NN -> task -> sub-bloco AC-NN -> PASS/FAIL` audita-vel.
- ADR-007 ganha posicao explicita sobre execucao em DEV; nada mais fica em zona cinzenta.
- QA herda os sub-blocos AC-NN como roteiro literal de homologacao.

**Negativas / Riscos:**

- **Overhead em tasks de 1 linha PL/SQL:** mesmo um `ALTER TABLE` para adicionar coluna
  exige bloco anonimo. Mitigado pelo `Approach: none` com justificativa quando AC nao
  envolve comportamento (refactor / DDL pura).
- **Schema DEV deve estar saudavel e atualizado:** se DEV esta desfasado de PRD, o bloco
  testa contra estado incorreto. Mitigado por `Evidence` exigir nota se DEV foi atualizado
  antes do teste.
- **`raise_application_error` aborta o bloco no primeiro FAIL:** outros ACs nao sao
  testados na mesma execucao. Mitigacao: usar pattern `DBMS_OUTPUT.PUT_LINE('FAIL AC-NN')`
  + contador, fazer `raise_application_error` final apos rodar todos os ACs, OR aceitar que
  primeiro FAIL para a execucao (mais simples). Padrao escolhido: **aborta no primeiro FAIL**
  para forcar fix incremental.
- **Drift entre DEV e PRD pode mascarar bugs:** teste passa em DEV, deploy quebra em PRD.
  Mitigacao fora do escopo desta ADR — pertence ao processo GMUD.

## Escopo

Esta ADR **se aplica a:**

- Toda task em `tasks.md` com `Tests Approach: automated` ou `hybrid` cujo `Tests Artifact`
  toca objeto PL/SQL.
- Execucao via MCP Oracle apontando para schema DEV declarado em `TESTING.md`.

Esta ADR **NAO se aplica a:**

- Testes manuais (`Approach: manual`) — seguem procedimento `.md` numerado, sem MCP Oracle.
- Tasks `Approach: none` — sem artifact PL/SQL.
- Execucao em HML/UAT/PRD — proibida via MCP Oracle, segue processo GMUD/sustentacao.
- Stacks Java/.NET/Frontend — usam seus proprios frameworks de teste (JUnit, xUnit, Jest).

## Implementacao

Commits associados a esta ADR:

1. `feat(adr): ADR-014 execucao testes PL/SQL via blocos anonimos em DEV`
2. `feat(brownfield-mapping): template de bloco anonimo + SAVEPOINT/ROLLBACK + mapeamento 1:1 AC`
3. `feat(hap-sd-tasks): prescreve verifica_<rotina>.sql obrigatorio em tasks PL/SQL`
4. `feat(hap-sd-implement): passo de execucao MCP Oracle DEV com captura de Evidence`
5. `feat(adr-007): emenda Excecao 3 — execucao bloco anonimo em DEV`

Skills afetadas:

- `hap-sd-tasks`: passo 6 (defincao de `Tests Artifact`) ganha regra de mapeamento 1:1
  AC<->sub-bloco para PL/SQL; gate "AC Coverage Check" valida que cada AC tem sub-bloco
  correspondente quando `Approach != none`.
- `hap-sd-implement`: passo 4 (criar/atualizar Tests Artifact) e passo 5 (verificar)
  ganham fluxo PL/SQL explicito: gerar bloco anonimo com `SAVEPOINT/ROLLBACK`, executar
  via MCP Oracle DEV, capturar `DBMS_OUTPUT`, registrar em `Evidence`.

Referencias:

- Template canonico do bloco anonimo: `references/brownfield-mapping.md` secao
  "Bloco anonimo PL/SQL — template canonico".
- Schema DEV declarado por squad: campo novo em `TESTING.md` — `Schema DEV autorizado para
  bloco anonimo via MCP Oracle: <SCHEMA_DEV>`.
