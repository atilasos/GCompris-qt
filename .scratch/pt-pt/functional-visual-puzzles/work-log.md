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
