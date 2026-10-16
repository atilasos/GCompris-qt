# Primeiro processador de texto

Exploração livre, sem níveis. Quatro casos finais passaram no Qt original,
PT-PT, com perfis novos, recursos privados e rede Docker desligada. O índice
liga os resultados e hashes. Não foram substituídos o editor, os ficheiros ou
o MediaPlayer por mocks.

- `typing-final`: entrada física/IME, incluindo12 caracteres portugueses em
  minúsculas/maiúsculas, com teclado visual desligado/ligado. Título, subtítulo
  e parágrafo preservam o texto e produzem alturas58/47/39. O teclado visual
  cobre52 letras com Shift,10 dígitos, espaços consecutivos, Enter e retrocesso.
- `creation-settled`: guardar «Texto do João», confirmação pela interface,
  reiniciar, selecionar/carregar o ficheiro. Texto e HTML formatado sobrevivem
  exatamente; a entrada física funciona após fechar o diálogo sem forçar foco.
- `controls`: configuração áudio desligado→ligado→desligado por cliques e
  gravação persistida. A letra ç só pede áudio quando ativado. O MediaPlayer
  original mostra posição58ms, duração835ms e hasAudio, seguido de done.
  Ajuda PT e recuperação do foco passam nos três ciclos; Início abre o menu.
- `space-green`: regressão do espaço visual, com o mesmo caso do vermelho.

## Correções

O editor interpretava a tecla Espaço como fragmento HTML e descartava-a. A
inserção passa a preservar espaços U+0020 com pre-wrap e escape HTML. A prova
mínima e o diagnóstico estão em [space-fix.md](space-fix.md).

O botão e a ajuda usavam «Sub-Título». Ambos usam agora «Subtítulo».
`labels-red` conserva a grafia anterior rejeitada pelo caso de controlos;
`controls` passa com a mesma fonte do caso e o catálogo corrigido.

## Reprodução

```sh
cmake -S tests/functional_letters/native_input -B build/functional-input
cmake --build build/functional-input --parallel 2
python3 tools/run-native-qml-case.py --source-root . \
 --binary /home/proteu/Projetos/GCompris-qt/build/pt-pt/bin/gcompris-qt \
 --activity baby_wordprocessor \
 --qml-file src/activities/baby_wordprocessor/BabyWordprocessor.qml \
 --case tests/first_wordprocessor.qml --output /novo/resultado --timeout 120 \
 --result-marker NATIVE_WORDPROCESSOR_RESULT --offline
```

Repetir para tests/wordprocessor_creation.qml, wordprocessor_controls.qml e
wordprocessor_space.qml, sempre com diretórios de saída novos. Os JSON guardam
hashes de fonte, caso, binário, RCC, catálogo/QM e cópia privada de recursos.

A primeira prova de guardar/carregar clicava em OK durante a animação do aviso;
`creation` é diagnóstico, não aprovação. `creation-settled` aguarda o fim da
animação e passa sem mudança de produção. Os primeiros `typing` e
`typing-diagnostic` conservam a falha de espaços, resolvida no caso final.
Apenas os quatro resultados do índice são evidência positiva final.

Pendente: orientação vertical, dispositivos físicos, audição por altifalante,
Windows e aceitação docente global. A observação sonora é da letra ç; não se
afirma audição individual das26 letras. A aprovação das32 novas gravações
pertence à tarefa35 e não equivale a aprovação integral desta atividade.
