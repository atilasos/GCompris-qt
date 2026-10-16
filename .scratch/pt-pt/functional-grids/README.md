# Sudoku e Calcudoku — prova Linux 87

Executar `python3 tests/functional_grids/audit.py` e `python3 -m unittest discover -s tests/functional_grids`. O auditor também funciona numa pasta isolada com apenas audit.py, oracle.py, static_data.py e a cápsula. Não usa Git, Qt, caminhos históricos ou fontes atuais. Python -O é recusado explicitamente.

## Inventário e conclusões

O diálogo real oferece quatro conjuntos Sudoku e cinco Calcudoku. Sudoku: 3×3 símbolos, três níveis com 8/5/5 grelhas; 4×4 símbolos com regiões 2×2, três níveis 5/5/8; 5×5 símbolos/dígitos sem regiões, dois níveis 6/6; 9×9 dígitos com regiões 3×3, cinco níveis de quatro grelhas. Total: 13 níveis e todas as 68 grelhas fixas. A comparação multiconjunto das pistas iniciais confirma a cobertura finita sem alimentar o solucionador.

Calcudoku: cinco conjuntos de um nível, 20 amostras geradas por conjunto: 3×3 (+), 3×3 (+/−), 3×3 (+/−/×), 4×4 (+/−/×), 5×5 (+/−/×/∕). Total: cinco níveis, 100 amostras; não se esgota o espaço aleatório nem se afirma unicidade das amostras ou soluções.

As nove campanhas completaram 168 grelhas, com avanço visível do Score em cada uma e Bonus flower_good natural/continuação em cada um dos 18 níveis. O primeiro tabuleiro de cada nível inclui conflito independente de linha/coluna, realce vermelho visível, rejeição sem alteração e reparação correta: 18 percursos de erro. Erros locais não exigem Bonus bad. Dois tracers adicionais não entram nessas contagens.

## Observação e entradas

O solver puro recebe apenas geometria das células, SVG desenhado, paleta visível, limites de regiões e rótulos aritméticos. Sudoku deriva regiões realmente desenhadas, incluindo a ausência delas em 3×3/5×5. Calcudoku deriva gaiolas das paredes visíveis e interpreta a diferença absoluta e a divisão exata em duas células; gaiolas maiores usam soma ou produto. Não lê soluções ocultas, modelos, funções de resposta ou estados de vitória. O parser de Data.qml serve exclusivamente o inventário/auditor separado.

Cliques reais na paleta/células e teclas numéricas colocam os símbolos. Não há escrita de progresso, grelhas, temporizadores ou velocidade. Os controlos finais selecionam/persistem dois conjuntos, verificam os limites entre dimensões, navegação anterior/seguinte circular, pista fixa imutável, colocação/remoção/recolocação, reinício parcial, ajuda PT, Escape/foco e regresso real ao menu. glyphs.png inspeciona os SVG físicos: cinco formas e dígitos 1–9.

## Fases e resultados observados

Baseline 1061af56417228aa27d123dd4aaa69eb7b5e256a: 168 grelhas, inventários e tracers. A ajuda mostrou «deve aparecem apenas»; o mesmo caso exato falhou e passou com a única correção PO «deve aparecer apenas», commit d740510aa8a87611d28e4776e64c8345fc4b2a64. A fase final contém essa prova dirigida e os dois controlos. Não se apresenta o conjunto anterior como repetição com o PO final.

19 recibos são preservados. Os dois primeiros inventários falharam por seleção demasiado ampla de checkboxes no harness, antes de obter registos; foram corrigidos e repetidos como v2. São diagnóstico excluído. Nesses dois casos e no red da ajuda: processo Qt 0, launcher/supervisor/tool 1. Nos outros 16 casos: os quatro retornos 0. Cada tool-exit.json foi registado apenas depois da resposta real de espera, com sessão/chunk e hashes; saída nativa não é inferida como retorno externo. Todos os processos terminaram.

## Recursos e limites

Snapshot independente de 269 ficheiros, sem symlinks para build principal; duas fontes congeladas atomicamente antes das campanhas. O launcher congelado usa Docker sem rede, host somente leitura e perfil/saída privados UID/GID 1000. Desde o primeiro caso conservou-se deployment: todos os 19 RCC e QM efetivos e extrações reais QResource/QM→TS estão arquivados, além de seis RCC canónicos (core e dois jogos × duas fases), fontes, casos, imagens e estados. A cápsula content-addressed é ligada pelo SHA literal externo de audit.py. As entradas históricas não são reescritas. Testes adulteram bytes RCC/QM/QML, cobertura, retornos e fontes/PO/recibos/estados coerentemente resselados, e testam cópia independente/saída existente. O snapshot completo permanece privado; o arquivo inclui os recursos específicos efetivamente exercitados.

Doze descodificações de seis sons locais por fase terminaram 0 em fakesink: prova de software, sem audição humana. Windows, dispositivos físicos, perceção das imagens, audição, revisão docente global e estabilidade83 permanecem pendentes. Aprovações anteriores de vozes não se transferem. Não há alteração de áudio ou de catálogo além do verbo identificado.
