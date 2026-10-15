# Ordenação cronológica — execução funcional Linux

15 de outubro de 2026. GCompris 26.2, Linux 7.0.0-38-generic x86_64, Qt 6.10.2, locale `pt_PT`.
A cópia do executável, o RCC privado, o catálogo e o caso têm hashes em
`../functional-sequences/chronology-final/result.json`.

## Exercícios executados

O caso `tests/functional_sequences/chronology.qml` jogou os três níveis com
imagens do ciclo da flor, viagem à Lua e o Tux a apanhar uma maçã. Enviou eventos
reais de arrastar e largar em QML, sem substituir `dropElement` ou `checkOrder`.

Em cada nível:

- Arrastou os quatro elementos para a ordem 2, 1, 3, 4 e submeteu com o botão OK.
- Verificou rejeição, bordas vermelhas nos dois primeiros elementos e verde no
  terceiro, mantendo o mesmo nível depois da animação de erro.
- Devolveu os quatro elementos à origem e confirmou o reinício das cores e a
  ocultação do OK enquanto a resposta estava incompleta.
- Construiu a ordem 1, 2, 3, 4 e submeteu, verificando as quatro imagens, bordas
  verdes, Bonus de sucesso e passagem automática ao nível seguinte.

O primeiro nível incluiu também arrastar entre posições da resposta para
verificar a reordenação. No total houve 37 arrastos, três respostas erradas e
três certas. A conclusão do terceiro nível regressou ao primeiro. O reinício
limpou a resposta; os botões Anterior/Seguinte foram clicados, incluindo a
passagem circular entre níveis 1 e 3. Zero falhas QtTest e zero erros QML.

O teste JS `functional_sequences_shuffle.test.mjs` usa os scripts reais de Core
e ordenação, com dois valores conhecidos do gerador aleatório. Confirma duas
permutações concretas, resposta certa/errada em todos os níveis, reordenação,
reposição das cores e preservação da solução original depois de reiniciar.
Apenas a fronteira ListModel é representada pelo modelo do teste; os eventos
reais de arrasto são cobertos pelo caso QML acima.

## Correção encontrada

A instrução dizia «Arrasta e larga as letras por ordem cronológica», apesar de
ser um jogo de imagens. O teste com QTranslator e catálogo realmente compilado
falhou antes da correção. A tradução passou a «Arrasta e larga as imagens por
ordem cronológica» e o teste passou. O caso QML final confirma `imagens` na
instrução visível. A captura anterior está em
`../functional-sequences/chronology-instruction-before.png`.

## Evidência e limites

Os logs, resultado e capturas de todos os níveis estão em
`../functional-sequences/chronology-final/`. As capturas foram inspecionadas.
A execução decorreu em perfil novo e Docker `--network none`, com os recursos
locais da compilação e sem cache anterior. Os comandos reproduzíveis estão em
`tests/functional_sequences/README.md`.

O resultado aprova estas interações dos três níveis em Linux. O som estava
desligado, a ajuda/configuração não foi percorrida e esta atividade não solicita
escrita de caracteres portugueses. A pronúncia, a revisão pedagógica e a
execução Windows 10/escola continuam pendentes. A linha da matriz global não
foi marcada como aprovada por este resultado parcial.
