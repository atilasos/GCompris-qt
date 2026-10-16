# Auditar as provas da tarefa 84

Na raiz do repositório, execute o auditor composto:

```sh
python3 tests/functional_exploration/audit_all.py
python3 -O tests/functional_exploration/audit_all.py
python3 -m unittest discover -s tests/functional_exploration -p 'test_*.py' -v
python3 -O -m unittest discover -s tests/functional_exploration -p 'test_*.py' -v
python3 tests/functional_exploration/apply_language.py
msgfmt --check poqm/pt/gcompris_qt.po -o /tmp/task84-checked.mo
```

O auditor composto verifica as três raízes; os resultados esperados são 98 páginas,
116 perguntas, 16 erros reparados, 30 Bonus, 4 casos de controlos e suplementos de 6 e 8 páginas.
A [documentação da prova](../../.scratch/pt-pt/functional-exploration/README.md)
descreve a cobertura e os limites.

Para usar outra cópia das provas, passe `--evidence CAMINHO` a `audit_all.py`.
Copie também `audit.py`, `audit_supplement.py` e `curriculum.py` para a mesma pasta
do auditor. Não são necessários Git, Qt ou os caminhos originais dos recibos.

Para repetir a verificação isolada, confirme que a imagem local
`python:3.12-slim` existe e execute `python3 tests/functional_exploration/portable.py`.
O comando recusa substituir `portable-verification.json`; preserve o recibo
anterior noutro caminho antes de gerar um recibo novo. O Docker usa uma cópia
física das três provas e executa os testes normal e `-O` sem rede, Git ou Qt.

Para uma nova observação nativa, crie uma fase inédita com `phase.freeze(nome)`
antes de lançar trabalhadores. Use `capture.py --activity NOME --phase FASE
--case CASO.qml --output PASTA_NOVA`. O executor recusa saídas existentes. O
snapshot deve existir em `build/functional-exploration/runtime-snapshot`.
Não reutilize os nomes históricos nem reexecute os criadores de cápsula sobre
raízes já publicadas.
