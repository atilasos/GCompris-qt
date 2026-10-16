# Trabalho em curso, tarefa 88

Ainda sem conclusão funcional. O snapshot físico independente build/visual-origin
contém 269 ficheiros e binário 3a226ee745c25aa8cf5e77d7cfb438c83dc6956091e6230053598cca659314bb.
A cópia terminou com zero, sessão 83541, saída d3d6bf. Nenhum Qt executado neste lote.

O módulo puro de procura de pormenores passou dois ciclos TDD. Primeiro
houve ImportError por módulo inexistente, saída 3ba278. A implementação mínima
passou a imagem sintética literal. A segunda fixture falhou porque dois locais
idênticos eram aceites, saída 473966. A implementação passou a rejeitar mínimos
empatados e os dois testes passaram, saída e11d96. A procura usa somente píxeis
opacos da peça e da imagem, sem dados de tabuleiro ou motor. O pormenor da
lâmpada de Van Gogh foi inspecionado visualmente e localizado em 167,14 numa
imagem 376×500, com erro médio de amostras 3,39. Ainda falta campanha nativa,
auditor, cápsula e revisão independente; isto não demonstra cobertura de jogo.

## Inventário visual

Três inventários nativos terminaram Qt/supervisor/capturador com zero:
details sessão 88623/771004 com 21tabuleiros e 106peças; paintings
sessão 57834/64391e com 22tabuleiros e 261peças; photo_hunter sessão 85315/f69bab
com 10níveis. A calibração paintings sessão 68597/e6fdd6 terminou com zero em 22
colocações, sem aceitar qualquer solução. Cada fonte foi congelada antes do pool.

Sete RCC canónicos reais foram copiados do snapshot e extraídos por QtCore,
com 836entradas no total. A primeira procura por píxeis resolveu 106pormenores
com mínimo único e calculou 59componentes diferentes nas fotografias. Isto
não é conclusão de jogo nem contagem de diferenças autorais distintas.

Os PNG individuais `level-N-left/right.png` do primeiro inventário de fotos
contêm recortes incompletos, conforme inspeção visual da imagem 3. Por isso o
oráculo ignora esses PNG, preservados para diagnóstico. Recorta a captura
completa `level-N-question.png` usando os dois quadros desenhados e a sua
geometria exportada. A imagem 3 mostra as duas diferenças corretamente nessa
captura completa. Nenhum parâmetro de resposta do motor alimenta a procura.

## Percursos e correções observados

Photo-complete1 concluiu 10 níveis, 35 diferenças e 10 erros reparados e menu após sucesso, Qt/supervisor/capturador/retorno externo 0. Details-complete2 concluiu 21 tabuleiros, 106 peças e 21 erros reparados e menu. Os dois negativos details anteriores mediram validação antes de a animação de OK terminar; o caso final aguarda okEnabled público, sem alteração ao produto.

Paintings-pilot1 concluiu 3 quadros. Paintings-complete1 concluiu19 dos 22, mas o oráculo propôs ordem visualmente errada para as 6 peças de Bazille, nível 20; Qt 0, retorno externo 1, sem Bonus no nível 20. A causa investigada é o custo de continuidade estreito dominado pelas molduras pretas. Este candidato não é um defeito do jogo nem prova de cobertura dos 22.

Controls-details1 e controls-paintings1 passaram, incluindo ajuda/Escape/teclado/reinício parcial/menu. Os três conjuntos details expõem 8, 6 e 7 níveis. Controls-photo1 falhou por medir sobreposição antes da animação de 1000 ms; controls-photo2 aguarda geometria e passou com barra arrastada realmente até 0.9645, imagem2 opacidade 0.0355, regresso da ajuda e menu parcial.

Captions-details-red e captions-paintings-red registaram 43 legendas e 6 divergências. As mesmas fontes de caso/expectativas passaram nos dois verdes após 6 msgstr PT alterados em eefe6e5ff. As fichas de museus e incertezas estão em caption-facts.md. Gameplay details continua ligado ao PO anterior; a confirmação suplementar da legenda não repete o percurso de peças nem afirma ter usado o mesmo QM.

Media-check1 falhou por rsvg-convert ausente, sem resultado de produto. Media-check2 renderizou/descodificou 562 imagens físicas e 4 efeitos WAV integralmente com GStreamer/fakesink, sem audição ou dispositivo real. Nenhuma aprovação das 32 gravações foi transferida.

## Repetição integral das pinturas

Paintings-complete2, fonte 5747488c2, terminou com zero externo na sessão 8844, saída 132fb1. Qt, supervisor e capturador também terminaram com zero. Concluiu 22 quadros, 261 peças, 305 arrastos, 22 tentativas erradas reparadas e menu estável após o último sucesso. O quadro 20 ficou confirmado com o comparador de faixas RGB. Os outros 21 mapeamentos não mudaram.

O lote final soma 53 tabuleiros, 367 peças e 35 diferenças, com 53 tentativas erradas reparadas. Não inclui repetições dos inventários, piloto ou prefixo de 19 quadros. São 19 execuções nativas preservadas, 13 positivas e seis negativas; todas têm retorno Qt zero. As extrações efetivas dos 19 RCC somam 1014 entradas, além das 836 entradas canónicas. A auditoria portátil e as revisões permanecem por concluir neste registo.
