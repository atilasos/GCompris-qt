# Jogos de alinhamento — prova Linux PT-PT da tarefa 80

42 partidas completas: galo contra o Tux, 5 níveis × 2 jogadores iniciais (10); quatro-em-linha contra o Tux, 6 × 2 (12); cada modo de dois jogadores, 8 vitórias (ambos os jogadores nas quatro direções) e 2 empates (10 + 10). Não há datasets nem configuração da atividade. Os modos de dois jogadores não apresentam seletor de dificuldade: o galo publica 0, quatro-em-linha publica 1. O antigo valor interno 5 do primeiro não representa cinco modos expostos.

O oráculo reconstrói apenas peças SVG realmente desenhadas, as coordenadas dos delegados, o texto da pontuação e o realce do turno. Conta linhas de comprimento 3/4 nas quatro direções e aplica gravidade independentemente dos motores. Não lê modelos, estado vencedor, estado da IA, histórico nem soluções. Os percursos são executados por cliques, setas, Espaço e Baixo, aguardando animações e a IA reais. As partidas contra a IA terminam legitimamente: galo 3 vitórias humanas, 3 derrotas e 4 empates; quatro-em-linha 5 vitórias e 7 derrotas. Não se promete vencer uma IA perfeita nem esgotar todos os tabuleiros aleatórios.

## Composição de fontes e correções

`source-tree.zip` preserva quatro fases de 244 ficheiros e seis ficheiros de três consumidores estáticos da ajuda comum (982 entradas). `source-phases.json` identifica cada revisão. Os catálogos e launchers fazem parte de cada fase.

- `baseline` 395456d94: 20 partidas do galo, dois tracers e diagnósticos iniciais.
- `help` db9a2095e: três traduções corrigidas. A ajuda de quatro-em-linha dizia linha em vez de coluna, e a variante com amigo descrevia três marcas num quadrado. A frase comum de dificuldade passa a indicar os botões com setas. Mesmos casos vermelhos/verdes em ambos os consumidores de quatro-em-linha. Bargame, checkers e nine_men_morris foram inspecionados estaticamente para a frase comum; não recebem uma nova aprovação funcional neste lote.
- `rules` 76844cb3a: galo publica inicialmente os cinco níveis no ActivityBase. Vermelho público 0 → verde 5, mesmo caso. O empate de quatro-em-linha usava um contador inicialmente 2/3, terminando com 40/39 peças. A correção verifica todas as células ocupadas, preserva vitória prioritária e para o temporizador de IA no empate. Dois mesmos casos vermelhos/verdes provam 42 peças, sem Bonus prematuro na 41. Nesta fase terminaram as 22 partidas completas de quatro-em-linha e os controlos de galo/IA quatro-em-linha.
- `final` e2b86fe45: o Grid recém-recriado ainda tinha coordenadas iniciais quando era escolhida a coluna de teclado. Após reinício, a primeira seta esquerda passava do indicador visível 0 para 5, saltando a coluna 6. `forceLayout()` no início posiciona os delegados antes de escolher a coluna. Os mesmos casos exatos passaram nos dois consumidores, além do controlo completo com amigo. Estes são verdes dirigidos; as 42 partidas anteriores não são apresentadas como execução integral desta última revisão.

Os quatro controlos cobrem reinício parcial, conservação de pontuação no reinício, seletor anterior/seguinte e wrap nos modos IA, ausência do seletor nos modos com amigo, ajuda PT, Escape, foco e menu real. Galo rejeita casas ocupadas; quatro-em-linha com amigo rejeita coluna cheia por rato e Baixo, mantendo turno/tabuleiro. A circulação do indicador pelas sete colunas, Baixo e Espaço têm transições verificadas. As campanhas tentam uma segunda ação durante animação e durante o turno IA e verificam exatamente uma colocação legal. As capturas, recibos e casos completos estão nas pastas com nomes explícitos.

## Auditoria e reprodução

```sh
python3 tests/functional_alignment/audit.py
python3 -m unittest discover -s tests/functional_alignment -p 'test_*.py'
```

O auditor só necessita de `audit.py`, `oracle.py` e uma cópia física deste diretório. Não usa Git, Qt, o build atual ou caminhos históricos. Âncoras SHA literais no auditor prendem o arquivo e o selo; alterar manifesto, caminho RCC, fonte, catálogo, caso ou encadear novamente recibos/status/selo continua a falhar. Python `-O` é recusado explicitamente. As negativas operam apenas em cópias; os recibos originais não são reescritos.

Para uma nova execução, `phase.py --revision COMMIT` congela os inputs; `prepare.py --source-root FONTE --origin-snapshot SNAPSHOT_ORIGEM --output NOVO_SNAPSHOT` compila cinco RCC privados e cria snapshot físico. Consultar `--help` para a interface exata. `run.py --source-root FONTE --snapshot SNAPSHOT --activity ATIVIDADE --case gameplay --output SAIDA_NOVA` usa sempre o supervisor congelado, rede Docker none, host RO e apenas perfil/saída privados RW. `--exact-case` permite repetir o mesmo caso preservado. Uma saída existente é recusada antes de invocar o supervisor ou escrever status. Os snapshots são privados, 269 ficheiros físicos, sem ligações ao build principal; nenhum rebuild do principal foi efetuado por esta tarefa.

## Limites

As quatro WAV foram descodificadas para fakesink, sem audição. Qt iniciou sem som. Linux/Qt e eventos sintéticos não aprovam Windows 10/11, dispositivos físicos, perceção, acessibilidade, áudio, pronúncia ou revisão docente. Não há alterações de vozes nem transferência da aprovação das 32 gravações. As conclusões contam apenas recibos nativos terminados; os diagnósticos falhados não contam para as 42 partidas. Ver `execution-notes.md` para os retornos externos independentes.
