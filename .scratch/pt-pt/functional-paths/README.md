# Codificação e descodificação de percursos

Os quatro jogos concluíram os sete níveis de cada variante, com 829 movimentos
corretos, 28 escolhas erradas rejeitadas e 28 Bonus/transições naturais. São
28 conclusões principais, sem contar pilotos ou repetições de controlos.

| Atividade | Níveis | Movimentos |
| --- | ---: | ---: |
| path_encoding | 7 | 206 |
| path_encoding_relative | 7 | 193 |
| path_decoding | 7 | 203 |
| path_decoding_relative | 7 | 227 |

A codificação usa o caminho cinzento e a bandeira desenhados, com BFS próprio.
A descodificação interpreta a seta laranja visível e a orientação da imagem
do Tux. Teclas, botões e cliques reais alternam conforme o modo exposto.
O teste não consulta caminhos ocultos, movesListModel ou o motor para obter
respostas e não modifica progresso, modelos ou temporizadores.

Quatro casos de controlos verificam movimento parcial, quatro datasets,
seleção persistida de três datasets, redução de sete para cinco níveis,
restauro, reinício, navegação anterior/seguinte, ajuda PT, Escape, nova
entrada depois da ajuda e regresso ao menu.

Quatro casos separados de inventário copiam os bytes QRC dos componentes,
dados e imagens próprios e partilhados, excluindo apenas o GridPath.qml
instrumentado pelo teste. Cada SVG é carregado pelo Image original. Os quatro
Data.qml de cada atividade são instanciados separadamente e as matrizes são
comparadas com o fonte histórico. Esta leitura é apenas inventário, nunca
orienta as ações de jogo. Os três WAV por variante descodificaram para
GStreamer fakesink. Isto não demonstra reprodução física nem audição.

O único ajuste de produção deste lote é o título relativo, antes igual ao
absoluto: «Codificação de caminhos» passou a «Codificação de caminhos
relativos». title-exact-red e controls-fixed-path_encoding_relative têm
exatamente o mesmo SHA de caso, com resultado vermelho e verde. O primeiro
usa o catálogo de be9df9911; o segundo usa 7273ac208. O lançador do vermelho
terminou com 1, os 12 casos positivos terminaram com 0, tanto no lançador
como nos recibos nativos.

Os primeiros controlos esperavam erradamente 49 células após excluir o
dataset 6×6. O seguinte é 8×8, portanto tem 64. O fixture foi corrigido,
sem alterar produção. controls-*, relative-title-red e os pilotos são
preservados como diagnóstico e não contam como casos finais positivos.

A prova usa Qt Linux original, PT-PT, perfis novos e Docker sem rede, com
snapshot selado de 269 ficheiros. O código de jogo, lançador e catálogo dos
percursos principais estão fixados em be9df9911. Controlos e inventários
usam apenas a correção de catálogo em 7273ac208. O auditor lê revisões Git
imutáveis, não ficheiros de worktrees antigas nem o catálogo corrente.

Reprodução da auditoria e dos nove testes puros:

```sh
python3 tests/path_audit.py
python3 -m unittest discover -s tests -p 'test_path*.py'
```

Os casos originais e todos os recibos estão neste diretório. tests/path_prepare.py
compõe os casos de jogo/controlos; tests/path_resources.py compõe inventários.
A auditoria estática independente também verifica os 28 grafos, dimensões,
símbolos, origem/bandeira, ausência de bifurcações e ligação de todas as células.
Testes de adulteração rejeitam casos, recursos, níveis ou identidades alterados
e verificam a auditoria de provas copiadas sem os caminhos de execução antigos.

Continuam pendentes aceitação global Linux, Windows 10 da escola, dispositivos
físicos, touch/mobile, audição e revisão docente. O teste Linux não aprova esses
critérios. A revisão independente final deste lote é registada separadamente.
