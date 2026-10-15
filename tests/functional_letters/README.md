# Testes funcionais nativos de letras PT-PT

Estes casos são injetados pelo launcher em cópias privadas dos RCC e executados
pela aplicação Qt real. Usam TextInput, FallingWord, GridView/Carriage, Score,
ErrorRectangle e Bonus originais. Nenhuma resposta ou pontuação é atribuída pelo
teste e nenhuma função de validação do jogo é substituída.

## Executar

Com a aplicação já compilada e os recursos offline presentes:

```bash
python3 tests/functional_letters/run.py \
  --binary build/pt-pt/bin/gcompris-qt \
  --output .scratch/pt-pt/functional-letters/nova-execucao
```

O diretório de saída deve ser novo. A execução completa pode demorar cerca de
quinze minutos porque espera as animações reais. `--suite gameplay`, `controls`,
`navigation`, `audio` ou `speed` permite repetir uma área. O launcher exige a
imagem Docker de verificação já disponível e executa os processos sem rede,
com perfis novos, dados locais e o sistema de ficheiros de origem só para leitura.
O build principal não é escrito.

O script compila apenas o adaptador de entrada de teste em `build/functional-input`.
Depois executa quinze casos nativos, em paralelo até ao limite `--workers`.
`summary.json` identifica resultados e hashes do adaptador; cada caso guarda o
log, hashes de QML/RCC/binário/launcher, resultado e capturas aplicáveis.

## Casos

- `gletters.qml`: completa os 13 níveis nos modos misto e apenas maiúsculas;
  testa rejeições, igualdade de maiúsculas/minúsculas, acentos e cedilha,
  transições automáticas e uma resposta na velocidade mínima.
- `keyboard_training.qml`: completa os 13 níveis nos modos de maiúsculas e
  minúsculas, com as animações, erros e transições originais; verifica caracteres
  portugueses e rejeição de respostas sem o acento pedido.
- `click_on_letter.qml`: completa os 11 níveis de cada variante, alternando
  cliques e navegação por setas/espaço, com uma resposta errada por nível.
- `click_navigation.qml`: seleciona a última das 11 respostas do nível 3, muda
  pelo botão real para o nível 4, que tem oito, e verifica a seleção por Espaço.
- `controls.qml`: usa botões reais para anterior/próximo, abre a ajuda em PT,
  regressa à atividade e ao menu. Aguarda a geometria da barra após mudar de nível.
- `audio_route.qml`: ativa vozes, verifica a apresentação da pergunta falada ou
  a resposta escrita e observa o sinal real `done`. Não certifica saída de som.
- `speed.qml`: exercita entrada certa/errada em todas as dez velocidades e confirma
  que aumentar a velocidade torna os lançamentos mais frequentes.

Os modos são fixtures aplicados às propriedades de configuração e ao ciclo
normal stop/start. Isto não afirma testar cada interação do diálogo de opções.
As respostas são sempre entregues pelos eventos nativos do teclado/rato ou IME.

## Caracteres compostos

QtTest `keyClick(char)` aceita apenas o mapeamento ASCII e aborta em `qasciikey.cpp`
quando recebe letras como ã. O adaptador de teste `native_input` entrega eventos
Qt `QInputMethodEvent` de pré-edição e confirmação ao TextInput original. O teste
confirma que a pré-edição não é uma resposta e que o commit segue o handler normal.
Não chama processKeyPress nem escreve diretamente no texto/pontuação do jogo.
O self-test verifica os 24 caracteres portugueses, em ambos os casos, num
TextInput real que limpa o texto como as atividades fazem.

Isto prova o tratamento do texto composto. Não emula o mapa físico de um teclado
português nem substitui a verificação das teclas mortas no computador real.

## Limites

A cobertura destes casos é distinta da aceitação global Linux, Windows e escola.
As execuções headless não têm dispositivo físico de áudio. O sinal de fim da fila
e a existência/descodificação de ficheiros não certificam audição ou pronúncia.
A revisão linguística e pedagógica do professor e a execução Windows 10 x64
mantêm-se pendentes. Os resultados de execução estão em
`.scratch/pt-pt/functional-letters/README.md` e nos documentos por atividade.
