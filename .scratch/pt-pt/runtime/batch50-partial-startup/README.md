# Arranque dos labirintos após três correções

maze, mazeinvisible e mazerelative passaram seis segundos cada em perfis
novos PT-PT, Docker sem rede e sem erros QML detetados. O RCC maze do build
principal foi reconstruído com a aplicação principal parada. As campanhas
longas da tarefa50 decorrem em cópias privadas, sem dependência operacional
deste build. Este ensaio só verifica arranque, não conclusão dos níveis.

```sh
cmake --build build/pt-pt --target rcc_maze --parallel 2
python3 tools/smoke-activity.py --binary build/pt-pt/bin/gcompris-qt \
 --output .scratch/pt-pt/runtime/batch50-partial-startup --source-root . \
 --seconds 6 --offline maze mazeinvisible mazerelative
```

Os JSON e logs são originais. Windows, hardware e docente continuam pendentes.
