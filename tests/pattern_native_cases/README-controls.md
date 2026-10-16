# Controlos preparados em casos separados

`controls-redraw.qml` cobre Redraw e o modo simétrico público.
`controls-mosaic.qml` cobre Mosaico. Ainda não foram executados em Qt pelo autor.
O agente principal deve congelar este diretório antes de os testar; geração e
parse de JavaScript não constituem provas de funcionamento nativo.

```sh
python3 tests/pattern_native_cases/build_controls.py --check
```

`build_controls.py` gera somente estes dois ficheiros. Reutiliza os fragmentos
imutáveis do plano e da observação pública do commit principal `7ce7f4ddd`,
sem incluir o teste de conclusão. Os casos e fontes principais permanecem
inalterados. O ficheiro de entrada continua a ser
`__QA_SOURCE__/tests/functional_patterns/observed-assets.json`.

O caso navega por controlos visíveis até encontrar uma grelha bidimensional.
Em Redraw exige a paleta completa das sete amostras calibradas e associa os
dígitos às imagens pela geometria das etiquetas numéricas realmente desenhadas.
Experimenta todos esses dígitos com uma alteração efetiva da cor, as quatro setas,
Espaço, Return, Enter, Delete e Backspace. Outros erros visíveis impedem uma
conclusão acidental. O arrasto real pinta dois alvos, conservando um terceiro
alvo errado como guarda.

Em Mosaico usa o realce vermelho pintado para observar o foco e a célula atual,
sem ler índices internos. As quatro setas percorrem vizinhos geométricos e
regressam. Tab alterna os realces entre seletor e grelha; Espaço, Return e Enter
selecionam imagens e pintam um alvo com assinaturas efetivamente diferentes.
O caso aguarda o realce na posição desenhada, incluindo a sua animação.

Os dois casos observam uma edição parcial, reiniciam-na por navegação seguinte
e anterior, abrem a ajuda PT-PT, fecham-na com Escape e voltam a pintar por
teclado. Não chamam `forceActiveFocus` para disfarçar a recuperação do foco.
Em seguida selecionam separadamente todos os três conjuntos Redraw ou quatro
Mosaico pelos checkboxes e pelo botão "Gravar". Se necessário, deslocam o painel
com gestos reais; `contentY` só é lido para registar o efeito, nunca atribuído.
Cada conjunto conserva etiquetas, níveis públicos, pergunta, grelha e paleta.
Por fim saem para o menu com uma edição deliberadamente errada, sem Bonus.

`NATIVE_RESULT` guarda `activity`, `wins`, `pointerPaintActions`, `evidence`,
`scope` e contadores QtTest. Exige zero Win: os controlos, conjuntos e navegação
não contam como conclusões. `evidence` contém `keys`, `levelSearch`, `initial`,
`keyboardBeforeHelp`, `keyboardAfterHelp`, `drag` quando oferecido, `restart`,
`help`, `datasets`, `configScroll`, `partialBeforeMenu`, `home` e
`menuDuringActivity`. As verificações falhadas ficam em `evidence.failure`.
Todos os estados relevantes conservam cores/fontes/assinaturas e frames reais.

As verificações estáticas e a cópia deliberadamente alterada do QML gerado
estão descritas em `proof/controls-static.json`. Não foi executado qualquer Qt,
não se leram matrizes ou identificadores de solução, e estes ficheiros não
alteram a contagem de jogos validados.
