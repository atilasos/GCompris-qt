# Revisão Spec50 parcial

Âmbito fixo `93f5d2aa6...a31083c0`, só três correções de Maze.qml/maze.js e REGRESSIONS.md/casos/seis recibos associados. A tarefa50 permanece claimed; conclusão dos150 casos globais não integra este checkpoint. Sem execução Qt ou alteração de saídas.

Sem achados acionáveis. A publicação de activity.numberOfLevel=25 acompanha o total existente no motor e corrige o contrato público antes do arranque. A atribuição explícita de16 linhas no nível18 corrige entrada direta com zero linhas, preservando a altura que a progressão sequencial já herdava do17. O guard de autoMove respeita a visibilidade do mapa nas variantes invisíveis e mantém o comportamento anterior nas visíveis.

Os três pares conservam o mesmo SHA256 de caso antes/depois. Confirmei por `audit()` importado em modo só leitura: três pares, vermelhos com uma falha e verdes sem falhas, todos offline PT-PT, sem timeout ou erros QML. O nível18 mede diretamente linhas/colunas e posição finita; o pilot mede total público e completa um nível por teclas. O caso de pausa lê paredes desenhadas, navega por entradas reais, liga o botão do modo rápido e mostra o mapa durante a animação. O primeiro passo pode terminar; o registo de posição comprova a suspensão dos seguintes.

A distinção entre corrida inicial de layout da fixture e defeitos de produção está explícita, tal como o ensaio histórico com start-level17 que não provava o18. Não encontrei scope creep ou conclusão integral prematura. Windows, hardware, toque e audição permanecem pendentes. Não foram acrescentados links globais de aprovação na matriz.
