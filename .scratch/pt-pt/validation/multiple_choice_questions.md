# Escolha múltipla — execução funcional Linux

15 de outubro de 2026. GCompris 26.2, Linux 7.0.0-38-generic x86_64, Qt 6.10.2, locale `pt_PT`.
Hashes do executável, RCC/QML privados, catálogo, caso e capturas em
`../functional-sequences/multiple-choice-final/result.json`.

## Exercícios e modos executados

O caso `tests/functional_sequences/multiple_choice.qml` jogou os três níveis e
os cinco exercícios, usando os botões, modelos, Score e Bonus reais:

| Nível | Exercícios | Comportamento |
| --- | --- | --- |
| 1 | Número depois do 2; identificar uma cor | Uma resposta e painel de explicação. Ordem inicial das perguntas/algumas respostas baralhada pelo jogo. |
| 2 | Números menores do que 3; identificar animais | Várias respostas e painel de explicação. |
| 3 | Lados do triângulo | Uma resposta, sem painel explicativo: avanço após a animação de Score. |

Em cada exercício foi submetida uma resposta errada e depois a resposta certa.
Os valores esperados são independentes das marcações `isSolution_`: 3,
amarelo, 1 e 2, gato e cão, 3. O caso escolhe por esses valores conhecidos,
clicando nos delegados de resposta e no OK. A rejeição preservou pontuação e
subnível; o acerto aumentou a pontuação. Foram confirmados os textos e o estado
real de sucesso/erro do painel. A explicação correta não avançou enquanto não
foi fechada; sem explicação, o último nível avançou automaticamente.

No terceiro nível foram enviados eventos de teclado para selecionar e validar
a resposta errada (Seta para baixo, Espaço e Enter). A resposta certa foi depois
selecionada com o rato. Depois de cinco rejeições e cinco acertos, o Bonus de
cada nível avançou, e o terceiro regressou ao primeiro.

O reinício limpou seleção, pontuação e subnível. Os botões Anterior/Seguinte foram
clicados, incluindo a passagem circular entre níveis 1 e 3. Zero falhas QtTest e
zero erros QML. Nenhuma falha de mecânica foi encontrada neste conjunto.

## Evidência e limites

Os logs, resultado e capturas de cada pergunta com explicação certa/errada estão
em `../functional-sequences/multiple-choice-final/`. As capturas foram
inspecionadas; mostram perguntas e explicações em português. O nível sem painel
inclui uma captura com a pontuação incrementada antes da transição.

A execução usou perfil novo, recursos locais e Docker `--network none`, sem cache
anterior. O catálogo PT foi recompilado para o teste. Os comandos estão em
`tests/functional_sequences/README.md`.

Este resultado cobre os cinco exercícios distribuídos e os dois modos em Linux,
com som desligado. A atividade não pede digitação de palavras; o texto `cão` foi
selecionado e apresentado corretamente. Não foram testados conjuntos externos
fornecidos pelo professor, ajuda, configuração, áudio ou Windows 10/escola.
A revisão linguística/pedagógica continua pendente. A matriz global permanece
pendente dos restantes critérios aplicáveis.
