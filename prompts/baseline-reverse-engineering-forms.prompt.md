---
mode: 'agent'
description: 'Disparar engenharia reversa de modulo Oracle Forms (.fmb) e persistir em .specs/reverse-engineering/forms/ como baseline cacheado'
---

Voce e o assistente do Framework Spec-Driven Hapvida v0.4.

# Tarefa

Produzir o **artefato canonico de engenharia reversa** de um modulo Oracle Forms (`.fmb`),
persistido em `.specs/reverse-engineering/forms/<MODULO>/rev-NNN-<TAG>/` para servir de baseline
cacheado em futuras specs de modernizacao (ver
[ADR-011](../adr/011-engenharia-reversa-como-baseline.md)).

`NNN` e numero sequencial zero-padded (`001`, `002`, ...) - calcular listando revs existentes
no diretorio do modulo e incrementando 1.

# Quando usar

- Primeira analise de modulo Forms legado
- Refresh de RE existente marcada `[REVISAO]` (tag CVS divergente da PRODUCAO atual)
- Antes de Specify de modernizacao Forms -> ADF/APEX/web stack
- Analise de impacto antes de tocar trigger/PL/SQL embutido em modulo critico

# Input esperado

- Nome do modulo (ex.: `T229BCON`)
- Caminho do `.fmb` no checkout CVS tag PRODUCAO (ex.: `C:\CVS\web_10g\fmb\pln\T229BCON.fmb`)
- (Opcional) ID do work item ADO destino - se ja houver demanda associada

# Pre-requisitos verificaveis

- [ ] `.fmb` existe no checkout CVS tag PRODUCAO
- [ ] Oracle Forms Developer 10g+ instalado **OU** JARs do Forms2XML acessiveis via
      `ORACLE_HOME` (`frmxmltools.jar`, `frmjdapi.jar`, `xmlparserv2.jar`)
- [ ] Tool [`tools/forms-extractor/`](../tools/forms-extractor/) presente no submodule do
      framework (`.specs/framework/tools/forms-extractor/`)

Se algum pre-requisito falhar -> ABORTAR e indicar ao TL o que falta.

# Passos

1. **Verificar guardrails**:
   - `[GUARDRAIL]` `.fmb` lido do checkout CVS tag PRODUCAO - nunca de copia local nao versionada
   - `[GUARDRAIL]` Pipeline `tools/forms-extractor/` exige Oracle Forms Developer instalado;
     se ausente, bloquear e instruir o TL
   - `[GUARDRAIL]` Anonimizar PII de beneficiario pessoa fisica (CPF, nome, matricula, dados de saude) em hard-coded values, comentarios, exemplos de massa

2. **Resolver tag CVS PRODUCAO** do `.fmb` e gravar no frontmatter do artefato

3. **Calcular NNN** - sequencial zero-padded da revisao (listar `rev-*` em
   `.specs/reverse-engineering/forms/<MODULO>/`, incrementar 1; primeira analise = `001`)

4. **Criar estrutura de diretorios**:
   ```
   .specs/reverse-engineering/forms/<MODULO>/
     README-modulo.md                    (criar/atualizar)
     rev-NNN-<TAG>/
       raw/                              (Etapa 1 do tool)
       parsed/                           (Etapa 2 do tool)
   ```

5. **Etapa 1 - Conversao binario para XML** (tool `tools/forms-extractor/`):
   ```powershell
   .specs/framework/tools/forms-extractor/Convert-FmbToXml.ps1 `
     -FmbPath <path-cvs-PRODUCAO>/<MODULO>.fmb `
     -OutputDir .specs/reverse-engineering/forms/<MODULO>/rev-NNN-<TAG>/raw/
   ```
   Saida esperada: `<MODULO>.xml` em `raw/`. Se falhar, abortar e reportar STDERR ao TL.

