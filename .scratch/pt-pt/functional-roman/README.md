# Números romanos: execução nativa em PT-PT

A execução final de `roman_numerals` concluiu os 14 níveis, com 102 perguntas,
102 respostas erradas seguidas de reparação e 14 transições Bonus. Usou 51
respostas pelo teclado físico simulado e 51 pelo teclado virtual. As perguntas
visíveis e o feedback estavam em português de Portugal.

## Correções observadas

| Caso idêntico antes e depois | Defeito reproduzido | Correção |
| --- | --- | --- |
| `bounds-probe.qml` | O nível com máximo 50 gerou 51 na amostra 58. | Gerar inteiros entre 1 e o máximo, inclusive. |
| `reset-probe.qml` | A pergunta 74 repetiu 48 e conservou `XLVIII` no campo. | Limpar a entrada em cada pergunta, mesmo quando o valor se repete. |
| `blank-answer.qml` | Apagar a resposta correta e premir Enter ainda aumentou a pontuação. | Limpar também a conversão quando a entrada fica vazia. |

Os três pares conservam o mesmo SHA do caso vermelho e verde. As fases de
produção são `7a93fa86e`, anterior às correções, `31121a829`, com limites e
reinício corrigidos, e `5425ec71e`, com a entrada vazia corrigida.

As duas sondas verdes da fase intermédia recolheram 150 perguntas cada. A sonda
de reinício encontrou perguntas consecutivas iguais dentro da mesma ronda e
confirmou a entrada vazia. Estas 300 amostras adicionais não aumentam a contagem
das 102 perguntas da execução final.

## Cobertura e limites

Os dez primeiros níveis contêm 62 perguntas fixas. Os quatro últimos contêm
40 perguntas aleatórias, com máximos 50, 100, 500 e 1000. O teste interpreta a
instrução desenhada e calcula a resposta por um algoritmo independente. Não lê
`questionValue`, `romanConverter` nem soluções internas. A auditoria compara a
sequência observada com as fontes preservadas. Não esgota todas as escolhas
aleatórias possíveis.

O caso de controlos verifica ajuda em português, Escape, foco do teclado após
a ajuda, apagar pelo teclado virtual, navegação anterior e seguinte, passagem
do nível 14 para o 1, reinício de uma entrada parcial, dica, menu e Home. A opção
pública `ApplicationSettings.isVirtualKeyboard` liga e desliga o teclado nos
testes. A persistência pelo diálogo global de definições não faz parte desta
prova. A atividade não apresenta um seletor próprio de conjuntos de dados.

Outro caso rejeita `MMMM`, `IIII`, `VX`, `IL` e `IIV`, e aceita a reparação. Estas
respostas adicionais não entram nas 102 perguntas principais. O caso de recursos
confirma seis ficheiros QRC e o carregamento das imagens SVG pelo Qt. Os dois
WAV originais passam a descodificação completa por GStreamer para `fakesink`.
Isso confirma a leitura por software, sem certificar audição ou dispositivo.

Existem imagens guardadas dos 14 níveis. A inspeção visual incluiu o nível 14
final e os casos vermelhos de limite e entrada vazia. Os testes não usam OCR
nem reconhecem os píxeis de cada pergunta.

## Provas preservadas

`capture.json` fixa 77 ficheiros selecionados por SHA-256. `source-tree.zip`
preserva 218 ficheiros, incluindo as três versões do QML, o catálogo PT, os
recursos e os executores. `resource-snapshot.json` identifica os 269 ficheiros do
runtime privado. Cada recibo liga o binário, o caso, as fontes, o catálogo e os
recursos efetivos. O Docker corre sem rede e com UID e GID 1000.

Os dez casos selecionados são sete positivos e três vermelhos esperados. Todos
terminaram o processo Qt com código 0. O supervisor e a ferramenta externa
terminaram com 0 nos positivos e com 1 nos vermelhos. `launcher-status.json`
regista o retorno observado pelo supervisor. `tool-status.json` transcreve o
retorno efetivamente recebido da ferramenta externa, com sessão e identificador
de saída. Não confundir esses três códigos.

As pastas `pilot`, `pilot2`, `complete` e `noncanonical` são históricas e ficam
fora da seleção final. O primeiro piloto tentou usar o teclado virtual quando a
preferência estava desligada. A execução `complete` pertence à fase intermédia
e foi substituída por `complete-final`. Nenhum destes casos aumenta a cobertura
declarada. `execution-notes.json` conserva os detalhes dessas fases.

## Verificação reproduzível

Na raiz do repositório, estes comandos verificam as provas sem iniciar o Qt:

```sh
python3 tests/functional_roman/audit.py
python3 -m unittest discover -s tests/functional_roman -p 'test_*.py'
```

A auditoria funciona sobre uma cópia isolada das provas e das ferramentas, sem
consultar os caminhos antigos do runtime ou o Git. Os 12 testes incluem as
conversões canónicas e recusam alterações de respostas, amostras vazias, casos,
fontes históricas, catálogo, imagens guardadas e retornos externos adulterados.
Também recusam execução com `python -O`. `index.json` é apenas a saída derivada
da auditoria.

A prova cobre software em Linux. Windows 10, instalação na escola, dispositivos
físicos, audição e aceitação docente global continuam pendentes.
