# Concluir os jogos de complemento de dez

Os casos jogam os puzzles completos dos quatro jogos Qt reais, desde o tabuleiro
inicial até ao Bonus e à transição de nível. Selecionam e trocam cartões com
cliques. A calculadora recebe algarismos e Backspace por eventos de teclado e
cliques no NumPad, e valida por OK ou Enter. Estes jogos expõem seleção por
cliques, sem gesto de arrasto.

## Executar

Cria um snapshot independente dos recursos existentes. Depois recompila o core
atual apenas numa cópia privada, para incluir a correção do NumPad da tarefa 33:

```bash
python3 tools/native_qml_resources.py \
  --binary /caminho/build/bin/gcompris-qt --output build/tens-snapshot
python3 tests/prepare_numpad_lock.py \
  --base-snapshot build/tens-snapshot \
  --core-qrc /caminho/build/src/core/core.qrc --output build/tens-core33
python3 tests/functional_tens/run.py \
  --activity tens_complement_find --resource-snapshot build/tens-core33/snapshot \
  --output .scratch/pt-pt/functional-tens/nova-execucao/find
```

Repete a última instrução para `tens_complement_swap`, `tens_complement_calculate`
e `tens_complement_use`, com saídas novas. Acrescenta `--controls` para ajuda,
anterior/próximo, reinício pelo botão Gravar do diálogo de datasets e menu.
A origem de `core.qrc` é lida; os recursos são compilados na cópia privada.
O build principal não é alterado. O launcher usa perfis novos, snapshot verificado,
rede Docker desativada, host só para leitura e UID/GID locais.

## Cobertura

| Jogo | Datasets selecionados | Níveis | Puzzles completos | Linhas matemáticas |
| --- | --- | --- | --- | --- |
| find | 1–4 | 8 | 40 | 120 |
| swap | 1–3 | 12 | 12 | 45 |
| calculate | 1–2 | 4 em cada modo | 8 | 28 |
| use | 1–3 | 6 | 30 | 60 |

`calculate` percorre todos os níveis com teclado virtual desligado e volta a
percorrê-los com teclado virtual ligado. Os restantes jogos têm um modo de jogo
por atividade. Todos os datasets da distribuição estão selecionados no perfil
novo. Os casos não alteram datasets, pontuação, fase, respostas ou soluções do jogo.
A configuração do teclado é a única fixture de modo. Para testar Home através do
menu normal, o caso de controlos limpa apenas o parâmetro de arranque `--launch`.

O teste de cartões distribui os números disponíveis por cálculo matemático.
Uma troca entre duas respostas produz um negativo quando altera a validade;
a ronda mantém apenas o positivo se essa troca não produzir erro. A auditoria
exige pelo menos uma rejeição por nível. Todos os puzzles são concluídos, mesmo
quando os cartões disponíveis têm valores repetidos. O caso swap/calculate
resolve uma permutação por busca, observando os números iniciais e sem usar
helpers de solução do jogo. Na calculadora, zero serve de resposta errada.

O runner Python volta a verificar as equações observadas com somas inteiras,
conservação dos cartões e pares iguais a dez. Em `use`, verifica também que a
primeira parcela original é conservada e que a decomposição tem a mesma soma.
`oracle.json` regista o resultado e hashes de ActivityInfo e dos datasets.
Os controlos negativos do auditor são executados com:

```bash
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover \
  -s tests -p test_tens_math_audit.py
```

O teste aguarda o layout dos delegates e o fim das transições do StackView antes
de clicar. Não acelera nem interrompe animações de pontuação ou Bonus.
Os resultados do launcher incluem hashes dos recursos privados, fonte, catálogo,
caso, binário e capturas. A evidência da tarefa está em
`.scratch/pt-pt/functional-tens/README.md`.

## Limites

Os datasets geram números aleatórios. A execução cobre cada nível e modo
exposto com os valores observados, sem enumerar todos os sorteios possíveis.
Não testa todas as combinações de subconjuntos de datasets. A ajuda é verificada
em PT-PT; isso não substitui a revisão linguística e pedagógica do professor.
Os ensaios headless não certificam som físico, pronúncia, mapa de teclado real,
Windows ou instalação na escola. Não são executados testes de indução de falhas.
