Revisão Standards — tarefa 86, intervalo fixo `7f285a2dc41a0530c70bee098a5c8866d116bc04...279aeaea6161642fe296c1292127856490ded92e`.

Sem achados acionáveis. Examinei as normas AGENTS/docs de agentes, README/HACKING/REUSE e a skill code-review, aplicando todo o baseline Fowler. Não encontrei CONTRIBUTING/CODING_STANDARDS adicionais, violações documentadas ou smells que justifiquem refatoração neste âmbito.

A produção altera exclusivamente dois `msgstr` em `poqm/pt/gcompris_qt.po`: Daughter-in-law → Nora e Son-in-law → Genro. O oráculo usa geometria, anéis, realces e opções desenhadas; não consulta respostas/modelos internos. Os testes geométricos literais distinguem ascendência, irmãos, primos e afinidade. A categorização iconográfica está explicitamente condicionada e não transforma aparência em certeza biológica ou pedagógica.

Comandos/verificações observados:

- `git log BASE..TIP --oneline` e `git diff BASE...TIP`: cinco commits; fontes de produto, harness, arquivo e limites revistos.
- `PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests/functional_family -p 'test_*.py' -v`: 15 testes passaram, incluindo cópia física, adulteração coerente, cobertura vazia, conservação de saída existente e recusa explícita de `-O` nos validadores.
- `python3 tests/functional_family/audit.py`: passou; 36 níveis, 46 conclusões naturais, 36 erros/reparações, 28 pares, dois controlos, dez recibos, seis RCC canónicos e 716 extrações físicas.
- Comparação independente via `git cat-file --batch`: 478 ficheiros fonte coincidem com as duas revisões declaradas. `capture.json` e `objects.zip` conservam os bytes do tip fixo; 485 objetos, 500 artefactos, âncora literal `72462c40…a66c5be`.

As quatro camadas de retorno estão separadas: oito casos `0/0/0/0`; dois vermelhos lexicais `0/1/1/1`. Os casos vermelhos/verdes são idênticos. Não executei Qt nem alterei provas. A cobertura finita e as ambiguidades iconográficas estão delimitadas; Windows, audição, acessibilidade, revisão docente, estabilidade83 e aceitação global continuam pendentes.
