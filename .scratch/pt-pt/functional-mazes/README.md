# Três labirintos no Qt nativo PT-PT

As seis campanhas terminaram com saída zero: 25 níveis de maze,
mazeinvisible e mazerelative, com modo rápido ligado e desligado. São 150
conclusões principais, 7164 eventos de direção, 2158 rotações relativas e 150
colisões rejeitadas. Mais 18 tracers por gestos de rato cobrem níveis 1, 14 e 25
nos dois modos e três variantes, com 1112 eventos, 470 rotações e 18 colisões.
Não são outra campanha completa com rato. Os três controlos também passaram.
O índice contém 27 recibos positivos e 145 hashes de artefactos.

## Oráculo e controlos

O teste lê posições/dimensões das paredes desenhadas, constrói um grafo
próprio e calcula um caminho por pesquisa em largura, conferindo passagens
dos dois lados e limites. A posição vem da imagem animada do Tux e da porta,
sem ler a matriz JS ou coordenadas/soluções ocultas, chamar movimentos
internos ou escrever progresso/modelos/temporizadores. Os caminhos principais
contêm 8602 células, não todos os passos automáticos.

No invisível, mostra o mapa pelo controlo permitido, observa e volta a
ocultá-lo antes de mover; confirma bloqueio de uma ordem enquanto observa.
No relativo, calcula rotação pela imagem do Tux. Seleciona modo pelo botão
e confere sapatos; espera estabilização natural antes de observar a célula
seguinte. Cada nível tem colisão, Bonus e transição natural. Os tracers abrem
níveis pelo CLI e conferem o índice efetivo. São disposições aleatórias,
sem certificar todas as permutações.

Controlos verificam próximo/anterior, velocidade, ícone do mapa, ajuda PT,
Escape, teclas após ajuda e Home/menu. Não há configuração local ou reinício
nesta barra. As 24 cópias de recursos Qt correspondem a oito originais usados/
carregados nas três atividades. brick.wav descodificou para fakesink; não há
prova de reprodução SoundEffect ou audição física.

## Correções e diagnósticos

[REGRESSIONS.md](REGRESSIONS.md) conserva três pares nativos idênticos antes/
depois: publicar 25 níveis, altura do nível 18 aberto diretamente e pausa de
autoMove com mapa visível. As primeiras campanhas full e pilotos ficam fora
do índice. O fixture inicial observava posições antes do fim das animações
de layout; o final configura o modo e espera estabilização. O defeito da
pausa foi reproduzido também num caso curto independente. direct-18-red
abriu realmente 17 por opção CLI incorreta; só direct-18-baseline prova a
falha de 18. Parciais e negativas de fixture não contam como conclusões ou
defeitos do produto.

## Reproduzir e auditar

```sh
python3 tests/functional_mazes/run.py --snapshot /snapshot/selado --output /nova/campanha
python3 tests/functional_mazes/pointer_tracers.py --snapshot /snapshot/selado --output /novos/tracers
python3 tests/functional_mazes/audit.py
python3 -m unittest discover -s tests/functional_mazes -p test_audit.py -v
```

resource-snapshot.json descreve 269 entradas físicas independentes. Todos
os casos usam Docker sem rede, UID/GID1000 e perfis/saídas privados. Todos
terminaram sem erros QML, timeout ou deployment retido. Ambas as sessões de
campanha saíram com código zero; não há processos pendentes. Controlos usam o launcher
tools/run-native-qml-case.py, QML src/activities/maze/Maze.qml, caso
tests/functional_mazes/controls.qml, marcador NATIVE_MAZE_RESULT, --offline
e saída nova por atividade.

O auditor compara fontes maze/wrappers, catálogo e gerador com a revisão
Git 8d9492256b0b49c5a67a8703914739b4e72316fc realmente testada. Confere casos
arquivados, snapshot e 145 artefactos sem paths históricos obrigatórios.
Catálogos posteriores alterados noutros jogos não têm de manter o hash.
Estas provas também não aprovam modificações futuras de maze. Seis testes
verificam cópia independente e recusa de nível ausente, recurso, caso ou
identidade de fonte adulterados.

Pendente: aceitação global Linux, Windows10/escola, dispositivos físicos,
touch/mobile, outras orientações/DPI, audição e revisão docente.
