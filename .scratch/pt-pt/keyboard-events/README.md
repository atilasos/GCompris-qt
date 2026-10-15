# Eventos de teclado: primeiro lote nativo

O inventário estático encontrou 71 handlers `Keys.onPressed` e 23 candidatos
com setas sem aceitação explícita no handler ou na função JavaScript diretamente
delegada. É uma heurística: métodos QML locais e ramos condicionais exigem
inspeção. Não mede a correção das 203 atividades. Memória pertence à tarefa 21.

Cinco motores foram reproduzidos e corrigidos neste lote:

| Motor | Antes: uma seta direita | Esperado / após | Prova antes | Prova final |
| --- | --- | --- | --- | --- |
| babymatch | índice -1 → 1, salta a primeira peça | -1 → 0 | babymatch-red-final-case/ | babymatch-fixed-test/ |
| algorithm | 0 → 2 | 0 → 1 | algorithm-before/ | algorithm-green/ |
| lightsoff | 0 → 2 | 0 → 1 | lightsoff-before/ | lightsoff-green/ |
| align4_2players | coluna 0 → 2 | 0 → 1 | align4_2players-before/ | align4_2players-green/ |
| money | duas moedas: 0 → 0, circula duas vezes | 0 → 1 | money-red/ | money-green/ |

Cada caso injeta um TestCase QtTest no RCC privado do motor e usa `keyClick`
real. Os cinco casos finais passam sem erros QML; a seta seguinte/esquerda
confirma um movimento. Escape atravessa ActivityBase e chama `menu.home`
exatamente uma vez. O objeto menu é substituído por uma fronteira de contagem
apenas durante essa asserção, para não destruir o TestCase ao sair da atividade;
não se apresenta isso como ensaio visual completo do menu.

A correção aceita o evento apenas para as teclas tratadas por cada motor.
As restantes continuam a propagar-se. `ActivityBase.forwardTo` não foi alterado.
Os motores babymatch, align4 e money têm atividades derivadas que herdam a
correção, mas neste lote não foram repetidas as provas em cada variante.

Reprodução de um caso, a partir deste checkout:

```sh
python3 tools/run-native-qml-case.py \
  --binary /caminho/build/bin/gcompris-qt \
  --activity algorithm \
  --qml-file src/activities/algorithm/Algorithm.qml \
  --case tests/native/key-navigation/algorithm.qml \
  --output /tmp/novo-diretorio-vazio
```

Babymatch usa `tests/native/keyboard-babymatch.qml`. As restantes usam o ficheiro
com o seu nome em `tests/native/key-navigation/`; money usa `MoneyCore.qml` e
align4_2players usa `Align42players.qml`. Os metadados `result.json` conservam
hashes do executável, fonte, catálogo, fragmento e RCC privado. A rede não foi
bloqueada nestas provas; não são prova de execução Windows ou conclusão de níveis.

Restam os restantes candidatos do inventário para triagem e reprodução. Mesmo
uma entrada que contenha `event.accepted` pode ter outros ramos incorretos; a
presença desse texto não é uma garantia. Nenhum outro motor foi corrigido sem
reprodução neste lote.
