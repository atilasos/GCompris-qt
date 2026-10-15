# Bloqueio do NumPad visual

A coluna5–9 não verificava enableInput, ao contrário da coluna0–4 eBackspace.
Assim, um jogo que bloqueasse a entrada durante feedback/Bonus ainda podia
receber cliques nesses cinco botões. A correção acrescenta a mesma guarda
já usada na coluna esquerda, sem mudar a API ou o despacho de teclas.

O teste Qt real em guessnumber usa propriedades públicas como fixture de
componente: enableInput=false e uma resposta inicial. Os cliques0–4 são
ignorados, mas o5 altera a resposta antes da correção. O baseline regista5
algarismos bloqueados e falha; os10 cliques ativos passam.

Após a alteração, green e reproduced passam10bloqueados/10ativos eBackspace
ativo/bloqueado. A preparação reproduzível recompila core.rcc num runtime
privado e sela um snapshot novo; o build principal não é modificado.
core-build.json e reproduced-core-build.json identificam a fonte e o RCC.

Isto é uma prova do contrato do componente, não conclusão de puzzles. Não
atribui pontuação ou número secreto, não simula Bonus, não prova Windows ou
dispositivos físicos. Os lotes27/28/30/31 mantêm os seus próprios âmbitos.

Reprodução na raiz do checkout, usando o core.qrc gerado pelo CMake e um
snapshot selado que contenha os recursos necessários:

```bash
python3 tests/prepare_numpad_lock.py --base-snapshot /snapshot/base \
  --core-qrc /build/src/core/core.qrc --output /novo/runtime
python3 tools/run-native-qml-case.py --source-root . \
  --resource-snapshot /novo/runtime/snapshot --activity guessnumber \
  --qml-file src/activities/guessnumber/Guessnumber.qml \
  --case tests/numpad_lock.qml --output /novo/resultado --timeout 40 \
  --result-marker NATIVE_NUMPAD_LOCK_RESULT --offline
```

Para reproduzir a falha, preparar o runtime com NumPad.qml da fonte anterior
ou usar um snapshot anterior sem alterar o core. O caso permanece igual.
