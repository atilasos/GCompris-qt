# Retirar palavras estrangeiras desenhadas nos ícones

A ajuda real em português mostrava `WORD` porque o texto estava convertido em
contornos SVG. Uma inspeção de contacto dos 203 ícones encontrou outras palavras
inglesas e duas francesas fora dos catálogos PO.

Foram corrigidos oito ícones, conservando os desenhos que identificam os jogos:

| Atividade | Antes | Depois e significado |
| --- | --- | --- |
| `grammar_classes` | `WORD` | `ABC`: um grupo de letras associado a uma classe de palavras. |
| `grammar_analysis` | `THE WORD` | `ABC DEF`: dois grupos de letras associados aos dois símbolos gramaticais. |
| `hangman` | `WORD` | `ABCD`: quatro letras e quatro posições por preencher. |
| `imagename` | `EGG`, `BOW`, `STAR`, `CUP` | `ABC`, `DEF`, `GHI`, `JKL`: exemplos genéricos de etiquetas junto de imagens. |
| `letter-in-word` | `BOAT`, `BAT`, com `O` em destaque | `ABCD`, `ACD`, com `B` em destaque: a letra em falta coincide com a diferença entre os grupos. |
| `ordering_sentences` | `It`, `is`, `fun` | `ABC`, `DEF`, `GHI`: grupos de letras em cartões para ordenar. |
| `lang` | `LUNE`, `SOLEIL` | `ABC`, `DEF`: exemplos genéricos de etiquetas de linguagem. |
| `memory-wordnumber`, em PT-PT | `2 two` | `2 dois`: mantém a correspondência correta entre numeral e nome. |

As sequências ABC não são palavras a ensinar: representam texto no ícone.
Não foram alterados exercícios, respostas ou regras dos jogos. Mantiveram-se
cartões, imagens, caixas, triângulos, cores e a colocação dos grupos de texto.
As siglas/unidades dos exercícios de medidas imperiais, como `lb`, foram
conservadas porque representam o conteúdo desses exercícios.

Os contornos novos foram obtidos com QPainterPath a partir de
`src/core/resource/fonts/Andika-R.ttf`, a fonte já distribuída pela aplicação
(OFL-1.1). São caminhos vetoriais incorporados, sem uma dependência nova de
fontes no computador da escola. A identificação e licença dos desenhos
originais foram conservadas. O novo SVG português de memória tem a atribuição
original de Timothée Giet e licença CC-BY-SA-4.0 em `REUSE.toml` e nos metadados.

## A correspondência entre numeral e nome usa um recurso português

A alteração específica para Portugal usa um SVG novo; os outros locales
conservam o recurso original. Foi acrescentado
`memory-wordnumber-pt.svg` com `2 dois`, selecionado por `ActivityInfo.icon`
quando `ApplicationInfo.getVoicesLocale(ApplicationSettings.locale)` devolve
`pt`. O normalizador existente trata `pt_PT` e a língua do sistema. A expressão
depende de `ApplicationSettings.locale`, que notifica alterações de língua.
Os valores `pt_BR` e `en_US` conservam o SVG original, sem uma alteração global
específica para Portugal.

Foi criada uma implantação privada com uma cópia do executável real e um RCC
de memória recompilado. Para observar a seleção do motor QML real, apenas a
cópia privada de `ActivityInfo.qml` recebeu uma linha de diagnóstico
`Component.onCompleted: console.log("MEMORY_ICON", icon)` e `import QtQml`.
Essa instrumentação não foi acrescentada às fontes distribuídas.

A execução `--list-activities --locale <língua>`, com perfis novos, mostrou:

| Fontes | Locale | Valor observado de `icon` |
| --- | --- | --- |
| Antes | `pt_PT` | `memory-wordnumber/memory-wordnumber.svg` |
| Depois | `pt_PT` | `memory-wordnumber/memory-wordnumber-pt.svg` |
| Depois | `pt_BR` | `memory-wordnumber/memory-wordnumber.svg` |
| Depois | `en_US` | `memory-wordnumber/memory-wordnumber.svg` |

Os quatro logs `locale-*.log` contêm o valor observado. Não houve erros QML.
`memory-resource.json` regista os dois SVG expostos pelo RCC compilado, com
caminhos, tamanhos e hashes. O padrão `*.svg` do CMake já inclui o recurso novo.
Não foi alterada a compilação partilhada.

## Inspeção visual com Qt

Os SVG reais foram renderizados por QSvgRenderer a 400×400, com transparência.
Foram inspecionados os oito pares antes/depois e a
[vista conjunta final](after-overview.png), confirmando letras legíveis,
ausência de cortes ou sobreposições e a conservação dos símbolos dos jogos.

- [Classes antes](grammar-classes-before.png) e [depois](grammar-classes-after.png).
- [Análise antes](grammar-analysis-before.png) e [depois](grammar-analysis-after.png).
- [Forca antes](hangman-before.png) e [depois](hangman-after.png).
- [Imagens antes](imagename-before.png) e [depois](imagename-after.png).
- [Letra antes](letter-in-word-before.png) e [depois](letter-in-word-after.png).
- [Frases antes](ordering-sentences-before.png) e [depois](ordering_sentences-after.png).
- [Língua antes](lang-before.png) e [depois](lang-after.png).
- [Memória antes](memory-wordnumber-before.png) e [depois](memory-wordnumber-after.png).

A captura da ajuda integrada que originou o problema continua em
`build/pt-pt/interface-grammar-help.png`, na compilação original.

Para repetir uma renderização:

```bash
c++ -std=c++17 -fPIC tools/render-activity-icons.cpp \
  $(pkg-config --cflags --libs Qt6Svg Qt6Gui) -o /tmp/render-icons
QT_QPA_PLATFORM=offscreen /tmp/render-icons --single \
  src/activities/memory-wordnumber/memory-wordnumber-pt.svg /tmp/memory-icon.png
```

O mesmo utilitário aceita uma lista de caminhos SVG, um por linha, e gera uma
imagem de contacto com dez colunas. As legendas de nomes de ficheiros nessa
imagem servem à inspeção, não fazem parte dos ícones da aplicação.

Não foram escritas asserções que repetissem caminhos SVG. A evidência do ajuste
gráfico é a renderização inspecionada, acompanhada da seleção real do recurso
por língua e da leitura do pacote compilado. Esta correção não certifica todos
os recursos gráficos das atividades ou a execução Windows, que tem tarefa própria.
