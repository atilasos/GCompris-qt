# Adivinhar um número

Os 17 níveis dos cinco datasets foram concluídos duas vezes, com teclado
físico simulado e teclado visual: 34 percursos. A pesquisa binária usa apenas
as pistas apresentadas, sem ler numberToGuess nem alterar o número secreto.
Verifica os intervalos portugueses de 1–10 até 1–1 000 000, digitação/Backspace,
Enter/OK, pistas de maior/menor, Bonus e transições naturais.

O primeiro ensaio passou com 177 pistas de demasiado alto e 169 de demasiado
baixo. O ensaio final, após integrar o core33, passou os mesmos 34 percursos
com 180 pistas de demasiado alto e 174 de demasiado baixo. A sequência é
aleatória; index.json distingue os ensaios e conserva hashes dos resultados.
As 34 respostas corretas do ensaio final não dependem de leitura da resposta
interna nem de chamadas a setUserAnswer.

A ajuda tinha uma etiqueta HTML incompleta antes da instrução Enter. O caso
controls original passou, mas não verificava essa estrutura; foi reforçado,
reproduziu a falha em help-baseline e passou em help-green após corrigir
`</li></li` para `</li><li>`. O caso final também verifica reinício com resposta
pendente, anterior/próximo, ajuda PT, fecho e regresso real ao menu.

Perfis novos e Docker sem rede; cada RCC da atividade/catálogo é privado e
as restantes dependências vêm de um snapshot completo selado. O teste não
representa teclado/rato físicos, audição, execução Windows ou aceitação docente.
Não há gestos no diálogo de datasets e a matriz global mantém esses limites.

Reprodução, para gameplay ou controls:

```bash
python3 tools/run-native-qml-case.py --source-root . --binary /build/bin/gcompris-qt \
  --activity guessnumber --qml-file src/activities/guessnumber/Guessnumber.qml \
  --case tests/functional_guessnumber.qml --output /novo/resultado --timeout 300 \
  --result-marker NATIVE_GUESS_RESULT --offline
```

Trocar o caso por tests/functional_guessnumber_controls.qml para ajuda e
controlos. O binário de origem deve conter os recursos offline e o core33;
para repetir mais casos pode usar --resource-snapshot em vez de --binary.
