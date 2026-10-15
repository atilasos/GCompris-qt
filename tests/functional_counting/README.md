# Contagem nativa, tarefa 46

O runner completa os jogos por eventos Qt reais. Requer Python 3, Qt 6,
Docker e o launcher/snapshot da tarefa 25. Não modifica o build principal.

```sh
python3 tools/native_qml_resources.py --binary /caminho/bin/gcompris-qt --output build/counting-origin
python3 tests/functional_counting/prepare.py --origin-snapshot build/counting-origin --output build/counting-current
python3 -m unittest discover -s tests/functional_counting -v
python3 tests/functional_counting/run.py --activity enumerate --validation automatic --resource-snapshot build/counting-current --output build/counting-auto
python3 tests/functional_counting/run.py --activity enumerate --validation ok --resource-snapshot build/counting-current --output build/counting-ok
python3 tests/functional_counting/run.py --activity smallnumbers --resource-snapshot build/counting-current --output build/counting-dice
python3 tests/functional_counting/run.py --activity smallnumbers2 --resource-snapshot build/counting-current --output build/counting-domino
```

Para cada atividade, executar também `--case controls` e `--case selectors`
com uma saída nova. `--levels 3 --physical-only` é um tracer separado de três
níveis por modo, sem teclado visual. A opção `--representation` permite um
modo isolado de dominó. Sem essas opções, o percurso completa todos os níveis
e todas as quatro representações. Não executa o produto cartesiano das dez
velocidades com todos os puzzles. Controls opera as dez velocidades pela UI,
confirma persistência e movimento, espera uma perda natural e recupera.

`inventory.py` inventaria os datasets e conta os pontos da face superior nos
SVG dos dados. `rendered.fragment` lê os elementos visíveis do dominó, sem
consultar valores ocultos. `audit.py` volta a contar os objetos e lados
observados; `collect.py --evidence .scratch/pt-pt/functional-counting` verifica
os recibos completos e sela os ficheiros. Os casos exatos ficam em cada pasta,
mesmo quando foram gerados antes da última organização dos fragments.

Para verificar os bytes de um RCC, compilar privadamente
`tools/pt-pt-audio/rcc_inventory.cpp` com Qt6Core e comparar os SHA das rotas
`:/gcompris/` com os ficheiros de origem. `source-identity.json` conserva essa
comparação para os cinco RCC da campanha. Nenhum recurso da cópia selada é
um symlink para um build mutável.

O caso `panel-drag.qml` aceita `__WAIT_FOR_PANEL__` false/true e o fragment de
UI. O vermelho demonstra que a animação de ocultação pode ainda intercetar a
pressão. O verde espera opacity=0 antes de iniciar o arrasto. Esta é uma
correção do teste, sem alteração de produção.

Som, dispositivos físicos, touch/mobile, Windows e aprovação docente continuam
fora desta validação. Relatório e limites completos na pasta de provas.
