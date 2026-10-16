# Orientação espacial e rato — tarefa 76

Concluídas 80 tarefas primárias em Qt real offline: 32 fotografias/rotações das
mãos em seis níveis, 26 relações em quatro níveis de posições (dois datasets,
cada um nos modos texto→imagem e imagem→texto) e 22 animais em três níveis de
rato. Há 13 erros reparados e 13 conclusões naturais de nível por Score/Bonus;
o jogo do rato não apresenta Score, sendo a chegada de todos os animais e o
Bonus os indicadores usados. Não se esgotam todas as permutações aleatórias
de estímulos e respostas.

## Oráculos e eventos

As oito fotos foram inspecionadas individualmente: palma/dorso, polegar e
orientação anatómica, com o pulso à esquerda e os dedos à direita nas fotos
originais. `hand-semantics.json` liga esta anotação aos bytes e
`hand-contact-sheet.png` permite conferência. Rodar uma foto não muda a mão;
o auditor exige cada combinação publicada, incluindo -90,0,90,180 graus.
Não se consulta isCorrectAnswer nem a escolha do motor. Foram usadas 16
respostas por teclado e 16 por rato nas mãos.

Em posições, o caso mede os centros desenhados da criança e da caixa,
visibilidade da tampa e ordem de pintura. Compara essas relações com os textos
PT visíveis, sem checkState, stateId, selectedPosition ou positionModels.
Cobriu 14 respostas por teclado e 12 por rato, com confirmação por
Espaço/Enter ou botão OK. Os distratores foram os que a atividade sorteou.

No rato, a identidade visível peixe/macaco determina lago/árvore e botão
esquerdo/direito. Foram 11 cliques corretos com cada botão físico. Os erros
mostram a cruz e deixam o animal no mesmo local; depois da reparação verifica-se
a chegada à área de destino e o desaparecimento normal. Não se consulta
animalIdentifier, estado de solução ou contador de conclusão.

## Correções e pares idênticos

`mouse-red` conclui os 22 gestos, mas o launcher e o executor devolvem 1:
as referências leftArea/rightArea guardadas como papéis de ListModel deixavam
de existir durante a limpeza dos animais reparentados nas transições naturais.
O Qt terminava com 0 e o QtTest passava; as exceções QML continuam a invalidar
a prova. `mouse-complete`, caso byte a byte igual, passa sem exceções depois de
passar os destinos diretamente como propriedades Item do delegate. A correção
está em `18714982cd3da866b0a24f2e931c444dddf40a90`.

`hand-help-red` comprova que o botão direito físico é ignorado, enquanto um
clique normal em «Mão direita» funciona. O manual PT mandava usar o botão
esquerdo ou direito **do rato**, confundindo-o com as duas respostas no ecrã.
`hand-help-green`, caso idêntico, passa com os nomes das respostas explicitados
no manual. Correção em `25f91ab4b85e0e8a5e79649ba2b9b6a5281b5dcc`.
A alteração é só textual; não houve alteração da aceitação de botões físicos.

As mãos e posições completas conservam a fase original, pois as suas imagens,
respostas e motores não foram alterados. A ajuda final das mãos foi revalidada
com a tradução nova. Não foi necessário repetir os 58 estímulos dessas duas
atividades para alterações isoladas ao rato e ao manual.

## Controlos e limites

Os três casos finais de controlos verificam ajuda PT/Escape e foco, navegação,
retorno ao primeiro/último nível e Ctrl+W para o menu. Mãos: progresso antes de
navegar e reposição, sem botão de reinício ou configuração na interface.
Posições: seleção por teclado, reposição pela navegação, retirada/reabertura/
reposição de dataset. A persistência demonstrada é na mesma execução.
Rato: reinício após um animal, navegação, quantidades repostas, teclas sem ação;
não existe seletor de configuração. Os checkpoints de controlos anteriores
ficam separados dos três controlos finais e não aumentam as 80 tarefas.

Uma tentativa inicial do ensaio do rato presumiu incorretamente que a
propriedade interna numberOfLevel fosse 3; a prova final usa as quantidades
visíveis 5/7/10 e as transições reais. Uma tentativa de controlo de posições
mapeava um diálogo para a página já deslocada pela StackView. O alvo real e
a geometria no viewport corrigiram o ensaio. Estas falhas de preparação
ficam no build privado, fora da conclusão; não foram tomadas como defeitos
do produto nem corrigidas com alterações de produção.

O arquivo contém os RCC privados efetivamente carregados por cada caso, as
fontes extraídas, os três arquivos físicos de fontes históricas e o catálogo
PT compilado por fase. Os imports de fundo, AnswerButton/Bonus e três WAV
foram capturados dos RCC do snapshot. Os WAV completetask/crash/bonus foram
descodificados por GStreamer para fakesink com retorno observado0. Isto não
comprova audição, pronúncia ou dispositivos. Não se modificou o conjunto de
1610 vozes nem se aprovou qualquer nova gravação.

## Identidades e reprodução

Onze recibos: três campanhas primárias, três controlos finais, dois
checkpoints anteriores e quatro membros dos pares vermelho/verde (o verde do
rato integra a campanha primária). Nove resultados externos0 e dois vermelhos1.
Todos os processos Qt terminam com0; essa camada não substitui o launcher ou
o executor. `launcher-status.json` é gravado pelo supervisor comum após wait;
`tool-status.json` é gravado por um processo pai depois da espera pelo runner.
Os bytes observados dos runners original/final e do capturador estão em
`execution-tools`. A versão original foi reconstruída dos bytes do comando
retido e conferida com o SHA já observado, sem inventar campos nos recibos.

O auditor é puro: não abre os caminhos históricos absolutos, não precisa de
Git, Qt ou do build original e não altera ficheiros. A âncora literal do índice
impede resealar novas fontes, casos, respostas, recursos ou retornos como
provas antigas. As verificações permanecem eficazes com Python -O.

```
python3 tests/functional_orientation/audit.py
python3 -O tests/functional_orientation/audit.py
python3 -m unittest discover -s tests/functional_orientation -v
```

Para novas execuções, criar snapshot próprio e usar `campaigns.py --revision
<commit> --snapshot <pasta> --output <pasta nova>`; as fontes completas são
preparadas antes do pool e publicadas atomicamente. `capture.py` permite
executar um caso individual e observar o retorno; `--case-file` reproduz casos
arquivados. Não substituir recibos existentes.

Âmbito Linux/software offline. Não se afirma cobertura de todas as sequências
personalizadas, gestos, tamanhos de janela ou permutações. Windows10,
dispositivos físicos, audição, revisão linguística/pedagógica docente e
aceitação global dos203 jogos permanecem pendentes.
