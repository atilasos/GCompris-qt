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

## Segundo lote: dez motores

Nove defeitos adicionais foram reproduzidos e corrigidos; `learn_digits`
passou antes de qualquer alteração. O handler deste último pertence à raiz
ActivityBase e não ao pageComponent, pelo que a ausência de aceitação explícita
não reproduziu o problema de encaminhamento. A atividade não foi alterada.

| Motor | Antes de aceitar a tecla | Após a correção |
| --- | --- | --- |
| binary_bulb | seleção dá a volta 0 → 0 | 0 → 1 |
| frieze | seleção dá a volta 0 → 0 | 0 → 1 |
| programmingMaze | instrução 0 → 2 | 0 → 1 |
| simplepaint | cursor 0 → 2 | 0 → 1 |
| solar_system | planeta 0 → 2 | 0 → 1 |
| polygons | cursor 0 → 2 | 0 → 1 |
| submarine | velocidade solicitada 0 → 2 | 0 → 1 |
| analog_electricity | área desloca-se -400 | -200 |
| digital_electricity | área desloca-se -400 | -200 |

As provas estão em `batch2/`: `*-red/` ou `*-before/` para a falha e `*-green/`
para a correção. `summary.json` liga os resultados finais, confirma os hashes
QML/fragmentos atuais e regista a dependência JavaScript do motor frieze. Os
nove casos finais também verificam seta esquerda e a chamada de menu por Escape.
Os tutoriais são fechados no setup; a navegação dos tutoriais não foi validada.
Para submarine, o runner privado precisa do plugin Box2D do build: definir
`QML_IMPORT_PATH=/caminho/build/lib/qml` antes do mesmo comando de reprodução.
Esta referência foi só de leitura; não foi alterado o plugin nem o build original.

O inventário reconhece agora também `event.accepted = variável`, pelo que
multiple_choice_questions deixa de ser um falso positivo (o código existente
já define `event.accepted = acceptEvent`). `inventory-batch2.json` conserva
sete candidatos estáticos: learn_digits passou como controlo negativo e seis
entradas continuam por reproduzir. Crane tem bloqueio durante movimentos;
guess24 delega a seleção num helper; note_names depende do modo musical e
três listas são componentes Rectangle de diálogos/menu (BackgroundMusicList,
ServerConfigPage e MelodyList). Nenhuma dessas seis entradas foi alterada ou
classificada como defeito sem prova nativa. A memória e a gramática mantêm os
seus ensaios e correções próprios, fora desta tarefa.

Em submarine, a prova final é `batch2/submarine-ctrl-w-green/`: além de uma
seta e Escape, verifica que Ctrl+W continua a alcançar o menu. Uma revisão
intermédia da correção consumia W com Control; o teste adicional reproduziu
esse efeito colateral e a versão entregue deixa esse atalho global propagar.
A contagem final de chamadas de menu é duas (uma por Escape e uma por Ctrl+W).
