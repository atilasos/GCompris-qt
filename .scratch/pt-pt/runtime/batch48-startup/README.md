# Arranque após as correções dos jogos de desenho

Os quatro jogos number_sequence, clickanddraw, drawletters e drawnumbers
passaram seis segundos cada, com perfis novos PT-PT e Docker sem rede.
Sem erros QML detetados. O RCC core e o RCC drawletters do build principal
foram reconstruídos com a aplicação principal parada. As campanhas nativas
longas usam cópias privadas e não foram afetadas.

```sh
cmake --build build/pt-pt --target rcc_core rcc_drawletters --parallel 2
python3 tools/smoke-activity.py --binary build/pt-pt/bin/gcompris-qt \
 --output .scratch/pt-pt/runtime/batch48-startup --source-root . \
 --seconds 6 --offline number_sequence clickanddraw drawletters drawnumbers
```

Os JSON/logs originais registam hashes e resultados. Este ensaio verifica só
arranque, sem concluir puzzles, audição, hardware ou Windows.
