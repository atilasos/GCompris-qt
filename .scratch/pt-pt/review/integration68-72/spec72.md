# Revisão Spec independente — tarefa72

Inspecionada a correção3ed653d70, autor03d893137 e integração670ff2a7b, com ticket/README, preparação, campanha e regressões. Sem Qt, alteração de mapa/CSV ou escrita de índices.

**Sem achados acionáveis; confiança alta para o contrato corrigido.**

Spec33–35 exige que cada conclusão tenha evidência válida. A preparação deixa de publicar ficheiros individuais numa pasta partilhada incompleta. `phase.freeze()` resolve a revisão para commit, obtém os blobs Git, escreve numa árvore temporária privada e publica por rename apenas depois do manifesto completo. O concorrente que perde a publicação valida o manifesto e todos os bytes do vencedor; não altera uma árvore publicada divergente.

`campaigns.main()` prepara a fonte antes de abrir o pool e passa o commit resolvido aos dez workers. Estes podem verificar/reutilizar a árvore, sem ler a escrita incompleta de outro processo. A fixture real com seis workers confirma esse contrato sem simular execução Qt.

Uma escrita interrompida fica na pasta temporária, que é removida sem publicar o destino; a repetição produz a árvore íntegra. Uma árvore já publicada corrompida é recusada sem voltar a selar. Verifiquei também, numa fixture Git temporária independente, uma árvore final preexistente incompleta/sem manifesto: foi rejeitada e conservou os bytes parciais, sem criar aprovação ou manifesto novo.

Repeti os16 testes (12 existentes/quatro novos): todos passaram. A função pura do auditor manteve22 recibos,574 perguntas e96 pares nível/passo. Conferi os307 ficheiros da lista de preservação: todos coincidem com os hashes históricos declarados. Nenhuma campanha Qt foi repetida ou recibo reescrito.

O lote repara ferramentas futuras e não aumenta contagens funcionais nem transforma uma repetição válida numa aprovação de fontes diferentes. Não há produção alterada, scope creep ou nova afirmação de aceitação global. Windows, hardware, áudio e revisão docente mantêm os limites anteriores; a tarefa72 não fecha automaticamente a tarefa68 ou a especificação203.
