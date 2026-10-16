# Casos preparados de Polígonos, tarefa 90

Entrega de casos para execução pelo responsável da tarefa. **Não houve execução
Qt, parsing por Qt, campanha nativa nem aprovação de comportamento nesta árvore.**
Se um piloto falhar, primeiro conferir as capturas da cena inteira, os vértices
realmente desenhados e o foco. Uma expectativa falhada não demonstra por si só
um defeito do produto.

Base: `work/pt-patterns`, `cef9f0cf14c9842d12b6d8e41033efc233971195`.
Só são acrescentados ficheiros nesta pasta. Nenhuma alteração de produto,
registry, fase, build, snapshot ou provas nativas.

## Entradas e fronteira

`proposals.json` copia exatamente a proposta independente fornecida em
`tests/functional_patterns/polygon-proposals.json` da árvore pt-patterns.
`observed-instructions.json` conserva apenas as nove perguntas visíveis,
contagens de páginas introdutórias e SHA-256 do recibo `inventory-polygons`.
Não se leu `TutorialDataset.qml` nem `polygons.js`. A preparação volta a verificar
cada candidato pela biblioteca independente `polygon_geometry_oracle`, incluindo
a correspondência estrita entre pergunta e classe, sem consultar o motor.

A fronteira nativa usa cliques, arrastos e teclas reais. Os pontos observados
são exclusivamente delegados visíveis, pelas propriedades geométricas
`centerX`, `centerY`, `radius`, dimensão e posição na cena. Não há leitura do
modelo, índice do modelo, listas de resposta, grelha escondida ou histórico.
Cada clique guarda uma cena inteira e uma observação da geometria renderizada.
A unidade da grelha é obtida do desenho de dez intervalos e, nos delegados,
da dimensão pública `radius`. Os sinais públicos `Bonus.win` e `Bonus.loose`
são apenas observados; não se chamam métodos Bonus nem validadores.

O único ajuste de lançamento, autorizado pelo responsável, é
`ActivityInfoTree.startingActivity=''` antes do clique Home real. Impede que
`--launch` encerre ao chegar ao menu. É configuração do harness e não altera
progresso ou estado do exercício. Não se alteram temporizadores, posições,
seleções, modos ou níveis por escrita interna.

## Casos separados

- `prepared/pilot.qml`: instrução inicial, tentativa colinear
  `[[2,4],[5,4],[8,4]]`, rejeição natural sem vitória/avanço, reinício real,
  candidato independente correto, Bonus e continuação naturais. Deve ser
  executado antes dos restantes. Falta de rejeição é registada antes da falha.
- `prepared/tutorial-nine.qml`: nove instruções, introduções por botões reais,
  tentativa colinear e reparação por nível, OK por clique e Enter alternados,
  nove Bonus/continuações naturais, retorno circular, ajuda/Escape e menu após
  os sucessos. Não navega para preparar a fase final.
- `prepared/controls-free.qml`: navegação anterior/seguinte circular e reinício
  parcial no tutorial; mudança e persistência de Modo Livre pelo diálogo real;
  nove classes propostas como exemplos livres, sem níveis artificiais nem
  Bonus; recusa de novo vértice em figura fechada, arrasto, eliminação por
  duplo clique, seleção/movimento/eliminação por teclado, criação de um
  triângulo pelo cursor desenhado, ajuda/Escape e menu após trabalho criado.

As expectativas de foco, diálogo e receção das teclas ainda são hipóteses do
caso, a confirmar no piloto nativo. Modo livre não significa todas as figuras
ou combinações possíveis. Não há formatos de ficheiro oferecidos nesta atividade.

## Preparação sem Qt

`PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests/pattern_polygon_cases`
executa seis testes Python. Logs red/green são da preparação, não do produto.

Para uma pasta nova:

```
python3 tests/pattern_polygon_cases/prepare.py --output tests/pattern_polygon_cases/prepared-v2
```

O gerador recusa saída existente. Os três QML em `prepared/` já incorporam
as propostas e o fragmento comum; só deixam `__QA_OUTPUT__` para o launcher.
Passar cada ficheiro ao supervisor/capturador habitual, sempre com saída nova,
fontes congeladas e deployment retido. Recomenda-se timeout de 600 segundos
para os nove níveis, sem reduzir animações. O responsável observará os quatro
retornos e preservará todos os resultados, inclusive falhas e pilotos.
Windows, dispositivos, audição, docente, estabilidade 83 e aceitação global
continuam fora desta preparação.
