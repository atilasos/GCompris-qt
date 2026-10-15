# Corrigir os recursos offline em /tmp

A revisão Standards de `1ac947fbc...fb787df936` identificou um P2 no launcher.
O deployment acompanha a saída, mas o tmpfs de `/host/tmp` escondia os seus
ficheiros quando a saída ficava em `/tmp`. Um snapshot externo em `/tmp` também
ficava escondido, mesmo que o executável estivesse noutro local.

A correção acrescenta bind mounts só de leitura para deployment e snapshot.
Os mounts de perfil e saída continuam privados e com escrita, e a raiz do host
continua só para leitura. A rede mantém-se desativada. O GNU chroot conserva
`--userspec` com o UID/GID local. O snapshot externo tem mount próprio, mesmo
quando não está dentro do deployment.

## Reproduzir

Na checkout com a correção:

```bash
PYTHONDONTWRITEBYTECODE=1 python3 tests/native_qml_resources/check_tmp_offline.py \
  --binary /home/proteu/Projetos/GCompris-qt/build/pt-pt/bin/gcompris-qt \
  --output .scratch/pt-pt/review/tmp-resources/nova-execucao
```

O verificador usa `click_navigation.qml`, nível inicial 3, Qt real e duas
configurações. A saída com snapshot automático fica em `/tmp`; a outra saída
fica na pasta indicada, usando um snapshot externo em `/tmp`. O resultado exige
sucesso do caso, dono local e remoção normal de cada deployment. Os ficheiros
temporários só são removidos automaticamente após sucesso global.

## Evidência

Antes da correção, ambos os casos falharam. O automático não encontrou o
executável em `/tmp/.../bin/gcompris-qt`. No externo, o binário arrancou mas Qt
não encontrou os recursos, incluindo `LanguageList.qml`. Os resultados e um
excerto inicial de cada log estão em `red/`. `red/logs.json` identifica hashes,
tamanhos e contagens dos logs originais antes de os reduzir a 25 linhas.

Com os mounts RO, ambos os casos passaram, cada um com 2 passes e 0 falhas,
código 0, sem timeout e sem erros QML. Os resultados e logs completos estão em
`green/`. UID/GID 1000:1000 verificados e ambos os deployments removidos pelo
launcher. O verificador removeu também a sua pasta temporária. Nenhum erro de
limpeza foi ocultado. Os artefactos temporários da reprodução inicial foram
removidos depois de guardar a evidência.

A imagem efetiva foi
`sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b`.
O teste usou o build existente apenas para leitura; não houve compilação nem
alteração do build principal. Os quatro unitários de `test_native_qml_resources.py`
passaram. Este ensaio cobre os mounts e o caso de navegação normal, sem testes
de sinais, memória ou ausência global de falhas.
