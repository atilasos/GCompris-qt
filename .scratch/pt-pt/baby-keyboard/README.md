# O meu primeiro teclado

Esta atividade é exploração livre, sem níveis ou pontuação. Passaram 208 entradas
por eventos Qt: 172 letras/dígitos/caracteres portugueses com preferências de
teclado visual desligado/ligado, mais 36 botões visuais A–Z/0–9. A entrada
acentuada usa o adaptador IME já usado nos jogos de letras, sem chamar métodos
do jogo. Cada resposta verifica o glifo maiúsculo e a rota portuguesa solicitada.
Os controlos visuais Retroceder/Enter limpam a apresentação; Espaço é mostrado.

O ensaio final também observa o MediaPlayer original dentro de GCAudio.
Para ç, houve PlayingState, posição 23 ms, duração 835 ms e hasAudio verdadeiro,
seguido de done. Não se substitui o player nem se simula áudio. As 208 rotas
são verificadas, mas não se afirma que cada clip foi ouvido fisicamente.
A descodificação do inventário completo foi verificada na tarefa 05; a audição
das 32 novas gravações foi aprovada pelo professor na tarefa 35.

A ajuda PT passou com teclado visual desligado e ligado. Após fechar a ajuda
e clicar no fundo, as teclas físicas voltam a produzir letras sem atribuir
foco no teste. O botão Início regressa ao menu real. Dois percursos passaram.
Não houve alteração de produção.

Limites: o teclado visual existente expõe A–Z e dígitos, sem linha acentuada.
Os caracteres portugueses são testados pela entrada física/IME. Windows,
dispositivos físicos e aceitação docente global permanecem pendentes.

Reprodução na raiz, com Qt6 de desenvolvimento e recursos offline:

```bash
cmake -S tests/functional_letters/native_input -B build/functional-input
cmake --build build/functional-input --parallel 2
python3 tools/run-native-qml-case.py --source-root . --binary /build/bin/gcompris-qt \
  --activity baby_keyboard --qml-file src/activities/baby_keyboard/Baby_keyboard.qml \
  --case tests/baby_keyboard.qml --output /novo/resultado --timeout 180 \
  --result-marker NATIVE_BABY_KEYBOARD_RESULT --offline
```

Para ajuda/foco/menu, usar tests/baby_keyboard_controls.qml. Os resultados e
respetivos hashes estão em index.json. gameplay é a primeira prova de rotas;
gameplay-player acrescenta a observação real da descodificação.
