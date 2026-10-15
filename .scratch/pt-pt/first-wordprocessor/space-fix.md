# Espaço no teclado visual do processador de texto

O teclado emitia um espaço, mas TextEdit.insert interpretava-o como um fragmento
HTML e descartava-o. O caso mínimo usa cliques reais em a/Espaço e observa o
sinal original. `space-red/result.json` conserva a emissão de um espaço, texto
«a» e comprimento1; `space-green/result.json` conserva a mesma emissão, texto
«a » e comprimento2. Os dois casos têm o mesmo SHA256.

A inserção de texto visual passa a escapar &/</> e a envolver o fragmento num
span com white-space: pre-wrap. Preserva espaços sem substituir o documento
formatado nem usar espaços não separáveis. O Qt devolve U+0020 no resultado.
O teclado físico e a quebra de linha mantêm os caminhos existentes.

`typing-green/result.json` verifica ambas as preferências do teclado: caracteres
portugueses, três formatos preservando o texto e alturas58/47/39, retrocesso,
Enter visual, dois espaços consecutivos e dígitos. Não houve falhas. Os hashes
de fonte, caso, recursos privados, binário e QM estão nos JSON.

Comando de reprodução do caso mínimo, na raiz com Qt6 e recursos locais:

```sh
python3 tools/run-native-qml-case.py --source-root . \
 --binary /home/proteu/Projetos/GCompris-qt/build/pt-pt/bin/gcompris-qt \
 --activity baby_wordprocessor \
 --qml-file src/activities/baby_wordprocessor/BabyWordprocessor.qml \
 --case tests/wordprocessor_space.qml \
 --output /novo/resultado --timeout 45 \
 --result-marker NATIVE_WORDPROCESSOR_RESULT --offline
```

A tarefa41 permanece claimed: guardar/carregar, configurações de áudio, ajuda,
reinício, navegação e restante teclado ainda estão em verificação. Isto não
conclui a atividade nem aprova dispositivos físicos ou Windows.
