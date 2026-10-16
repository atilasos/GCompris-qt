# Corrigir o seletor de cores em versões de Qt anteriores a 6.11

Status: ready-for-agent
Progress: resolved
Type: task

## Reprodução

Com Qt 6.10.2, lançar `compass` deixava a aplicação no ecrã de carregamento:

```bash
python3 -B tools/smoke-activity.py --binary build/pt-pt/bin/gcompris-qt --output build/pt-pt/smoke-before --seconds 5 compass
```

O comando terminou com código 1 e três erros QML. `ColorSelector.qml:20` usava
`override property list<color> palette`, sintaxe que o analisador rejeitou.
As notas oficiais do Qt identificam `override` como novidade do Qt 6.11:
https://doc.qt.io/QT-6/whatsnew611.html

## Answer

A lista de cores foi renomeada para `paletteColors`, evitando sobrepor a propriedade
`palette` herdada de Item e eliminando a necessidade da nova sintaxe. Foram migrados
os três utilizadores diretos, incluindo os leitores da lista nas operações de
reposição. Nenhuma API antiga foi mantida.

Após recompilar, o comando seguinte terminou com código 0 e zero erros QML nas
três atividades que partilham o seletor:

```bash
python3 -B tools/smoke-activity.py --binary build/pt-pt/bin/gcompris-qt --output build/pt-pt/smoke-after --seconds 6 compass sketch drawing_wheels
```

O compasso foi também verificado numa janela real, incluindo abrir o painel da
caneta com P. A captura anterior mostrava o ecrã de carregamento; a nova mostra
o painel funcional em português. Caminhos das evidências em `../build-linux.md`.

Os testes de arranque não demonstram todas as operações de edição ou conclusão
de níveis. Esses resultados permanecem pendentes na validação funcional.
