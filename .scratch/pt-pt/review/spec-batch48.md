# Spec da tarefa 48

Base `c722da9e9`, merge `7ffe1e5e03e0a62be3b2d6180075e37880c58dfd`.
Revisão independente do ticket 48, diferenças de produção, casos, auditor,
README, índice e recibos. Sem alteração de fontes, índices ou novas campanhas.
A tarefa 46 da minha autoria está excluída.

Não encontrei achados acionáveis contra a aceitação delimitada.

Os 18 recibos finais passam com código zero e sem falhas Qt. Conferi os
hashes de caso e resultado do índice. Os dez casos de jogo cobrem 126
percursos: nove níveis de number_sequence nas quatro combinações de modo e
realce, nove de clickanddraw nos dois modos, 26 letras e dez algarismos nos
dois modos. O auditor regista 3408 pontos, 252 negativos, 46 pausas e 126
Bonus. Os oito controlos cobrem ajuda PT, reinício parcial por Gravar,
navegação, foco e saída Home/Escape.

O solver escolhe o menor rótulo numérico visível ou o recurso azul de realce.
Não usa pointIndexToClick nem o fixture para escolher o próximo alvo. A
observação desse índice verifica o efeito dos eventos reais. Os fixtures
conferem quantidades, imagem final e pausas, e cada conector é comparado com
as posições efetivamente clicadas. Configuração persistida e progressão
manual/automática têm verificações explícitas.

As alterações do loop e da atualização estacionária respondem à dupla
aceitação reproduzida. Os recibos N conservam o mesmo SHA de caso nos dois
vermelhos e no verde. A pausa do N e o vértice redundante do K têm provas
próprias; as alterações M/G explicitam ou removem grupos sem acrescentar
traçados. Não encontrei declaração de certificação pedagógica desses desenhos.

O relatório separa reprodução MediaPlayer das 36 vozes, descodificação do WAV
e ausência de prova SoundEffect neste ambiente. As 100 identidades de recursos
e 297 entradas RCC são objeto de auditoria. Os limites de audição física,
Windows, hardware, touch/mobile, DPI e revisão docente continuam explícitos.
A pressão/movimento/libertação de rato na MultiPointTouchArea não é apresentada
como certificação de ecrã tátil. Diagnósticos negativos ficam fora dos 18 casos
aprovados. Esta revisão verifica a coerência das provas conservadas, sem
repetir as campanhas.
