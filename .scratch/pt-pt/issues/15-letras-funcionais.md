# Verificar funcionalmente as quatro atividades de letras PT-PT

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 04

## Âmbito

`gletters`, `keyboard_training`, `click_on_letter` e `click_on_letter_up`.
Verificar os níveis PT, os modos de maiúsculas/minúsculas e as configurações
que alteram o comportamento, incluindo velocidade e entrada por teclado/clique.

## Aceitação

- Exercitar as funções reais de jogo, incluindo criação de objetos, respostas
  certas/erradas, composição de acentos, progresso, conclusão e transições.
- Cobrir todos os níveis PT nos testes automáticos e os modos/comportamentos
  distintos no GUI nativo. Não substituir a interação por chamadas ao índice
  de resposta ou por uma asserção de que os dados contêm letras portuguesas.
- Guardar procedimento, hashes e evidência por atividade, com limites explícitos.
- Só atualizar resultados da matriz quando os critérios estiverem demonstrados.
  A aprovação linguística e os testes Windows/escola permanecem separados.

## Answer

Quinze casos nativos delimitados passaram: 74 percursos completos de nível/modo,
1 037 respostas certas e 282 erradas nos quatro jogos. Foram usados os objetos e
funções reais, eventos de rato/teclado/IME, transições e animações normais.
Controlos, dez velocidades, percurso da fila de vozes e regressão da navegação
têm casos separados. [Relatório, evidência e limites](../functional-letters/README.md).

Foi reproduzida e corrigida a seleção inválida conservada ao mudar para um nível
com menos respostas em click_on_letter e na variante de maiúsculas. O caso nativo
anterior lança TypeError e bloqueia a entrada; ambos os casos após a correção
reiniciam a seleção e recebem Espaço corretamente.

A aprovação global Linux, Windows, teclado físico/teclas mortas, audição e revisão
docente continuam pendentes. O tracker global e a matriz são atualizados pelo
integrador. Nenhuma escrita foi feita no build principal.

## Revisão de cobertura nativa de gletters

A revisão detetou que a descrição de erros de acentos excedia a evidência inicial.
O caso agora rejeita explicitamente omissão de acento/cedilha nas 12 formas PT,
nos dois modos, sem outra letra ativa que pudesse aceitar a resposta. A etapa
red confirma a lacuna anterior; a green repete os 26 percursos com 425 certas e
252 erradas. Os restantes casos não mudaram. Evidência inicial preservada e
[novo relatório com hashes](../functional-letters/review-accent.md).

A sugestão de partilhar o pequeno helper input foi avaliada: mantém-se local
para preservar os IDs/asserções lexicais dos fragmentos injetados, sem ampliar
o launcher. O plugin de eventos IME continua partilhado e passou o self-test.
