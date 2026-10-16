# Primeiro rato e peixes — tarefa 43

Três defeitos concretos têm prova Qt antes/depois:

- `levels-red`: clickgame publicava zero níveis apesar de carregar seis.
  `levels-green` observa seis após publicar o total no start original.
- `boundaries-red`: mantendo a seta para baixo, o pato atingiu y=536 para
  um limite de 532. A guarda verificava um passo de 1, mas movia 5.
  As quatro deslocações usam agora Math.min/Math.max. O mesmo caso passou
  (`boundaries-green`); o caso reforçado `boundaries-complete` mantém cada
  seta durante três segundos, chega aos quatro limites exatos e verifica
  que a posição fica estável após largar. O caso inicial exato está junto do red.
- `help-red`: a ajuda PT mostrava o inglês literal 'click'. `help-green`
  verifica «clique» e a frase corrigida no catálogo compilado privadamente.
  A redação final continua sujeita à revisão docente.

## Comportamento observado

`fish-gameplay` completou os seis níveis originais, com 5/7/10/12/15/18
capturas (67 no total), seis Bonus e retorno ao primeiro nível. Foram
necessários 309 cliques de tentativa em alvos móveis; os peixes nunca foram
imobilizados, as velocidades/RNG/temporizadores não foram alterados e não
foi chamada fishKilled. Cada clique só pode aumentar o contador em uma
unidade. Seis cliques fora dos alvos não alteraram a pontuação. O fundo
correto de cada nível foi carregado e copiado do QRC; foi observada mudança
de posição dos peixes sem intervenção do teste.

`duck-free` operou os quatro patos/cores, verificou a rotação de cada um,
movimento por hover (390,301→460,341), arrasto de rato
(460,341→510,381) e marcador na posição do clique. Trata-se de exploração
livre: não tem níveis, vitória, configuração ou reinício expostos. As
quatro setas são botões visuais, não atalhos de teclado anunciados.

A ajuda PT, foco e regresso por Home e Escape passaram nos dois jogos.
Os peixes têm ainda os botões de nível anterior/próximo verificados com
reposição da contagem. Não existe botão de reinício nestas barras.
O índice separa os oito casos positivos finais das calibrações e dos três red.
Os casos anteriores da ajuda/limites ficam preservados, sem substituir factos.

## Recursos e limite de áudio

`audit.py` lê os dados originais sem usar a função de pontuação. Confere
seis níveis/velocidades, 27 sprites distintos, número/dimensões de frames,
seis fundos e descodificação completa pelo Pillow. Os sete WAV originais
foram descodificados por GStreamer para fakesink. Os bytes dos 42 recursos
copiados da aplicação correspondem aos ficheiros fonte. O sorteio nativo
carregou 22 dos 27 sprites; os outros cinco têm auditoria de dados/descodificação,
sem se declarar uma execução interativa individual de cada sprite.

**A reprodução SoundEffect não foi demonstrada neste ambiente.** Qt regista
«No audio devices available»; os SoundEffect dos patos e dos peixes
ficaram Null, sem playingChanged. O teste regista esses valores e não os
converte em reprodução ou audição. As rotas/bytes e os movimentos visuais
estão verificados; o feedback sonoro efetivo precisa de repetição num
ambiente com saída de áudio. Nenhuma substituição do leitor foi usada.

Cada processo usou perfil novo PT-PT e Docker sem rede. O snapshot tem
269 entradas físicas independentes, sem symlinks ou dependências de
worktrees antigos. Core, cores e dois jogos foram compilados privadamente;
o launcher recompila a atividade e o catálogo PT a partir da fonte corrente.
O build principal não foi alterado. Resultados incluem hashes do binário,
recursos, caso, QML e PO/QM. `audit.json` confere os dados e bytes;
`index.json` identifica os resultados; `artifacts-sha256.json` sela os ficheiros.

Windows 10/escola, dispositivos físicos, touch/mobile, orientação vertical,
saída sonora e revisão linguística/pedagógica docente permanecem pendentes.
A tarefa fecha a verificação delimitada, mantendo o limite SoundEffect nas
aceitações áudio/hardware (05/08). Esta fatia não aprova integralmente os
dois jogos nem os 203 jogos.
