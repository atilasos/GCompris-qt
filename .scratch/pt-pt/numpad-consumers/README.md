# Uma tecla por entrada: consumidores NumPad

Os quatro motores adicionais duplicavam a entrada física: uma tecla `5`
produzia `55`, e Backspace sobre `52` apagava os dois algarismos. A prova
inicial está nas pastas `*-before/`, com falhas QtTest sem erros QML. Em
learn_decimals_additions, Backspace em `5,2` também produzia `5`, em vez de `5,`.

A correção pertence a cada consumidor: `handleAnswerKey(event, pressed)` aceita
apenas dígitos/Backspace tratados e encaminha press/release para o NumPad.
O motor dos decimais aceita vírgula e ponto apenas na fase de resultado com
botão decimal habilitado; as teclas de validação já tratadas aceitam o evento.
Teclas desconhecidas continuam a propagar-se. NumPad.qml e Algebra.qml não
foram alterados nesta tarefa.

## Prova final e limites

`verified/summary.json` liga os dez casos:

| Atividade | Âmbito ensaiado |
| --- | --- |
| tens_complement_calculate | Uma tecla por dígito e Backspace; modo input herdado do motor swap |
| scalesboard | Entrada depois de preparar uma balança equilibrada, num nível com pergunta |
| scalesboard_weight | Mesma fronteira, com a derivada métrica real |
| scalesboard_weight_avoirdupois | Mesma fronteira, com a derivada de onças real |
| guessnumber | Uma tecla por dígito e Backspace |
| learn_decimals_additions | Fase de resultado; dígitos, Backspace e separador decimal PT |
| learn_decimals_subtractions | Mesma fronteira na derivada de subtrações |
| tens_complement_swap | Fase swap sem edição numérica; atalhos globais |
| learn_decimals | Fase de representação sem edição numérica; atalhos globais |
| learn_quantities | Fase de representação sem edição numérica; atalhos globais |

Os sete casos de entrada verificam literalmente `5 → 5`, depois `2 → 52`, e
`52 + Backspace → 5`. Os dois casos decimais verificam separador `,`, entrada
`5,2`, Backspace para `5,`, e normalização de ponto para vírgula. Todos os dez
verificam Ctrl+W e Escape a alcançar `menu.home` uma vez cada; os casos de
entrada também verificam que uma tecla A não altera a resposta. A fronteira do
menu é substituída apenas durante essa contagem, evitando destruir o TestCase.
Não se apresenta isso como navegação visual completa.

As fixtures selecionam um cartão input real no modo calculate. Nas balanças,
selecionam um nível com pergunta e preparam pesos iguais, sem testar os gestos
de pesar. Nos decimais, preparam barras corretas no modelo e chamam a validação
real da representação, que abre a fase de resultado. Estes preparativos não
constituem prova de resolução de puzzles nem de todos os níveis ou submodos.
A base learn_decimals e learn_quantities não são declaradas fases de teclado
decimal ativo: foram controlos da fase inativa.

## Reproduzir

Criar um snapshot independente, sem recompilar nem alterar o build original:

```sh
python3 tools/native_qml_resources.py \
  --binary /caminho/build/bin/gcompris-qt \
  --output /tmp/novo-snapshot-selado
python3 tests/numpad_consumers/run.py \
  --resource-snapshot /tmp/novo-snapshot-selado \
  --output /tmp/novo-diretorio-de-resultados
```

O launcher da tarefa 25 verifica o snapshot antes/depois de cada execução e
compila apenas RCC privados a partir deste checkout. Cada `result.json`
conserva o manifesto e hashes dos recursos, executável, QML, catálogo, caso e
RCC privado. O snapshot usado ficou em `build/numpad-resource-snapshot`, fora
do Git. Os ensaios foram nativos Linux com QtTest; não são audição, aceitação
Windows nem validação interativa das 203 atividades.

`final/` conserva o primeiro percurso de dez casos. `verified/` repete os dez
com o launcher atualizado após sincronizar 75f56f71f: todos passaram, os hashes
QML e do launcher coincidem com as fontes entregues, e o mesmo manifesto
selado foi conservado. A rede não foi bloqueada nestes casos; a validação
offline e Windows continua nos respetivos percursos de implantação.
