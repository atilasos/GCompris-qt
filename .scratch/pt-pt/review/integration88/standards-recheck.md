Recheck Standards88 — delta fixo `4afe862cb26c3845c97e87e9c034e285001fab63...e7b09959a2308076223ba41b6bcddc76022fc1a1`.

P2 fechado. `tests/functional_visual_puzzles/run.py:14` recusa agora saída ou log ocupados por ligação simbólica pendente; `capture.py:10` faz a mesma guarda na sua entrada direta. Ambas as verificações precedem preparação, lançamento e escrita. Nenhum novo achado acionável no delta.

Verificações observadas:

- `git log BASE..TIP --oneline` e `git diff BASE...TIP`: correção isolada das guardas, regressões e remoção da linha vazia conhecida; nenhuma alteração de produto.
- A reprodução original `/tmp/repro-standards88-dangling-output.py` termina agora com código 2, «Output and parent log must both be new».
- `python3 [-O] -m unittest discover -s tests/functional_visual_puzzles -p 'test_output_boundary.py' -v`: dois testes/sete subcasos passaram nos dois modos. Confirmam recusa antes de preparação/lançamento, preservação dos links/bytes e ausência de novo log.
- A descoberta completa desse diretório passou: cinco testes em cada modo, incluindo as três verificações de píxeis anteriores.
- Comparação Git e leitor físico: os seis ficheiros da cápsula permanecem byte a byte iguais à base/tip; âncoras do índice e ZIP aceites, 1567 objetos, 19 execuções e 14 fases intactos.

A correção protege futuras observações; não exige repetir jogos nem resselar provas. Não executei Qt/build, não alterei main/provas e não avancei aceitação global ou estado da tarefa.
