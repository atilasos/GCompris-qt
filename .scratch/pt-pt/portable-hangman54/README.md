# Auditoria portátil de Hangman, tarefa54

O teste CLI vermelho copiou a evidência real para um contentor sem rede que
não contém a worktree histórica. O agregado tentou abrir um caso pelo caminho
absoluto antigo e falhou. `red.log` conserva essa reprodução, sem executar Qt.

O arquivo `../functional-word-letters/sealed-inputs/historical/archive.json`
resolve116 casos já preservados na evidência, duas árvores congeladas completas
e o launcher nativo histórico. Cada árvore inclui CMake, catálogo PO, fontes
de Hangman, qmldir e bytes do adaptador IME compilado. Os bytes foram copiados
da worktree antiga só depois de conferir o digest congelado e os hashes de
cada ficheiro. O launcher coincide com runner_sha256 dos recibos originais.
`archive_inputs.py` regista essa captura única e recusa sobrepor um arquivo.

O agregado usa apenas caminhos relativos ao arquivo e os hashes históricos,
incluindo o corpus capturado. Não reabre row.command nem o launcher atual.
Não foram acrescentados campos ausentes aos recibos antigos. Os caminhos
absolutos nas ordens históricas permanecem como metadados, sem serem seguidos.
Os binários arquivados são dados para verificação de hash, não são carregados
ou executados pela auditoria.

`all-green.log` verifica sete testes. O CLI Docker afirma que a worktree antiga
é inacessível, audita116 campanhas/4824 palavras e volta a passar depois de
remover também os recursos fonte atuais do corpus. Seis adulterações isoladas
são rejeitadas: caso, fonte QML, adaptador IME, manifesto congelado, launcher e
corpus. Mantêm-se a recusa de conjunto incompleto e de recibos duplicados.
Docker reutiliza a imagem local fixada pelo ID, sem descarregar imagens.

`preserved-receipts.json` confirma byte a byte pelo Git e por hash os116
recibos Hangman/4824 palavras e174 Letra na palavra/1740 perguntas. Não houve
novo caso Qt. O agregado portátil fica em aggregate.json; o índice e o agregado
históricos da tarefa38 não foram substituídos. O novo índice54 sela também
todos os ficheiros históricos agora arquivados.

```bash
python3 -m unittest discover -s tests/functional_word_letters -p 'test_*.py' -v
python3 tests/functional_word_letters/aggregate.py .scratch/pt-pt/functional-word-letters/hangman-final .scratch/pt-pt/functional-word-letters/hangman-remaining-full .scratch/pt-pt/functional-word-letters/hangman-remaining-sample
```

O comando aceita as três pastas copiadas para outro diretório, mantendo o
respetivo corpus.json e sealed-inputs. Os testes Docker exigem o motor local;
a auditoria normal usa apenas Python. Windows, audição e aprovação docente
não são ampliados por esta correção operacional.
