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

A validação interativa completa continua em curso. Este checkpoint não declara
concluídos os níveis de Hangman. Recursos serão recompilados e selados
privadamente; Windows, audição física e aprovação docente permanecem separados.
