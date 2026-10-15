# Correção do identificador programmingMaze no launcher nativo

A revisão de seguimento encontrou que `run-native-qml-case.py` rejeitava
`programmingMaze` antes de preparar o teste, por aceitar apenas minúsculas.
O verificador de arranque já aceitava este identificador do projeto.

O launcher passa a aceitar `[A-Za-z0-9_-]+`, tal como o verificador de arranque.
Não foi criada uma abstração nova para duas verificações de argumentos.
A regressão pública em `tests/test_activity_identifiers.py` percorre todos os
203 identificadores de `src/activities/activities.txt` nas duas interfaces CLI,
incluindo o nome com maiúscula. Rejeita também caminhos relativos, barras,
pontos, espaços e metacaracteres antes de criar qualquer saída.

O teste usa executável/caso inexistentes como sentinelas. Chegar à validação
seguinte demonstra que o identificador foi aceite; não prepara recursos nem
executa jogos. Isto cobre a falha concreta de argumentos, sem afirmar validação
funcional das 203 atividades.

Antes da correção, a suite falhou apenas em `programmingMaze`, com a mensagem
«Invalid activity or QML source path». Depois da correção, as duas verificações
passaram. Os dois testes existentes do verificador de arranque também passaram:

```bash
python3 -B -m unittest discover -s tests -p test_activity_identifiers.py
python3 -B -m unittest discover -s tests -p test_smoke_activity.py
```

Foi também corrigida a descrição do âmbito em `result.json`: a aplicação começa
sem som, mas cada caso pode alterar as definições de áudio. A descrição não
confunde a observação de descodificação/reprodução do caso com aprovação de som
físico ou pronúncia. Não foram alterados argumentos de execução, resultados
anteriores, código dos jogos ou a compilação partilhada. O launcher do worktree
que ainda tinha testes demorados em execução não foi modificado.
