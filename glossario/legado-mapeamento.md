# Glossario - Mapeamento Legado PL/SQL

> **Status:** Seed - expandir conforme refatoracoes acumulam baseline.

Mapeia termos legados em codigo PL/SQL Hapvida para termos canonicos do glossario corporativo.

## Tabelas e schemas

| Legado | Canonico |
|---|---|
| `tb_beneficiario` (alias `BNF`) | Beneficiario |
| `tb_cliente` | Cliente |
| `tb_plano` | Plano |
| `tb_proposta` | Proposta |
| `tb_cotacao` | Cotacao |
| `tb_contrato` | Contrato |

## Colunas frequentes

| Legado | Canonico |
|---|---|
| `BNF` | Beneficiario (entidade) |
| `ID_BNF` | identificador de Beneficiario |
| `DT_VIG` / `DT_VIGENCIA` | data de Vigencia |
| `DT_VIG_INI` | inicio da Vigencia |
| `DT_VIG_FIM` | fim da Vigencia |
| `CD_PLANO` | codigo de Plano |
| `VL_MENSAL` | valor de Mensalidade |
| `QT_DEP` | quantidade de Dependentes |
| `FL_ATIVO` | flag de status Ativo |
| `DT_CADASTRO` | data de Cadastro |

## Sufixos e prefixos comuns

| Sufixo / Prefixo | Significado |
|---|---|
| `tb_` | tabela |
| `pkg_` | package |
| `proc_` | procedure |
| `fn_` | function |
| `trg_` | trigger |
| `seq_` | sequence |
| `vw_` | view |
| `mvw_` | materialized view |
| `ID_` | identificador / chave |
| `CD_` | codigo |
| `DT_` | data |
| `VL_` | valor (numerico monetario) |
| `QT_` | quantidade |
| `FL_` | flag (S/N ou 0/1) |
| `DS_` | descricao |
| `NM_` | nome |

## Como usar em refatoracao

Em codigo refatorado (Improvement+Tunning), preferir nomes canonicos. Em codigo legado mantido,
adicionar comentarios:

```sql
SELECT b.id_bnf,           -- canonico: id_beneficiario
       b.dt_vig,           -- canonico: dt_vigencia
       b.fl_ativo           -- canonico: ativo
  FROM tb_beneficiario b
 WHERE ...
```

## Mapeamentos a expandir

- [ ] Termos especificos de Autorizacao
- [ ] Termos especificos de Glosa
- [ ] Termos especificos de Mensalidade
- [ ] Termos especificos de Faturamento
