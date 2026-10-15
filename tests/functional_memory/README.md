# Memória PT-PT: testes nativos

```bash
python3 tests/functional_memory/run.py \
  --binary /caminho/para/gcompris-qt --output /novo/diretorio
```

Requer a aplicação compilada com recursos locais, Qt6 rcc, Node e a imagem Docker
já disponível usada pelo launcher. O diretório deve ser novo. `--case gameplay`,
`controls`, `keyboard_home` ou `restart` repete só uma área nos três jogos.

O runner reconstrói os RCC das três atividades a partir do checkout atual.
O launcher reconstrói MemoryCommon com o caso e o catálogo PT num QM privado;
todos os recursos são copiados transitivamente uma vez para um snapshot selado.
Cada aplicação liga apenas a esse snapshot e recebe
perfil novo PT-PT e Docker sem rede. O build principal nunca é escrito.

## O que os casos verificam

- `data.test.mjs`: todos os 21 significados numéricos, 26 pares de glifos/som e
  49 pares numeração/borboletas dos oito datasets, capacidade das grelhas e
  correspondência entre algarismo e quantidade de borboletas visíveis. O modelo
  do zero contém uma borboleta de tamanho zero; essa imagem não conta como item.
- `gameplay.qml`: cinco níveis wordnumber, quatro case-association e oito
  enumerate, nos modos de um/dois jogadores. O caso agrupa cartas pela semântica
  visível (palavra/algarismo, letra ou quantidade), nunca pelo matchCode do motor.
  Submete pares por cliques reais e usa setas/Espaço num par de cada nível.
  Verifica erro, exposição durante o atraso, terceira carta bloqueada, pontuação
  só após resolução, pares encontrados desativados, Bonus e transições. Nos dois
  jogadores, erros alternam o turno e há vitórias dos dois jogadores.
- `controls.qml`: botões anterior/próximo, ajuda PT, fecho e menu.
- `keyboard_home.qml`: Escape continua a chegar a ActivityBase.
- `restart.qml`: quatro setas com destinos inequívocos e reinício com uma carta
  aberta nos dois modos; aguarda mais de 1500 ms para detetar temporizador antigo.

Não há atribuição de pontos, marcação de cartas encontradas, alterações de duração
ou chamadas a selected/checkMatch/reverseCards para responder. A configuração
playerCount é uma fixture pelo ciclo normal stop/start; não equivale a testar
cada gesto do diálogo de opções.

A regressão curta `key_regression.qml` tem comando próprio pelo launcher:
atividade memory-wordnumber, componente src/activities/memory/MemoryCommon.qml,
marcador NATIVE_MEMORY_RESULT. Completa o primeiro nível por setas/Espaço e verifica
Escape; reproduziu a entrega dupla das setas antes da correção.

`wordnumber_help.qml` demonstra a correção da ajuda: os pares associam algarismos
a números por extenso. `wordsgame_contract.qml` é a verificação curta solicitada
na continuação da tarefa20: os dois contadores públicos/locais indicam três níveis.

## Estado da verificação

Consultar `.scratch/pt-pt/functional-memory/README.md`. O lote inicial sem debugger
teve saídas139 por reescrita de recursos ainda mapeados (diagnóstico23). O replay
com snapshot selado25 passou os 12 casos sem debugger. As falhas históricas e as
passagens diagnósticas sob GDB ficam separadas da evidência final. Não inferir
aprovação global Linux/Windows de testes de dados ou capturas.

Os casos arrancam sem som e o ambiente headless não tem dispositivo de áudio.
Teclado físico, som/pronúncia, revisão docente, Windows e instalação na escola
mantêm-se fora desta evidência automatizada.
