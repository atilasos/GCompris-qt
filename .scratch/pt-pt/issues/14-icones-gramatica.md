# Retirar texto estrangeiro desenhado dos ícones

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 03

## Problema

A ajuda PT-PT mostra `WORD` no ícone de classes de palavras. A inspeção dos 203
ícones encontrou também inglês na análise gramatical, forca, imagens/palavras,
letra na palavra, memória numeral/nome e ordenação de frases, além de francês
no ícone de língua. As letras eram contornos SVG fora do catálogo de traduções.

## Aceitação

- Substituir palavras por grupos de letras educativos sem vocabulário de uma
  língua, conservando a composição, cores, símbolos e licença dos desenhos.
- Manter a correspondência numeral/nome no ícone de memória com um recurso
  português, sem substituir por `ABC` o nome de um número específico.
- Inspecionar renderizações Qt antes/depois e a seleção do recurso por locale.
- Não usar esta correção como aprovação de todos os recursos ou dos jogos.

## Answer

Os oito ícones foram corrigidos. As sequências neutras representam grupos de
letras; o ícone de letra na palavra conserva uma letra em falta coerente.
O recurso PT de memória apresenta `2 dois`, selecionado pelo normalizador
existente de locale. A execução do motor QML real comprovou a seleção em PT-PT
e a conservação do recurso original em pt_BR/en_US. Ambos os recursos existem
no RCC compilado. Foram inspecionadas as renderizações Qt dos próprios SVG.

Evidência visual, proveniência e procedimento em `../icons/review.md`.
A revisão pedagógica, os restantes recursos e Windows têm validação própria.
