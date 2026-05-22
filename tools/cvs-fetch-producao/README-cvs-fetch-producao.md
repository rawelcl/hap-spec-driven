# Tool: cvs-fetch-producao

Busca um modulo PL/SQL do WinCVS usando a tag `PRODUCAO_*` mais recente.
Etapa obrigatoria do fluxo de engenharia reversa PL/SQL ([ADR-007](../../adr/007-guardrail-acesso-producao.md) emendada).

Consumido pela skill [`engenharia-reversa-sigo`](../../skills/engenharia-reversa-sigo/SKILL.md)
e pelo prompt [`hap-sd-re-plsql`](../../prompts/hap-sd-re-plsql.prompt.md).

---

## Pre-requisitos

| Pre-requisito | Como verificar |
|---|---|
| `cvs.exe` no PATH | `cvs --version` |
| Conectividade TCP com servidor CVS (porta 2401) | `Test-NetConnection 10.1.17.26 -Port 2401` |
| Autenticacao CVS feita (`~/.cvspass` existe) | `Test-Path ~\.cvspass` |
| Opcional: `.cvs-env.ps1` com host/usuario | gerado pelo setup interativo |

O tool realiza o setup interativo automaticamente na primeira execucao se as
credenciais estiverem ausentes.

---

## Parametros

| Parametro | Obrigatorio | Default | Descricao |
|---|---|---|---|
| `-Module` | Sim | — | Caminho do modulo no CVS relativo ao CVSROOT. Ex: `HUMASTER/PK_VENDA_JSON.pkb` |
| `-Tag` | Nao | (automatico) | Tag especifica. Se omitido, resolve a `PRODUCAO_YYYYMMDD` mais recente |
| `-OutputDir` | Nao | `.cvs-checkout/<OBJETO>/<TAG>/` | Diretorio local de saida |
| `-CvsHost` | Nao | `$env:HAPVIDA_CVS_HOST` | Hostname/IP do servidor CVS |
| `-CvsRepo` | Nao | `/cvs/hapvida` | Caminho do repositorio no servidor |
| `-CvsUser` | Nao | `$env:HAPVIDA_CVS_USER` | Usuario CVS |

---

## Saida

```
.cvs-checkout/
  <NOME_OBJETO>/
    <TAG>/
      HUMASTER/
        PK_VENDA_JSON.pkb      <- arquivo fonte obtido do CVS
      cvs-fetch-evidence.json  <- rastreabilidade: host, tag, SHA-256
```

`cvs-fetch-evidence.json` — estrutura:

```json
{
  "fetched_at": "2026-05-22T14:30:00",
  "cvsroot_host": "10.1.17.26",
  "cvs_repo": "/cvs/hapvida",
  "module": "HUMASTER/PK_VENDA_JSON.pkb",
  "tag": "PRODUCAO_20260430",
  "output_dir": "C:\\...\\.cvs-checkout\\PK_VENDA_JSON\\PRODUCAO_20260430",
  "files": [
    {
      "path": "C:\\...\\PK_VENDA_JSON.pkb",
      "sha256": "A3F2..."
    }
  ]
}
```

---

## Seguranca de credenciais

- Senha **nunca** em parametro, arquivo ou variavel de ambiente — capturada via
  `Read-Host -AsSecureString` e usada apenas no processo `cvs login`.
- `~/.cvspass` e gerado pelo proprio cliente CVS com senha ofuscada (formato pserver).
- `.cvs-env.ps1` (opcional) contem apenas host e usuario, **sem senha**.
  Adicionar ao `.gitignore` do projeto — o tool faz isso automaticamente.

---

## Exemplos de uso

### Uso tipico (primeiro uso — setup interativo automatico)

```powershell
cd C:\Repos\squad-comercial
.\.specs\framework\tools\cvs-fetch-producao\cvs-fetch-producao.ps1 `
  -Module "HUMASTER/PK_VENDA_JSON.pkb"
```

O tool detecta que `~/.cvspass` nao existe, solicita host/usuario/senha
iterativamente, executa `cvs login` e prossegue com o checkout.

### Usos subsequentes (credenciais ja configuradas)

```powershell
# Com .cvs-env.ps1 gerado pelo setup:
. .\.cvs-env.ps1
.\.specs\framework\tools\cvs-fetch-producao\cvs-fetch-producao.ps1 `
  -Module "HUMASTER/PK_VENDA_JSON.pkb"

# Ou com env vars ja definidas na sessao:
.\.specs\framework\tools\cvs-fetch-producao\cvs-fetch-producao.ps1 `
  -Module "HUMASTER/PR_CADASTRAMENTO_EMPRESA_PROV.prc"

# Com tag especifica:
.\.specs\framework\tools\cvs-fetch-producao\cvs-fetch-producao.ps1 `
  -Module "HUMASTER/PK_VENDA_JSON.pkb" `
  -Tag "PRODUCAO_20260430"
```

---

## Como a skill invoca este tool

No prompt [`hap-sd-re-plsql`](../../prompts/hap-sd-re-plsql.prompt.md) e na skill
[`engenharia-reversa-sigo`](../../skills/engenharia-reversa-sigo/SKILL.md), o agente executa
via terminal (Passo 0 do protocolo de execucao):

```powershell
# O agente substitui <RAIZ_PROJETO> e <MODULO> pelos valores do contexto
cd <RAIZ_PROJETO>
.\.specs\framework\tools\cvs-fetch-producao\cvs-fetch-producao.ps1 `
  -Module "<ESQUEMA>/<NOME_OBJETO>.<EXT>"
```

Se o tool retornar `[BLOQUEADO]` (exit 1), o agente para imediatamente e
notifica o TL — sem fallback para `dba_source` ou outra fonte.

---

## Codigos de saida

| Exit code | Significado |
|---|---|
| `0` | Sucesso — arquivo obtido, evidence.json gravado |
| `1` | `[BLOQUEADO]` — falha de autenticacao, modulo nao encontrado, cvs.exe ausente ou tag nao encontrada |
