# Contador de Hangman ao mudar para uma lição menor

O mesmo caso Qt completa as95 palavras da lição2, por cliques/teclas/IME reais,
sem atribuir resposta, contador ou fase. Aguarda o Timer/Bonus e confirma o
avanço natural para a lição3, que tem39 palavras.

Antes, a última asserção obtinha95 em vez de1 para score.currentSubLevel.
A implementação mudava numberOfSubLevels para39 mas conservava o contador95;
initSubLevel só o atualizava se o valor anterior fosse menor que o novo limite.
O ramo contrário também ocultava a pontuação. Quatro combinações de pistas
reproduziram o mesmo problema; a prova isolada fixa um desses casos.

A correção reinicia o contador em initLevel antes da primeira palavra da nova
lição. Depois, o mesmo caso concluiu95/95 palavras e verificou o contador1 na
lição3, com zero falhas. Os hashes do caso e snapshot são iguais entre vermelho
e verde; index.json conserva também os hashes de JS e relatórios.

Reprodução num checkout com snapshot selado e adaptador Unicode compilado:

```bash
python3 tools/run-native-qml-case.py --resource-snapshot build/current-lang/full-snapshot --activity hangman --qml-file src/activities/hangman/Hangman.qml --case .scratch/pt-pt/functional-word-letters/hangman-counter-fix/case.qml --start-level 2 --output /tmp/hangman-counter-new --timeout 1250 --offline
```

Esta fatia prova a regressão de transição; não declara concluída a matriz
integral38. O primeiro lote de baseline foi interrompido ao identificar o bug;
resultados parciais e campanhas interrompidas não contam como níveis completos.
