# Validar os quatro jogos de ligar pontos e desenhar

Status: ready-for-agent
Progress: claimed
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
