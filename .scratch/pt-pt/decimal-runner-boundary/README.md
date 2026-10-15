# Retorno do launcher — tarefa36

A reprodução percorre a CLI real de `tests/functional_decimals/run.py` numa
cópia temporária mínima. O launcher é um subprocesso Python normal: grava
result.json verde e termina com código 1, sem crash ou processo Qt.
O inventário lê os datasets reais por ligação, sem lhes escrever; nenhum jogo
ou deployment é executado.

Antes da correção, o runner aceitava `(launcher 1, Qt verde)` e terminava 0;
`red.log` fixa esse falso sucesso. A correção exige `returncode == 0` além do
relatório verde e da contagem correta, sem remover qualquer critério anterior.
`green-first.log` confirma a regressão corrigida. `green.log` fixa os três
percursos e os quatro testes anteriores do auditor: sete testes verdes.

```bash
python3 -m unittest discover -s tests/functional_decimals -p 'test_*.py' -v
```

Percursos: launcher 1+JSON verde é rejeitado; launcher 0+JSON falhado é rejeitado;
launcher 0+JSON verde é aceite. As asserções observam o retorno público da CLI
e o summary.json produzido, sem mock de funções internas.

`historical-proof-audit.json` confirma os 20 relatórios finais da tarefa30:
launcher 0, Qt 0, resultado verde e SHA256 idêntico ao índice existente. Não
se repetiram os 316 puzzles, nem se alteraram as provas históricas, jogos,
mapa, CSV ou build principal. O subprocesso fixture cobre a fronteira de
orquestração, não pretende substituir a validação nativa Qt arquivada.
