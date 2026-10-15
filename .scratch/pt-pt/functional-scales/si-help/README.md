# Corrigir a concordância no título da balança SI

O catálogo PT apresentava "Balança que usam o Sistema Internacional de Unidades".
O caso Qt real abriu a ajuda e reproduziu a discordância entre o sujeito singular
e o verbo plural. `baseline/` guarda a captura, o log e o resultado com uma falha.

A correção troca apenas "usam" por "usa" nesse título. `green/` guarda a mesma
execução com o catálogo privado recompilado: 2 passes, 0 falhas, código 0,
sem timeout nem erros QML. A ajuda mostra o título corrigido. O caso também
verifica a relação kg/g na ajuda, anterior/próximo, reinício por Gravar após um
arrasto parcial e regresso ao menu. Ambas as execuções usam o mesmo caso, e os
resultados registam os hashes dos casos, catálogo, recursos e binário.

Reproduzir usando um snapshot independente já preparado, sem escrever no build:

```bash
python3 tools/run-native-qml-case.py \
  --resource-snapshot /copia/selada \
  --activity scalesboard_weight \
  --qml-file src/activities/scalesboard/Scalesboard.qml \
  --case tests/functional_scales/controls.qml \
  --output /novo/resultado --offline --timeout 60 \
  --result-marker NATIVE_SCALES_RESULT
```

Esta fatia corrige apenas o título. A tarefa 34 continua `claimed`; os puzzles
completos das três balanças e a respetiva auditoria permanecem em execução.
Não certifica Windows, dispositivos físicos, audição ou revisão docente.
