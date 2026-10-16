# Validar o primeiro rato e os peixes em PT-PT

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25

## Aceitação

Primeiro rato: exploração livre das quatro cores/patos, cliques, movimentos,
arrastos de rato, quatro setas/pressão contínua, limites e feedback audiovisual.
Peixes: completar todos os níveis através de cliques reais em peixes móveis,
verificando contagem, Bonus, transições, fundo, resposta a cliques fora do alvo
e contrato público de níveis. Não imobilizar os peixes nem chamar fishKilled.

Nos dois: ajuda PT, foco, reinício se exposto, navegação/menu e recursos reais.
Usar Qt original, perfil novo offline e recursos privados. TDD para defeitos,
com vermelho/verde nativo e evidência reproduzível. Não aprovar touch/mobile,
dispositivos físicos, audição por altifalantes, Windows ou revisão docente.

## Answer

Verificação delimitada concluída com oito casos Qt finais positivos e três
regressões red/green: publicar seis níveis nos peixes, limitar o passo das
quatro setas à área do pato, e substituir 'click' por «clique» na ajuda PT.
Todos os seis níveis dos peixes passaram (67 capturas reais, seis Bonus),
assim como quatro patos, hover, arrasto, marcador, pressão contínua das setas,
limites/paragem, ajuda, foco, navegação e Home/Escape nos dois jogos.

Auditoria: 27 sprites, seis fundos e sete WAV descodificados, 42 recursos QRC
comparados por hash. SoundEffect não atingiu Ready/playing neste ambiente
sem dispositivo; isso não conta como reprodução ou audição. Este limite
permanece nas aceitações áudio/hardware05/08, sem bloqueio artificial da
integração das três correções comprovadas. Touch/mobile, dispositivos,
Windows e revisão docente continuam pendentes.

Relatório/casos/hashes: `../functional-mouse-fish/README.md` e `index.json`.
Sem mapa/CSV ou escrita no build principal.
