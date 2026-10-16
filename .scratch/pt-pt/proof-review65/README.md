# Revisão65: retornos externos e fontes históricas

Foram corrigidos os três P2 de Standards60–63 sem executar Qt nem alterar
produção. `preserved-originals.json` confere cada blob original dos três
arquivos contra Git9750a053a: os recibos, casos, screenshots, manifestos,
fontes e índices originais permanecem byte a byte. Os novos ficheiros são
complementos separados, não novos recibos nativos.

## Retornos de calendários e dinheiro

Os autores recuperaram as respostas efetivas de `exec`/`write_stdin` retidas
nos rollouts locais. As observações são explicitamente retrospetivas; não são
sidecars emitidos na altura, não usam `result.json.exit_code` como retorno do
lançador e não atestam execuções futuras.

- Calendários: `functional-calendars/supervisor-observations.json` conserva a
  declaração original SHA5802b004…; `supervisor-observations-rollout.json`,
  SHA492ad2ef…, acrescenta os registos brutos de32 eventos e liga14 outcomes
  a sessões, chamadas, blocos e hashes de recibo/caso. Os grupos distinguem
  o retorno do coordenador dos valores individuais impressos depois de wait.
  Há dez lançadores0 e quatro negativos esperados1.
- Dinheiro: `functional-money/supervisor-observations.json`, SHAf4c1c16f…,
  liga18 outcomes a respostas reais com sessão, ordinal, timestamp, chunk e
  hashes de recibo/caso. Há quinze lançadores0 e três negativos esperados1.
  Os12 casos de campanha/controlos propagavam o retorno do lançador no wrapper
  histórico, confirmado pelo blob Git documentado no próprio ficheiro.

Os hashes completos ficam fixados no código dos auditores, fora do arquivo
modificável. Os auditores exigem o outcome esperado e a ligação aos bytes de
recibo e caso. Alterar a declaração de observações é rejeitado. Não se presume
que o processo tenha terminado apenas por existir um JSON verde.

O indexador de dinheiro verifica a conclusão antes de escrever o índice. Em
novos resultados usa o sidecar; só para os casos históricos exatos admite as
observações retrospetivas fixadas. O auditor histórico exige ainda essas
observações originais e rejeita também um sidecar adicional com retorno errado.
Os índices antigos não foram regenerados: os complementos têm âncoras próprias.

## Supervisor para novas execuções

`tools/run-native-qml-supervised.py` aceita os argumentos do lançador nativo e
`--launcher PATH` opcional para selecionar uma cópia histórica. Exige uma pasta
de saída nova; os logs do parent devem ficar fora dela enquanto o filho corre.
Espera o filho com `subprocess.run` e só depois grava `launcher-status.json`:

```json
{"format":1,"kind":"observed-subprocess-exit","exit_code":0,
 "native_receipt_sha256":"SHA256","case_sha256":"SHA256",
 "launcher_sha256":"SHA256"}
```

O retorno do wrapper é o retorno real do filho, mesmo se o JSON nativo disser
passed=true. Sem recibo, o campo correspondente é null; um auditor não o aceita
como prova concluída. Se o filho não criar a pasta, não é inventada uma prova.
`tools/native_qml_supervision.py` confere o sidecar contra os ficheiros exatos,
o caso e o lançador identificados pelo recibo, e o retorno esperado.

O runner de dinheiro passa agora por esse supervisor, preservando a escolha
do lançador histórico. Para novas execuções de calendários e outros casos:

```bash
python3 tools/run-native-qml-supervised.py --launcher HISTORICAL/tools/run-native-qml-case.py --source-root HISTORICAL --resource-snapshot SNAPSHOT --activity ACTIVITY --qml-file HISTORICAL/src/activities/PAGE.qml --case CASE.qml --output NEW_OUTPUT --offline
```

O auditor de calendários ganhou `--evidence PATH --check-only`, para conferir
uma cópia pela CLI sem reescrever o seu índice. Para dinheiro, o indexador
aceita `--evidence PATH`; uma falha externa é rejeitada antes de gravar.

## Âncoras de verticais

O auditor fixa os SHA256 dos manifestos de baseline, green e complete
provenientes do commit de prova1b7ac42cb. Exige a lista exata de ficheiros e os
seus bytes, sem symlinks; cada recibo continua ligado à fase própria. Um ataque
que altera PO e QML, os seus manifestos, ligações, hashes nativos e índice de
forma coerente é rejeitado pela raiz independente do arquivo. O teste portátil
continua sem depender de Git ou dos caminhos da worktree histórica.

## Verificação

38 testes passaram:13 calendários,14 dinheiro,9 verticais e2 supervisor.
Os logs guardam os vermelhos dos três achados e os verdes. As regressões de
CLI usam subprocessos normais para JSON verde com retorno externo1; não causam
crashes Qt. O indexador conserva o índice existente perante essa falha.
A cópia portátil de verticais e as cópias independentes de dinheiro/calendários
permanecem válidas, incluindo rejeição das adulterações anteriores.

Os limites dos lotes originais mantêm-se: Linux/software; Windows, dispositivos,
audição e aprovação docente pendentes. Não houve nova validação funcional de
jogos, nenhuma campanha foi repetida e a contagem de cobertura não aumentou.
