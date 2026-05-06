# Glossario do Framework Spec-Driven Hapvida

**Status:** Seed inicial - sera expandido durante o piloto e Onda 2.

## Estrutura

| Arquivo | Conteudo |
|---|---|
| [`dominio-comercial.md`](dominio-comercial.md) | Termos canonicos da area Comercial (venda de planos) |
| [`regulatorio-ans.md`](regulatorio-ans.md) | Conceitos e normas regulatorias ANS |
| [`legado-mapeamento.md`](legado-mapeamento.md) | Mapeamento de termos legados (PL/SQL) para canonicos |

## Como usar

- Specs referenciam termos do glossario na secao "Glossario aplicavel"
- Termos canonicos sao **sinonimo unico** - evitar variacoes em codigo novo
- Termos legados sao mapeados para canonicos no codigo de refatoracao PL/SQL
- ADR 21 da Wiki Arquitetura-Referencia rege a Linguagem Onipresente corporativa

## Governanca

- Adicoes durante o piloto vem de specs reais
- Onda 2: forum/guild de TLs cura adicoes
- Termos que merecem virar parte do glossario corporativo: propor para Wiki Arquitetura-Referencia
