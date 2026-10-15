# Jogar os conjuntos offline com o motor Qt real

Os fragmentos QML nesta pasta são `TestCase` injetados apenas em RCC privados.
O executável é uma cópia da compilação real; não são recriados os botões,
modelos, regras, Score ou Bonus. Os testes enviam eventos Qt de rato/teclado,
leem os resultados reais e guardam capturas do componente da atividade.

```bash
python3 tools/run-native-qml-case.py \
  --binary build/pt-pt/bin/gcompris-qt \
  --activity multiple_choice_questions \
  --qml-file src/activities/multiple_choice_questions/Multiple_choice_questions.qml \
  --case tests/functional_sequences/multiple_choice.qml \
  --output build/native-results/multiple-choice \
  --result-marker NATIVE_SEQUENCE_RESULT --offline --timeout 90

python3 tools/run-native-qml-case.py \
  --binary build/pt-pt/bin/gcompris-qt \
  --activity ordering_chronology \
  --qml-file src/activities/ordering_numbers/Ordering.qml \
  --case tests/functional_sequences/chronology.qml \
  --output build/native-results/chronology \
  --result-marker NATIVE_SEQUENCE_RESULT --offline --timeout 120

node --test tests/functional_sequences_shuffle.test.mjs
python3 -B tests/functional_sequences_translation.py
```

Usa uma pasta de resultados nova em cada execução. São necessários QtTest QML,
Qt6 LinguistTools, rcc e, para `--offline`, Docker com uma imagem local que tenha
`chroot`. A imagem não é descarregada pelo verificador. O perfil de teste começa
sem recursos em cache e com descarregamentos automáticos desativados. Apenas os
marcadores de boas-vindas/versão são inicializados para as mensagens de primeiro
arranque não taparem os controlos dos jogos.

O launcher recompila o módulo QML e o catálogo PT das fontes do checkout, sem
alterar a compilação partilhada. As dependências restantes vêm dessa compilação.
Em `--offline`, a rede é desativada e o sistema de ficheiros fica só para leitura,
exceto perfil e resultados. `result.json` identifica os hashes do executável,
caso, QML, RCC, catálogo/QM e capturas; exige uma única conclusão explícita,
zero falhas QtTest, ausência de erros QML e saída normal do programa.

O nome de atividade pode diferir do módulo: `ordering_chronology` herda
`ordering_numbers/Ordering.qml`. `--source-root` permite testar outro checkout
com o mesmo launcher. Os fragmentos não têm imports e precisam de uma função
`cleanupTestCase` que emita o marcador configurado, seguido de JSON com
`failures: qtest_results.failCount` e `passes: qtest_results.passCount`.
O launcher substitui `__QA_OUTPUT__` e `__QA_SOURCE__` por caminhos absolutos.

A animação de entrada da aplicação precisa de concluir antes de enviar eventos.
Os casos esperam inicialmente 1500 ms e usam as propriedades reais de Score e
Bonus para esperar os resultados. Não alteram a velocidade dos jogos. O caso
JS adicional controla apenas o gerador aleatório e a fronteira ListModel, usando
os scripts reais de ordenação e Core para verificar soluções e reinício.

Este conjunto cobre dois jogos, com som desligado, em Linux. Não certifica áudio,
ajuda, todas as configurações ou atividades, Windows ou revisão pedagógica.
