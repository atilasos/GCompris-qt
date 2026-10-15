# Palavras e letras — tarefa38

Checkpoint de dados: o auditor independente lê os dois corpora e as1090
traduções PT, sem executar a lógica de correspondência dos jogos. Encontrou
nove palavras com espaços exteriores, incluindo « coruja» e «ilusionista ».
A correção remove apenas esses espaços; acentos, letras e fonemas conservam-se.
`trimmed-spellings.json` fixa os nove pares. `corpus-red.log` e `corpus-green.log`
documentam a falha anterior e a passagem depois da correção.

O conjunto completo possui23 lições e1090 palavras; a amostra incorporada
possui6 lições e116 ocorrências. `corpus.json` conserva a listagem auditada,
carateres, imagens e entradas omitidas por falta de tradução. Os textos são
NFC e não vazios. Hangman ignora diferenças de maiúsculas/minúsculas, exige
acentos exatos, revela os espaços automaticamente e mantém hífen como caráter.
Letra na palavra procura o caráter fonte exato; a capitalização é visual.
Não foi alterada nenhuma destas políticas.

```bash
python3 -m unittest discover -s tests/functional_word_letters -p 'test_*.py' -v
python3 tests/functional_word_letters/corpus.py
```

A matriz completa de Hangman continua em curso. Os recursos foram recompilados
e selados privadamente. Windows, audição física e aprovação docente permanecem
separados. O índice `checkpoint-letter.json` fixa as provas concluídas abaixo.

## Total de níveis publicado

O ensaio nativo `letter-level-count-red` confirmou activity.numberOfLevel=0,
com23 lições carregadas e11 cartões visíveis. O start() calculava maxLevel mas
não o publicava em items.numberOfLevel, que atualiza ActivityBase. A correção
publica esse total; `letter-level-count-green` observa23 e passa. Isto corrige
a informação usada por ActivityBase na decisão de avançar numa sequência;
a prova isolada cobre o contrato público do total, não uma sequência completa.


## Checkpoint interativo de Letra na palavra

`letter-complete/summary.json` fixa174 campanhas aprovadas, com retorno0 do
launcher e do processo Qt. São23 lições completas e6 da amostra incorporada,
cada uma com5/11 cartões e três opções de capitalização. Concluíram1740
perguntas, incluindo resposta vazia incorreta, seleção por setas/Espaço e por
cliques, validação por Enter/OK, pontuação, Bonus e transição final. Os
cartões são aleatórios. A prova cobre um tabuleiro por combinação, sem
pretender esgotar todos os subconjuntos possíveis do corpus.

O auditor Python independente confere cada cartão, texto, frequência da letra,
pertinência das respostas e capitalização. `letter-complete/audit.json` contém
174 resultados sem erros. Os primeiros162 resultados foram preservados. Os12
casos com imagens de números precisaram de corrigir o oráculo da fixture,
pois `zero.webp` corresponde ao áudio `alphabet/U0030.ogg`. As tentativas
iniciais falhadas e as12 retomas estão conservadas, sem atribuir a falha ao jogo.

`full-resource-audit-canonical` verificou na aplicação real a existência das1090
imagens e dos1090 áudios PT pelos caminhos originais do corpus. Esta prova
verifica recursos disponíveis, não a semântica de cada tradução nem audição
física. `linguistic-captures` documenta separadamente as duas correspondências
suspeitas para revisão.

`controls-hangman` e `controls-letter` cobrem navegação, ajuda PT, menu e
reinício depois de alterar opções com cliques reais. `hangman-loss` cobre seis
erros, revelação da palavra, Bonus negativo e Enter para a palavra seguinte.
`hangman-accent-policy` concluiu as20 palavras da lição corporal incorporada e
confirma que c/e/a/i não preenchem posições ç/é/ã/í. Preedit IME não responde;
o commit Unicode responde. A política existente não foi modificada.

## Repetir e retomar

```bash
cmake -S tests/functional_letters/native_input -B build/functional-input
cmake --build build/functional-input
python3 tests/functional_word_letters/prepare.py --base-snapshot SNAPSHOT_BASE --output build/word-resources-new
python3 tests/functional_word_letters/run.py --activity letter-in-word --full-snapshot build/word-resources-new/full-snapshot --sample-snapshot build/word-resources-new/sample-snapshot --output RESULTADOS_NOVOS --jobs 12
python3 tests/functional_word_letters/audit.py RESULTADOS_NOVOS
```

A mesma interface, com `--activity hangman`, executa todas as palavras e quatro
combinações de pistas. `--resume` aceita apenas provas verdes com hashes de
caso, fonte, recursos e relatório coincidentes. JSON com ordem diferente de
chaves não invalida uma prova equivalente. `test_runner.py` verifica essa
retoma por subprocessos normais. Não constitui prova Qt dos jogos.

Cada relatório Qt contém os hashes do binário, catálogo, RCC privado,
recursos selados e caso, além de rede `docker-none`. A campanha Hangman final
copia e sela também as fontes e o adaptador de entrada antes de lançar casos.
O fallback incorporado tem removidos o RCC externo de palavras e o bundle
completo que também fornecia essas imagens. A ausência é verificada na própria
aplicação, sem substituir dados ou pontuação.
