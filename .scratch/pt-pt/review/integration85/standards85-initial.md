Revisão Standards — tarefa 85, intervalo fixo `1efc489b2e1f0b8ddf83d26bf1fda48d0d0bceae...a20b4c2705bcfe9dfafd20b367c32b4cc600c397`.

Sem achados acionáveis. Não identifiquei violações documentadas nem smells Fowler que justifiquem alteração neste âmbito. Consultei AGENTS, documentação de agentes, README/HACKING/REUSE e as skills code-review/tdd; não existem CONTRIBUTING/CODING_STANDARDS adicionais. As alterações de produto restringem-se a oito traduções PT, coerentes com a terminologia de eclusa e com os pré-requisitos reais do banho.

Verificação observada, somente leitura:

- `git log BASE..TIP --oneline` e `git diff BASE...TIP`: sete commits; produção, harness e provas examinados.
- `PYTHONDONTWRITEBYTECODE=1 python3 [-O] -m unittest discover -s tests/functional_cycles -p 'test_*.py' -v`: 13 testes passaram em cada modo, incluindo rejeição de adulteração coerente e preservação de saída existente.
- `python3 tests/functional_cycles/audit.py`: passou; âncora literal `d9751aa9…b70d3`, 18 recibos, dois pares lexicais, três controlos e oráculos físicos independentes.
- `python3 tests/functional_cycles/portable.py`: Docker sem Git, Qt ou checkout histórico; auditor normal e otimizado passaram.
- Comparação independente das cápsulas com `git cat-file --batch`: 909 ficheiros idênticos às três revisões declaradas. Os 1010 objetos arquivados coincidem com os hashes e bytes do tip fixo.

Os retornos permanecem distintos: 11 casos Qt/supervisor/ferramenta `0/0/0`; sete negativos `0/1/1`, dos quais dois lexicais de produto e cinco diagnósticos do fixture. Não são sucessos funcionais adicionais.

O arquivo comprova uma ida e volta da eclusa, um ciclo da água e três níveis de energia. A composição entre rotas anteriores e verificações dirigidas finais, e a escala ausente no JSON histórico do controlo de água, estão delimitadas explicitamente. Não implica nova execução integral na última frase traduzida, estabilidade global, Windows, audição ou aprovação docente. Não executei Qt nem alterei capturas/índices.
