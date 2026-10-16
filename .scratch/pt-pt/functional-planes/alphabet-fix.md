# Alfabeto português com 26 letras

O catálogo PT traduzia a sequência do jogo para 23 letras, omitindo k, w e y. A Base I do Acordo Ortográfico de 1990 define um alfabeto de 26 letras, com formas minúsculas e maiúsculas. A correção repõe essas três letras na única tradução de `AlphabetSequence`.

Fonte primária de consulta: [Base I, Portal da Língua Portuguesa](https://www.portaldalinguaportuguesa.org/?action=acordo&id=1-1&version=1990). Publicação oficial: [Diário da República, 23 de agosto de 1991, anexo I](https://files.diariodarepublica.pt/1s/1991/08/193a00/43704388.pdf).

`alphabet-catalogue-red.log` e `alphabet-catalogue-green.log` conservam o teste do catálogo antes e depois. O solver nativo usa um alfabeto independente, não deriva respostas desse catálogo ou de dados privados da atividade. `alphabet-order-red` conserva a primeira reprodução: a–j capturados normalmente, seguida da ausência de k, com saída nativa 0 e lançador 1. As primeiras tentativas de controlo por interceção também revelaram limites do harness, preservados separadamente como diagnóstico, sem os atribuir ao produto.

As fontes anteriores são a revisão `fb5e4eac9f0e7740673acf79d06eb63fe5449875`; a correção é `7e1d611bd246763bdfb4ba63ccbe09dbd36078c3`. `alphabet-modern-red` observa no Qt a captura de l quando o oráculo espera k. `alphabet-complete`, com exatamente o mesmo SHA-256 de caso, concluiu as 104 capturas dos quatro níveis, incluindo indicação oculta e maiúsculas. Recibo Qt e estado externo final são 0 no verde; o vermelho tem Qt 0 e lançador 1. A aprovação funcional é limitada a esse percurso Linux e não substitui revisão docente.

Os recursos de voz preexistentes para k, w e y são inventariados sem alterar os seus bytes. A descodificação por software e a aprovação das 32 gravações de outro lote não equivalem a audição ou aprovação de pronúncia destas vozes. Revisão docente, Windows e dispositivos físicos continuam pendentes.
