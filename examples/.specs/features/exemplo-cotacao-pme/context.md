# Cotacao PME Context

**Gathered:** 2026-04-30
**Spec:** `.specs/features/exemplo-cotacao-pme/spec.md`
**Status:** Ready for design

---

## Feature Boundary

Plataforma online para corretores gerarem cotacoes de planos coletivos PME (1-99 vidas) em <10 minutos, com PDF para enviar ao prospect.

---

## Implementation Decisions

### Layout do formulario de beneficiarios

- Tabela inline editavel (corretor adiciona linhas)
- Validacao em tempo real por linha
- Botao de import de CSV para volumes maiores (10+)

### Comportamento de erros

- Erros de validacao inline (campo a campo)
- Erros sistemicos (calculo, PDF) em modal com opcao de retry

### Densidade visual

- Densa - corretores sao usuarios power, querem rapidez

### Breakdown de cotacao

- Exibido em tabela apos calculo
- Linha agrupada por faixa etaria (somatorio)
- Expansao para ver beneficiario individual

### Agent's Discretion

- Cores e tema visual (seguir design system corporativo)
- Animacoes (preferir minimalismo)

---

## Specific References

- Padrao similar a cotacao residencial em `comercial-residencial-ui` (mas adaptado para PME)
- Validacao de CEP: usar componente compartilhado `CepInput` ja existente

---

## Deferred Ideas

- Cotacao colaborativa (corretor + prospect simultaneos) - v2
- Comparador de planos lado-a-lado - v2
- Sugestao automatica de plano mais adequado - v3
