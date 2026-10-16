Revisão Standards87, intervalo fixo `62bbef03fc773f67c6fde234ce700414790ea2e7...08e730b27f099b7b55af58133da67dcb57b46940`.

Sem achados acionáveis. Aplicadas a skill code-review, as normas AGENTS/docs de agentes, README/HACKING/REUSE e todo o baseline Fowler. Não surgiram CONTRIBUTING/CODING_STANDARDS adicionais; não identifiquei violações documentadas ou smells que justifiquem alteração neste âmbito.

A produção altera exclusivamente o verbo da ajuda Sudoku: «deve aparecem» → «deve aparecer». O caso lexical vermelho/verde é idêntico. Os oráculos independentes usam símbolos/pistas e geometria visíveis, distinguindo ausência de regiões, regiões 2×2/3×3 e gaiolas aritméticas. O parser de dados fixos é separado do solver e serve a comparação multiconjunto das pistas para cobertura finita.

Comandos e verificações observados:

- `git log BASE..TIP --oneline` e `git diff BASE...TIP`: cinco commits; PO, harness, cápsula e limites examinados.
- `PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests/functional_grids -p 'test_*.py' -v`: 19 testes passaram, incluindo cópia independente, adulteração coerente de PO/fontes/recibos/status/selo, corrupção física de RCC/QM/QML, cobertura vazia, preservação de saída existente e recusa explícita de `-O` nos validadores.
- `python3 tests/functional_grids/audit.py`: passou; 168 tabuleiros (68 fixos/100 gerados), 18 níveis e erros/reparações, dois controlos, 2128 colocações, 19 recibos, seis RCC canónicos e 863 extrações.
- Comparação independente via `git cat-file --batch`: 498 ficheiros fonte coincidem com as revisões declaradas. `capture.json` e `objects.zip` conservam os bytes do tip fixo: 676 objetos, 814 artefactos, âncora `d5332fa4…603a8e7`.

Retornos Qt/lançador/supervisor/ferramenta: 16 casos `0/0/0/0`; três negativos `0/1/1/1`, incluindo dois diagnósticos de inventário excluídos da cobertura.

A composição separa as 168 grelhas baseline da ajuda/controlos finais e não alega esgotar a geração Calcudoku. Os limites de replay, Windows, hardware, audição, docente e estabilidade83 permanecem explícitos. Não executei Qt nem alterei provas, índices ou fontes.
