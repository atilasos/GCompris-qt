# Arranque após as correções38,41 e43

baby_wordprocessor, baby_mouse, clickgame e hangman passaram seis segundos
cada em pt_PT, perfis novos e Docker sem rede, sem erros QML detetados.
O build principal teve RCC/QM afetados reconstruídos com a aplicação principal
parada. Os restantes ensaios decorriam em cópias privadas. `run.json` conserva
hashes de fonte/build/runner/configuração; os logs e results.json são originais.

Comando:

```sh
python3 tools/smoke-activity.py --binary build/pt-pt/bin/gcompris-qt \
 --output .scratch/pt-pt/runtime/batch43-startup --source-root . \
 --seconds 6 --offline baby_wordprocessor baby_mouse clickgame hangman
```

Este teste só verifica arranque. Não conclui puzzles, audição, hardware ou Windows.
