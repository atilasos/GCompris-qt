# Validar os quatro jogos de ligar pontos e desenhar

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25

## Aceitação

Cobrir number_sequence, clickanddraw, drawletters e drawnumbers, todos os níveis
originais. Validar transição automática e manual por configuração persistida;
no number_sequence cobrir também realce ligado/desligado. Usar números ou
realce realmente visíveis para escolher pontos, sem ler a resposta esperada
do motor nem chamar drawSegment/won. Testar pontos fora da ordem e cliques
fora dos alvos, linhas/pausas entre traços, imagem final, Bonus e transições.

Ajuda PT, configurações, reinício/navegação/foco/menu e metadados públicos.
Inventariar dados/pontos/recursos com referência independente; observar imagens
Qt originais e os áudios realmente solicitados. Separar MediaPlayer, SoundEffect,
descodificação e audição física, sem substituir as classes ou temporizadores.

Qt real, perfis novos offline e recursos privados independentes. TDD para bugs,
com vermelho/verde. Sem certificar touch/mobile, hardware, Windows ou revisão
pedagógica/sons de letras por testes automáticos.

## Answer

18 casos Qt finais completos:126 percursos,3408 pontos,252 entradas rejeitadas,
46 pausas e126 Bonus. Todos os níveis/configurações dos quatro jogos, modos automático
e manual persistidos e realce ligado/desligado passaram. Oito casos separados
verificam ajuda PT, reinício por Gravar, navegação/foco/Home/Escape.

Corrigida aceitação dupla da mesma pressão (loop/atualização estacionária),
pausa do N e ponto redundante do K; grupos M explicitados sem mudar o traçado
e três valores G não usados removidos. Mesmo caso N em red de entrada, red de
pausa e green final, mais red/green K e auditoria dos dados.

Auditor confere 100 recursos QRC e 297 ficheiros nos cinco RCC contra a fonte. As 36 vozes
A–Z/0–9 tiveram MediaPlayer real PlayingState/posição positiva; SoundEffect
continua sem prova de reprodução por falta de dispositivo, com WAV descodificado
para fakesink. Hardware/áudio 05/08, Windows e revisão docente mantêm-se pendentes.
Relatório, limites e hashes: `../functional-drawing/README.md` e `index.json`.
Sem escrita no build principal, mapa ou CSV.
