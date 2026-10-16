# Memória: cinco variantes restantes

Usa os casos QtTest inseridos no componente original MemoryCommon, com eventos
reais e snapshot transitivo imutável. Não lê matchCode, não atribui respostas,
pontos ou turnos, nem reduz temporizadores. O oráculo identifica pares por
ficheiro de imagem/som; no caso das letras, associa lowerX.svg a upperX.svg.

```sh
python3 tests/functional_memory_rest/run.py --binary /COPIA/bin/gcompris-qt \
  --output /NOVO/DIRETORIO --jobs 4
```

O runner recompila privadamente os sete RCC necessários e cria um snapshot
completo. Para reutilizar uma cópia selada, acrescentar `--snapshot /SNAPSHOT`.
`--case` permite repetir só gameplay, controls, restart, keyboard_home,
audio_probe ou configuration. Os dois últimos aplicam-se apenas aos jogos
com áudio de cartas ou configuração 1/2 jogadores, respetivamente.

Cada modo do percurso longo é preparado antes de iniciar a atividade; o caso
configuration prova separadamente a seleção por cliques/teclas e a gravação
persistente pela interface. As respostas e pontuações nunca são preparadas.
Os casos aplicam a seam de reinício stop/start já aprovada; o reinício pela
interface de Gravar é também exercitado na configuração dos dois jogos.

```sh
node --test tests/functional_memory_rest/data.test.mjs
python3 -m unittest discover -s tests/functional_memory_rest -p test_audit.py
```

O auditor dos recibos exige todos os pares (nível,modo), valores de pontuação,
capacidade de pares incluindo derrotas, sinais Bonus e recursos originais.
Controlos negativos recusam nível em falta, pontuação inventada, capacidade
errada e erro de descodificação. Para auditar os recibos preservados:

```sh
python3 tests/functional_memory_rest/audit.py \
  --gameplay .scratch/pt-pt/functional-memory-rest/sealed-gameplay \
  --voices-inventory .scratch/pt-pt/functional-memory-rest/voices-inventory.json \
  --output /NOVO/relatorio.json
```

Para conferir também os sete RCC contra a fonte atual, compilar o utilitário
Qt já existente em tools/pt-pt-audio/rcc_inventory.cpp (Qt6Core) e acrescentar
`--resource-snapshot /SNAPSHOT --rcc-inventory /CAMINHO/UTILITARIO`.

A saída regista o caso combinado exato em `<atividade>/<caso>-input.qml`.
Esse ficheiro é a referência da execução, inclusive quando um helper é
posteriormente corrigido. A evidência e os limites estão em
`.scratch/pt-pt/functional-memory-rest/README.md`.
