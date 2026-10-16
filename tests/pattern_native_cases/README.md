# Casos nativos preparados para padrões

Estes casos ainda não foram executados em Qt. Os testes puros de geometria,
verificações de geração e sondagens de inventários não provam conclusões de jogos.

- `complete-redraw.qml` cobre o modo público `redraw` ou `redraw_symmetrical`,
  exigindo respetivamente38 ou21 níveis. Apenas o segundo reflete colunas.
- `complete-mosaic.qml` exige22 níveis e deriva cada pergunta atual, incluindo
  as perguntas geradas que diferirem dos inventários históricos.

O agente principal deve incluir `tests/pattern_native_cases` no congelamento
antes de executar. Os dois QML são autocontidos, gerados por `build.py` a partir
de `planner.js`, `common.js` e do adaptador correspondente. Não carregam JS
externo durante o jogo nem invocam Python ou funções de pintura/solução do motor.

```sh
python3 tests/pattern_native_cases/build.py --check
node tests/pattern_native_cases/test-planner.js
```

O único ficheiro de dados lido pelo caso é
`__QA_SOURCE__/tests/functional_patterns/observed-assets.json`. Espera:

```json
{"palette_samples":{"redraw":[{"id":"qrc:/...","signature":"#33ffffff"}],"redraw_symmetrical":[]},"images":{"qrc:/...":{"signature":"rgba160-sha256:..."}}}
```

As cores são calibradas por pintura real. Nas imagens, o URI localiza os bytes;
a assinatura física decide a correspondência. O plano usa apenas centros,
dimensões e assinaturas atuais. A paleta exige imagens qrc prontas, ignorando
MultiEffects com fontes GCText. Os retângulos Redraw admitem borda de largura1
ou3 após hover. As dimensões registadas resultam das esquinas mapeadas à cena,
conservando escalas e rotações reais dos ícones.

Cada nível guarda um alvo inicialmente diferente da pergunta. Quando só existe
um erro inicial, cria um segundo erro visível antes de experimentar a pintura
correta do alvo. Pinta esse alvo corretamente e depois com uma assinatura errada,
completa os restantes e conserva-o errado durante500ms reais. Confere a cor ou
imagem efetiva, ausência de Bonus, Win e avanço; repara por cliques e aguarda
propriedade renderizada, imagem pronta, Bonus bom, Win e continuação naturais.
A espera por ColorAnimation usa a propriedade observada, não um tempo assumido.
O último nível exige regresso ao menu. As campanhas completas podem precisar de
um timeout superior ao padrão240s, por exemplo1200s.

`NATIVE_RESULT` tem `activity`, `boards`, `wins`, `actions`, `evidence`, `scope`
e os contadores QtTest `failures`/`passes`. Cada tabuleiro conserva `level`,
`total`, `completed`, `question`, `answerInitial`, `palette`, `plan`, `holdout`,
`actions`, `prepaint`, `holdWrong`, `wrong`, `repair`, `repaired`, `bonus`,
`nextLevel` e `winsAfter`. Um `guard` só aparece quando necessário. Falhas deixam
o tabuleiro incompleto e os passos já observados, sem fabricar conclusão.

As células observadas têm `frame`, `signature` e `color` ou `source`/`status`.
As amostras de paleta têm `id`, `signature`, `frame`. Cada colocação do plano tem
`question_frame`, `target_frame`, `signature`, `palette_id`. Cada ação guarda
papel, seleção, clique, assinatura esperada e estado pintado antes/depois.
O estado `wrong` conserva todos os alvos, o alvo incorreto, assinaturas esperada
e observada, nível, wins e Bonus; o estado reparado conserva todos os alvos.
`evidence.menuAfterSuccess` guarda `depth`, `busy`, `isMenu`.

`probe_inventories.py` compara o plano JS com o módulo Python independente
`pattern_grid_solver` a partir dos inventários públicos e do registo calibrado.
Recusa saída existente. A primeira sondagem coincidiu em81 grelhas/2486 células,
sem execução Qt nem conclusão de jogos. As fontes de autoria nunca são lidas.
O caso só consome o registo de assinaturas; não consome planos da sondagem.
