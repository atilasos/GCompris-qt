# Verificar memória matemática em Qt real

```sh
node --test tests/functional_memory_math/data.test.mjs
python3 tests/functional_memory_math/run.py --binary /caminho/bin/gcompris-qt \
  --output .scratch/pt-pt/functional-memory-math/replay
```

Requer Qt 6 com QtTest, rcc, lconvert, lrelease, Docker com a imagem offline já
instalada e GNU chroot. O runner recompila os catorze RCC das variantes, memory e
core num diretório privado e cria uma cópia integral selada. Cada processo usa
perfil novo em PT-PT e `--network none`. A aplicação real e os seus timers fazem
o jogo; não há alteração de RNG nativo, matchCode, pontuação ou duração.

Pode selecionar `--case gameplay|controls|keyboard_home|restart`, `--activity ID`
repetido e `--jobs N`. Para repetir apenas casos sobre um snapshot próprio já
construído, passe `--snapshot DIRETÓRIO` juntamente com `--binary` dessa cópia.
Os resultados contêm os hashes do manifesto, dados, QM, caso e binário.

## Dados e respostas

O teste Node executa `math_util.js` original numa VM que só adapta Qt/tradução e
shuffle na fronteira. Inspeciona todas as 138 definições Data.qml e os níveis
de ActivityInfo. Valida quantidade, unicidade, operadores, todas as respostas e
ambas as ordens de operandos. Um teste de sensibilidade rejeita uma resposta
errada e outra com resultados duplicados.

O oráculo usa contagem de unidades para somas/produtos e relações inversas para
subtrações/divisões. O caso Qt usa o mesmo princípio independente do gerador.
Lê o texto das cartas e agrupa conta/numeral pelo seu significado. Não lê os
códigos de correspondência do motor. Verifica também todas as contas geradas
nos datasets carregados, para além dos cinco pares sorteados por tabuleiro.

## Interação

`gameplay.qml` carrega todas as tabelas pelo mecanismo original levelFolder e
percorre os modos de um/dois jogadores ou o modo contra Tux, conforme a variante.
Usa rato e teclas reais. Verifica erros, atraso de exposição, terceiro clique
bloqueado, cartas encontradas desativadas, pontuação, turno, Bonus e avanço com
regresso ao primeiro nível. No modo de dois jogadores, ambos pontuam/vencem.

Contra Tux, os cliques e Espaço ficam bloqueados durante o turno automático.
Os pontos são confrontados com as cartas realmente encontradas. Uma vitória do
Tux por erros deliberados do jogador deve emitir Bonus negativo e repetir o
mesmo nível, sem atribuir pontos nem chamar diretamente as respostas do motor.

`controls.qml` usa botões reais anterior/próximo, ajuda PT, fechar e menu.
`keyboard_home.qml` verifica Escape. `restart.qml` testa as quatro setas e
reinício com carta aberta, esperando mais que o timer original de 1500 ms.
Nos perfis novos, Enter confirma a configuração inicial quando esta é exibida.
A seleção completa das tabelas e playerCount usam fixtures pelo ciclo normal
stop/start. Não são gestos exaustivos do seletor de tabelas/opções.

O lote só aprova as ações indicadas. Teclado/rato físicos, som/pronúncia,
Windows 10 x64, escola e revisão docente continuam por validar separadamente.
