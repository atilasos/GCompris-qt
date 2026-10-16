# Preparação concorrente das fontes — tarefa 72

A reprodução `red.log` usa um repositório Git temporário real e suspende a
primeira escrita depois da abertura do ficheiro. A implementação anterior
permitia ao segundo leitor observar bytes vazios. Uma interrupção também
publicava uma pasta incompleta. `campaign-red.log` conserva a falha separada
da fronteira CLI: os workers recebiam `HEAD`, sem preparação prévia.

`freeze()` agora escreve cada árvore numa pasta temporária privada e publica
por rename apenas a árvore completa, com manifesto. Um concorrente que perde
a publicação valida os bytes e manifesto do vencedor contra Git. Uma árvore
publicada corrompida é rejeitada, sem a voltar a selar. Uma falha de preparação
não publica a árvore final e permite nova tentativa. As campanhas preparam
antes do pool e passam o commit resolvido aos workers.

Verificação sem Qt:

```
python3 -m unittest discover -s tests/functional_graduated -v
python3 tests/functional_graduated/audit.py
```

`green.log`: 16 testes passaram (12 existentes e quatro novos). A fixture da
campanha lança dez subprocessos Python normais, com seis workers; não simula
um resultado Qt. O auditor puro em `audit.json` mantém os 22 recibos, 574
questões e restantes contagens históricas.

`preserved.json` compara os 307 ficheiros históricos indicados com os blobs
Git de `de2ff968f68fb54cbff3a2e5161474befaad3a0f`: arquivo das retas, provas
de verificação anteriores e catálogo PT. Todos permanecem byte a byte iguais,
incluindo os manifestos, casos, recursos e recibos. Não foram repetidas
campanhas Qt nem alterados recursos de produção. Isto corrige ferramentas de
preparação futura; os limites Windows, equipamento, áudio e docente mantêm-se.