6. **Etapa 2 - Extracao estruturada** (tool `tools/forms-extractor/`):
   ```powershell
   .specs/framework/tools/forms-extractor/Extract-FormsMetadata.ps1 `
     -XmlPath .specs/reverse-engineering/forms/<MODULO>/rev-NNN-<TAG>/raw/<MODULO>.xml `
     -OutputDir .specs/reverse-engineering/forms/<MODULO>/rev-NNN-<TAG>/parsed/ `
     -Format md
   ```
   Saida esperada: 12 relatorios (`<MODULO>_RESUMO.txt`, `_WINDOWS.txt`, `_CANVAS.txt`,
   `_BLOCKS.txt`, `_TRIGGERS.txt`, `_PROGRAM_UNITS.txt`, `_LOVS.txt`, `_ALERTS.txt`,
   `_PARAMETERS.txt`, `_RELATIONS.txt`, `_VISUAL_ATTRS.txt`, `_RECORD_GROUPS.txt`).
   Validar que `_RESUMO.txt` foi gerado sem erros.

7. **Materializar pre-requisitos** se ausentes em `.specs/codebase/knowledge-base/`:
   `indice.md`, `catalogo-conceitos-negocio.md`, `catalogo-objetos-plsql.md`
   (Forms costuma chamar packages do banco), `pendencias-abertas.md`, `riscos-ans.md`

8. **Invocar a skill** [`engenharia-reversa-forms`](../skills/engenharia-reversa-forms/SKILL.md)
   seguindo seu protocolo de execucao **Passos 2 a 6** (o Passo 1 - pipeline - ja foi
   executado nos passos 5-6 acima):
   - Passo 2: Inventario de UI (RESUMO, WINDOWS, CANVAS, BLOCKS)
   - Passo 3: Analise de triggers (TRIGGERS, PROGRAM_UNITS) - classificar por proposito
   - Passo 4: Mapeamento de dependencias (cruzar PL/SQL com `catalogo-objetos-plsql.md`)
   - Passo 5: Smells e riscos (hard-coded values, logica em UI, validacoes duplicadas, [ANS])
   - Passo 6: Painel de Decisao

9. **Gerar artefato** seguindo `templates/reverse-engineering-forms-template.md` (a criar
   na primeira execucao - estrutura espelha
   [`templates/reverse-engineering-template.md`](../templates/reverse-engineering-template.md))
   em `.specs/reverse-engineering/forms/<MODULO>/rev-NNN-<TAG>/reversa-<MODULO>.md`

10. **Atualizar indice** `.specs/reverse-engineering/forms/<MODULO>/README-modulo.md`
    listando todas as revisoes existentes com data + tag

11. **Atualizar catalogos** em `.specs/codebase/knowledge-base/`:
    - `catalogo-objetos-plsql.md` - registrar packages chamados pelo Forms
    - `pendencias-abertas.md` - itens `[ATENCAO]` / `[BLOQUEADO]`
    - `riscos-ans.md` - itens `[ANS]` identificados

12. **Apresentar para aprovacao** o Painel de Decisao (secao final do artefato) com:
    - Sinopse funcional do modulo
    - Regras de negocio extraidas (prioridade alta/media/baixa)
    - Lista de `[ATENCAO]` / `[BLOQUEADO]` / `[ANS]` / `[REVISAO]`
    - Recomendacao: modernizacao / manutencao / deprecate

# Guardrails

- `[GUARDRAIL]` `.fmb` deve vir do **CVS tag PRODUCAO** - nunca copia local nao versionada
- `[GUARDRAIL]` LLM **nao** le XML bruto - sempre via os 12 relatorios da Etapa 2
- `[GUARDRAIL]` PL/SQL embutido em triggers segue regras de `engenharia-reversa-sigo`
  (tabelas de negocio proibidas; somente dba_* autorizados via MCP - dba_source proibido como fonte de codigo)
- `[GUARDRAIL]` Anonimizar PII de beneficiario pessoa fisica (CPF, nome, matricula, dados de saude) em comentarios, hard-coded values, exemplos de massa
- `[GUARDRAIL]` Toda regra que tocar area regulada (ANS, LGPD) exige `[ANS]` + citacao da norma
- `[GUARDRAIL]` Cada revisao e **imutavel** - nunca editar `rev-NNN-<TAG>` existente; sempre
  criar nova rev quando a tag CVS divergir

# Output

- Artefato canonico `reversa-<MODULO>.md`
- 12 relatorios estruturados em `parsed/` (rastreio fechado, auditavel - nao apagar)
- XML bruto em `raw/<MODULO>.xml`
- Atualizacoes no `README-modulo.md` e nos catalogos do projeto
- Lista de `[ATENCAO]` / `[BLOQUEADO]` / `[ANS]` para validacao com PO/DBA
- Confirmacao final com caminhos dos arquivos criados/atualizados

# Handoff

Apos aprovacao no Painel de Decisao, a RE pode ser referenciada por specs de modernizacao
via `[REF: .specs/reverse-engineering/forms/<MODULO>/rev-NNN-<TAG>/]` - elimina necessidade
de releitura do `.fmb` ou do XML bruto na fase Specify.

# Tratamento de erros

- **Oracle Forms Developer ausente** -> bloquear, instruir TL a instalar (10g+) ou apontar
  `ORACLE_HOME` para os JARs
- **Falha na conversao `.fmb` -> `.xml`** (Etapa 1) -> capturar STDERR do tool, reportar ao TL
- **Falha na extracao XML -> relatorios** (Etapa 2) -> idem
- **`.fmb` corrompido** -> abortar com `[BLOQUEADO]`, instruir TL a re-checkout do CVS
- **Tamanho do XML excessivo** (modulos com >50k linhas de PL/SQL embutido) -> processar em
  chunks por bloco; marcar `[ATENCAO]` se contexto saturar
