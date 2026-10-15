# Contrato público dos níveis do Solitário

A contagem privada era quatro, mas ActivityBase anunciava zero níveis e não
acompanhava o nível atual. Dois handlers publicam as alterações já calculadas
pelo motor. A correção permite que os consumidores dos metadados, incluindo
as sequências, recebam a contagem e o índice atuais.

## Prova nativa offline

`tests/solitaire_levels.qml` percorre os quatro tabuleiros para a frente e para
trás através dos botões reais. Compara o índice público com o privado a cada
passo e regista as descrições portuguesas. Usa perfil novo, Qt real e uma cópia
privada dos recursos, com rede Docker desativada.

- `baseline/result.json`: falha, dois testes rejeitados; contagem pública zero.
- `green/result.json`: passa, zero falhas; contagem pública quatro, oito transições.
- Cada JSON conserva hashes do caso, fonte, QM, RCC, binário e recursos; os logs
  adjacentes conservam a saída nativa. O launcher terminou com código zero no verde.

Comando, executado antes e depois dos dois handlers, alterando apenas o output:

```sh
python3 tools/run-native-qml-case.py --source-root . \
  --binary /home/proteu/Projetos/GCompris-qt/build/pt-pt/bin/gcompris-qt \
  --activity peg_solitaire --qml-file src/activities/peg_solitaire/PegSolitaire.qml \
  --case tests/solitaire_levels.qml \
  --output .scratch/pt-pt/solitaire-levels/green --timeout 40 \
  --result-marker NATIVE_SOLITAIRE_LEVELS_RESULT --offline
```

Esta prova verifica exclusivamente o contrato de níveis. Não resolve os
puzzles, não verifica todas as aberturas e não aprova Windows ou áudio físico.
A atividade continua pendente na matriz global.
