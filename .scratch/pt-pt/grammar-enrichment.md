# Gramática PT-PT: contrações e novos níveis

17 de outubro de 2026.

As duas caixas sob `no` e `na` eram criadas pelo motor a partir de `ppt+dtm`,
não por espaços repetidos na tradução. Os ficheiros mantêm a análise completa,
mas passam a definir símbolos conjuntos com `mergedClasses`. O jogo apresenta
uma caixa por contração e pede apenas as classes do objetivo atual. Quando
ambas são pedidas, apresenta um símbolo conjunto de preposição e determinante
ou de preposição e pronome. As línguas sem esta definição mantêm o comportamento
anterior.

| Atividade | Níveis antes | Níveis agora | Frases antes | Frases agora |
| --- | ---: | ---: | ---: | ---: |
| Classes gramaticais | 8 | 13 | 92 | 188 |
| Análise gramatical | 7 | 12 | 80 | 168 |

Foram acrescentadas quatro frases a cada grupo existente, um nível de advérbios,
quatro desafios de classes e cinco níveis de análise. Os desafios incluem
frases mais longas, tempos verbais, determinantes e pronomes, contrações e análise
de todas as classes. As frases novas evitam quantificadores e numerais, que não
têm símbolos próprios nestas atividades.

## Verificação repetível

```bash
node --test tests/grammar_pt_pt.test.mjs
cmake --build build/pt-pt --target rcc_grammar_analysis rcc_grammar_classes -j2
python3 tools/run-native-qml-case.py --binary build/pt-pt/bin/gcompris-qt \
  --activity grammar_classes \
  --qml-file src/activities/grammar_analysis/GrammarAnalysis.qml \
  --case tests/native/grammar.qml --result-marker NATIVE_GRAMMAR_RESULT \
  --output build/grammar-classes-enrichment-check --timeout 1300 --offline
```

Repetir o último comando com `--activity grammar_analysis` e outra pasta de saída.
O teste Node verifica os 356 exercícios com o parser e o modelo de respostas reais,
a aceitação das soluções, a rejeição de respostas erradas, a ausência de espaços
repetidos e as opções disponíveis. Inclui regressões de `no`, `na` e `disto`,
com uma, ambas ou nenhuma das classes pedidas, e o comportamento das línguas que
mantêm caixas separadas.

O teste Qt percorre todas as frases com rato, faz o primeiro exercício de cada
nível com teclado e verifica apagar/corrigir, respostas erradas, pontuação,
transição entre níveis e uma caixa por palavra. Os resultados finais são
registados após a execução.


## Símbolos e apresentação

O caso `tests/native/grammar-contractions.qml` passou quatro cenários na
aplicação Qt. Verifica uma caixa por palavra, seleção, apagar e repor os símbolos,
carregamento das imagens e largura do conjunto de opções. As capturas em
`build/grammar-enrichment-contractions-final/` foram inspecionadas, incluindo
`no`, `na`, `disto` e o nível de análise completa. Resultado em
`build/grammar-enrichment-contractions-final/result.json`.

Para repetir, usar o launcher acima com `--activity grammar_analysis`,
`--case tests/native/grammar-contractions.qml`,
`--result-marker NATIVE_CONTRACTIONS_RESULT` e uma nova pasta de saída.

## Resultado final

Os 11 testes Node passaram. Os recursos locais foram recompilados.

| Percurso Qt | Níveis concluídos | Respostas certas | Erradas rejeitadas | Exercícios por teclado | Apagar e corrigir |
| --- | ---: | ---: | ---: | ---: | ---: |
| Classes gramaticais | 13 | 188 | 13 | 13 | 13 |
| Análise gramatical | 12 | 168 | 12 | 12 | 12 |

Os dois percursos terminaram sem erros QML e regressaram ao primeiro nível.
A análise exercitou 33 palavras com símbolos conjuntos. Resultados detalhados
em `build/grammar-enrichment-classes-current/result.json` e
`build/grammar-enrichment-analysis/result.json`.

Os percursos completos usaram cópias privadas dos recursos. Na revisão final,
`Nós partilhamos isto com todos.` passou a `Nós partilhamos isto com ela.`,
para evitar a questão dos quantificadores, mantendo a sequência de classes.
O parser voltou a verificar os 356 exercícios finais. A disposição dos símbolos
compostos foi ajustada e verificada no caso Qt focal com quatro cenários.

A validação Qt foi realizada em Linux, sem rede e com áudio silenciado.
