# Revisão: rejeitar omissões de acentos em gletters

A revisão identificou uma descrição excessiva: o caso inicial de gletters
comprovava entrada acentuada correta e rejeição de caso, mas não omissão de
acentos/cedilha. A evidência inicial fica intacta no índice e no diretório run3.

## Red e green nativos

Foi acrescentada ao caso anterior uma asserção que exige rejeições das doze
formas `àáâãéêíóôõúç` em cada modo. A [execução red](review-accent-red/result.json)
completou os 26 percursos mas falhou a asserção, com os dois conjuntos de
rejeições vazios. O [caso dessa etapa](review-accent-red/case-before-probes.qml)
é conservado com o hash registado pelo launcher. Trata-se da falta de cobertura,
não de um erro de produção.

O caso atual envia pares de grafia explícitos (`à→a`, `á→a`, …, `ç→c`) pelo
teclado real, apenas quando nenhuma outra letra ativa poderia aceitar a forma
sem acento. Confirma que a pontuação não avança e que o alvo ainda não foi
resolvido; depois submete a forma correta. Exige as doze rejeições nos dois modos.

A [execução green](review-accent-green/result.json) passou os 26 percursos com
**425 respostas certas e 252 erradas**, incluindo as **24 novas rejeições**.
O log regista alvo, tecla sem acento, modo, nível e pontuação de cada tentativa.
O self-test do adaptador IME voltou a passar (3 entradas QtTest, sem falhas). Sete testes Node passaram.

Os [hashes e as contagens](review-accent-index.json) identificam a nova evidência.
O composto por atividade passa de 1 037/282 para
1 037/306 respostas certas/erradas e mantém 74 percursos.
Isto combina o novo gletters com a evidência histórica dos restantes casos;
não afirma que os quinze casos foram todos repetidos nesta revisão.

## Reproduzir e limites

Executar o launcher estável do checkout atual, após compilar o adaptador pelo
[procedimento existente](../../../tests/functional_letters/README.md):

```bash
python3 tools/run-native-qml-case.py --source-root . \
  --binary /caminho/para/gcompris-qt --activity gletters \
  --qml-file src/activities/gletters/Gletters.qml \
  --case tests/functional_letters/gletters.qml \
  --output /novo/diretorio --timeout 300 \
  --result-marker NATIVE_LETTERS_RESULT --offline
```

Nenhuma função de produção foi alterada. A sequência pequena de entrada mantém-se
local aos dois fragmentos injetados: depende dos IDs lexicais e das asserções do
caso; uma extração exigiria passar estes contextos ou alterar o launcher. O plugin
IME já é comum e testado. A decisão está documentada no README dos testes.

Windows, teclado físico português/teclas mortas, audição, aceitação global Linux
e revisão docente mantêm-se pendentes.
