# Gatos & Cães, duas pessoas

A base da branch work/crjm-04 foi confirmada como descendente de integration/crjm-games b78753319. O seam é a aplicação Qt real, aberta pelo menu. Não foram substituídas regras ou posições.

## Red e green

O primeiro caso, antes da atividade existir, procurou Gatos & Cães no menu real e falhou com uma asserção, sem erros QML. O resultado e log estão em red/. Com a atividade integrada, o caso completo passou com zero falhas, duas passagens QtTest e zero erros QML.

Comando green executado nesta worktree:

```sh
python3 tools/run-native-qml-case.py --resource-snapshot /tmp/crjm-native-base --activity menu --from-menu --extra-activity dominorio --extra-activity gatos_caes --qml-file src/activities/menu/Menu.qml --case tests/crjm/gatos-caes.qml --output /tmp/crjm04-green --offline
```

O red usou o mesmo comando, sem --extra-activity gatos_caes, caso inicial de descoberta e output /tmp/crjm04-red. Os dois result.json preservam hashes, Qt, imagem Docker e isolamento docker-none. Renderer software, sem GPU e sem rede.

## Comportamentos verificados

Menu e descoberta, tabuleiro 8×8, primeira colocação central dos Gatos, primeira colocação dos Cães fora do centro, rejeição de adjacência ortogonal e de casa ocupada sem consumir turno, diagonal permitida, casas legais opcionais, ajuda PT-PT sem perda de posição, partida completa de 33 ações legais até vitória dos Gatos, bloqueio das ações após o fim, reinício, rato, teclado, toque sintético e retorno ao menu.

A sequência de 33 ações foi verificada independentemente contra as regras CRJM no commit b206a7b4948673be935a5cb6a5a84df92d3ba6c2. Está literal no caso nativo e é executada exclusivamente pelas casas visíveis. Implementação, textos e ícone SVG foram criados independentemente; não se importou código, texto ou arte licenciados CRJM. A ajuda contém atribuição da referência de regras.

Inspeção visual de desktop.png 1100×700, portrait.png 600×900 e result.png: textos legíveis sem sobreposição, controlos dentro da janela, centro assinalado, peças com identificação 1 G / 2 C além da cor e resultado coerente. Casas de desktop maiores que 40 píxeis e retrato maiores que 70 píxeis. O teste também exige tamanho mínimo de 40.

O teste de toque é sintético QtTest; não demonstra uso num tablet físico. Não houve avaliação pedagógica com crianças nem publicação externa. Contra Tux e introdução guiada pertencem ao ticket 05.
