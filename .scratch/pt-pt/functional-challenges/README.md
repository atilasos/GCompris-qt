# Desafios aritméticos — tarefa 79

As campanhas Qt reais, offline, concluíram **186 perguntas principais em 31
níveis**: `guess24` 100/6, `guesscount` incorporado 56/17 e gestão predefinida
30/8. O utilizador de teste resolveu também as quatro perguntas de um nível
configurado pelo editor público. Todos os processos terminaram.

Os 22 recibos selecionados estão em `index.json`: 18 execuções verdes e quatro
vermelhas. Todos os processos Qt retornaram 0; as quatro asserções vermelhas
produziram retorno 1 do launcher e do executor. `launcher-status.json` resulta
do `wait` do supervisor comum; `tool-status.json` resulta do `wait` do processo
que executa `run.py`. Nenhum desses retornos foi deduzido do JSON Qt.

## Reproduzir a auditoria

```sh
python3 tests/functional_challenges/audit.py
python3 -O tests/functional_challenges/audit.py
python3 -m unittest discover -s tests/functional_challenges -p 'test_*.py'
```

O auditor só lê o arquivo físico indicado por `--evidence`. O teste de cópia
executa-o sob `-O` num contentor sem rede onde o caminho original não existe,
sem consultar Git nem executar Qt. Recusa alterações de caso, recibo, cápsula,
manifesto e índice, cobertura vazia e uma falsificação que volta a selar PO,
manifesto, recibos e retornos. A âncora do índice é literal no auditor.

## O que foi observado

O algoritmo de pares procura árvores de operações sobre os quatro números
pintados. O algoritmo linear procura uma operação por linha e lê os números,
alvo e operadores desenhados. Usa frações exatas, resultados intermédios inteiros
não negativos e cada número, no máximo, uma vez. Os operadores lineares podem
ser reutilizados: a origem volta a criar a peça depois de um arrasto. Não se
lê `solutions`, pilhas, modelos de respostas ou históricos internos. A dica do
24 é aberta e fechada, mas o seu texto não é usado para resolver o exercício.

Os 100 desafios do 24 alternaram teclado e rato, 50 de cada. As 86 perguntas
lineares principais usaram arrastos reais. Houve uma resposta errada e reparada
em cada nível, 31 no total, operações negativas/fracionárias rejeitadas quando
o conjunto as permite, contadores Score e Bonus naturais, e avanço até ao nível
seguinte sem escrever progresso. O gesto de arrasto ajusta o ponteiro usando o
centro da peça efetivamente desenhada, para compensar o limiar inicial do Qt.

Os dois casos de controlos verificam ajuda portuguesa/Escape, foco, desfazer
Delete e Tab no 24, navegação que reinicia uma resposta parcial, extremos,
seleção de datasets persistida e retorno ao menu por Ctrl+W. Nenhum jogo oferece
botão de reinício; usa-se a navegação apresentada. No cálculo linear não existe
entrada de números por teclado nem autoria livre de enunciados: o editor permite
subconjuntos não vazios dos quatro operadores para oito níveis. Foi rejeitada a
remoção do último operador, gravado/reaberto um nível com `+` e `-`, jogadas as
suas quatro perguntas e restaurada a configuração. Este ensaio finito não
abrange as `15^8` configurações possíveis.

O inventário estático verifica **todas as 1506 entradas publicadas**: 1310
puzzles de 24 e 196 entradas lineares, contando separadamente incorporadas e
administrativas. Cada uma tem testemunho aritmético independente. Isto não
significa que os 1310 sorteios do 24 tenham sido jogados em Qt, nem que todas as
permutações e configurações tenham sido experimentadas. As campanhas nativas
concluem as perguntas que os níveis realmente apresentam.

## Correções reproduzidas

- `pool-red`/`pool-green`: os níveis 16–17 voltavam a escolher o primeiro grupo
  com quatro operadores. Agora selecionam a ocorrência correspondente do grupo
  publicado. O verde conclui as três perguntas do nível 16.
- `admin-red`/`admin-green`: o contador prometia cinco perguntas para um grupo
  com quatro; a contagem passou a quatro e o verde conclui-as.
- `unsolvable-red`/`unsolvable-green`: a navegação pública encontra os números
  5,5,4,3; com `+`, `-`, `/` e três linhas não existe solução inteira para 6.
  O alvo passa a 7 nas duas cópias do corpus. O verde conclui o nível.
- `label-red`/`label-green`: o falso sentido nobiliárquico de «Conde das
  Adivinhas» foi substituído por «Adivinha a conta» e «Número a obter: N».
  O verde verifica a instrução desenhada e o título da ajuda.

Cada par conserva exatamente os mesmos bytes de caso. As cinco fases históricas
estão em `sources/`, com QML/JS/dados/PO e ferramentas originais; os recibos não
foram reescritos para lhes atribuir outra fase. `effective/` contém os RCC
realmente usados e todos os seus ficheiros extraídos. `catalogue/` guarda os QM
compilados usados. O manifesto do snapshot sela o executável e todos os recursos.
Foram extraídos também o fundo importado, o ícone de desfazer e Bonus/sons do
core. As extrações e a descodificação dos cinco WAV por GStreamer têm retornos
observados em `resource-commands.json`; não constituem audição humana.

Os primeiros ensaios de gesto e uma expectativa incorreta sobre o nível após
mudar de modo ficaram como diagnóstico local em `build/`, fora deste índice.
Uma cópia de teste inicial tentou incluir os deployments temporários, excedeu a
quota e foi corrigida para copiar apenas o arquivo de provas; nenhuma campanha
Qt ou prova original foi alterada por isso.

Windows 10, dispositivos físicos, audição, revisão docente e aceitação global
continuam pendentes. Este lote não declara funcionais os 203 jogos.
