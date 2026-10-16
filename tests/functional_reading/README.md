# Leitura horizontal e vertical: testes funcionais

Executar a partir de um checkout com QtTest, Node.js, Docker e a imagem
`alpine:latest` já disponível:

```sh
python3 tests/functional_reading/run.py \
  --binary /caminho/build/pt-pt/bin/gcompris-qt \
  --output /caminho/novo/reading-results
```

O comando executa os dados JavaScript reais e quatro casos nativos: conclusão e
controlos em `readingh` e `readingv`. Compila RCC privados para a atividade e
para a lista partilhada de `wordsgame`; não altera a instalação usada como fonte.
Cada processo tem perfil novo e rede Docker desativada. Os fingerprints dos
dados/JavaScript ficam em `dependencies.json`, além dos fingerprints, logs e
capturas por caso fornecidos pelo launcher genérico.

Os três níveis portugueses têm 27, 39 e 81 entradas. O jogo pede dez respostas
certas por nível, não os 15 subníveis declarados no JSON de `wordsgame`: a leitura
limita a contagem a dez no código real. Os casos observam cada palavra que
aparece com os temporizadores normais, calculam a resposta a partir dessa
observação e clicam nos botões. Não chamam funções de validação, não mudam a
pontuação e não saltam animações. A resposta errada é repetida durante o bloqueio
para verificar que não permite ganhar pontos.

As duas direções têm conclusão dos três níveis, alvos presentes/ausentes,
feedback, avanço e volta ao primeiro nível, reinício, dez velocidades com pulsos
reais, PT no primeiro arranque e PT explícito após reinício. Os controlos usam
cliques nas setas e ajuda; Escape regressa ao menu. As definições de velocidade
e idioma são fixtures aplicadas entre stop/start, não gestos nos diálogos.
A cobertura aleatória observada fica registada por nível; o gate nativo exige
as duas respostas na atividade completa. Os nove fluxos RNG determinísticos no
Node cobrem todos os dados, incluindo ocorrências repetidas de «chuva».

O caso nativo começa sem áudio e estas atividades não têm locução ativa de
palavras/instruções; os efeitos sonoros físicos não são certificados. Não há
entrada de palavras por teclado: o teclado testa a rota Escape. Windows, escola
e revisão linguística/pedagógica do professor continuam fora desta prova Linux.
