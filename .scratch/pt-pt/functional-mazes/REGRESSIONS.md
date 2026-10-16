# Três regressões reproduzidas nos labirintos

As campanhas completas da tarefa50 continuam em curso. Este checkpoint só
prova três correções por testes nativos curtos, com perfil PT-PT novo e rede
desligada. Não resolve a tarefa nem aprova as atividades na matriz global.

| Caso idêntico antes/depois | Antes | Depois |
| --- | --- | --- |
| pilot.qml | A interface comum declara 0 níveis | Declara 25 e o primeiro nível termina por teclas |
| direct-18.qml | Abrir diretamente o nível 18 cria 0 linhas | Cria 16 linhas e 18 colunas, com posição finita |
| map-pause.qml | Tux avança além do primeiro passo enquanto se vê o mapa | O mapa visível suspende os passos automáticos seguintes |

Os pares de diretórios são `pilot`/`pilot-green`,
`direct-18-baseline`/`direct-18-green` e
`map-pause-baseline`/`map-pause-green`. Cada par preserva exatamente o mesmo
SHA256 de caso. `regressions.json` sela resultados e logs. A altura 16 mantém
a dimensão que o nível18 já recebia ao chegar pelo nível17; não aumenta a
dificuldade. O CLI usa níveis a partir de 1, portanto este teste usa
`--start-level 18`. O ensaio anterior com 17 abriu realmente o nível17 e
fica apenas como diagnóstico de fixture.

O caso da pausa encontra um corredor nas paredes desenhadas, chega lá por
teclas com modo rápido desligado, liga esse modo pelo botão e mostra o mapa
durante a primeira animação. O primeiro passo pedido pode terminar; os
seguintes têm de esperar. O registo `MAP_PAUSE_OBSERVATION` demonstra que o
motor continuava pelo corredor enquanto a mensagem de observação era visível.
O guard de autoMove passa a respeitar o mesmo bloqueio do movimento manual.

Os primeiros ensaios longos também observavam o início de alguns níveis
antes de terminarem os movimentos das animações de layout. O novo fixture
configura o botão do modo rápido e espera pela posição estável antes de ler
as paredes e calcular a rota. Não se atribui essa corrida ao produto. Estes
ensaios iniciais ficam fora da evidência final de conclusão integral.

```sh
python3 .scratch/pt-pt/functional-mazes/audit_regressions.py
```

Reprodução com `tools/run-native-qml-case.py`, atividade maze para os dois
primeiros casos e mazeinvisible para o terceiro, QML partilhado
`src/activities/maze/Maze.qml`, marcador `NATIVE_MAZE_RESULT`, `--offline` e
saída nova. Os recibos preservam identidade do binário, catálogo, RCC privado,
caso, fonte e snapshot. Não demonstram Windows, toque ou audição física.
