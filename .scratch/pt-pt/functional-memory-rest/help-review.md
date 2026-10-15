# Correções parciais da ajuda de memória (tarefa 37)

O manual de imagens dizia «uma carta de cada vez», apesar de o jogo permitir
as duas cartas necessárias ao par. O manual de sons tinha «as gémeos».
Corrigidos para «duas cartas» e «fazer corresponder os gémeos», preservando
os restantes textos e regras.

A mesma asserção Qt sobre a ajuda visível falhou antes da correção em memory
e memory-sound (`help-red`) e passou depois nas cinco variantes (`help-green`).
`help-review.json` identifica os resultados e SHA-256. Cada resultado contém
os hashes do executável, snapshot privado, catálogo compilado e caso realmente
executado. Os casos também exercitam os botões de nível, fechar ajuda e Home.

Reprodução de um caso (diretório de saída novo; snapshot independente obrigatório):

```sh
python3 tools/run-native-qml-case.py --source-root . \
  --resource-snapshot /CAMINHO/SNAPSHOT --activity memory \
  --qml-file src/activities/memory/MemoryCommon.qml \
  --case tests/functional_memory_rest/controls.qml --output /CAMINHO/SAIDA \
  --timeout 40 --result-marker NATIVE_MEMORY_RESULT --offline
```

Esta fatia não conclui a tarefa 37: os percursos completos, sons e regressões
continuam em validação. Não certifica Windows, dispositivos físicos ou revisão
docente da totalidade da aplicação.
