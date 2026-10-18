# Nex contra Tux e aprendizagem guiada

Implementação independente, baseada no ramo de integração em 5492a958b. Seam aprovada: aplicação Qt real, abrir pelo menu e operar os controlos nativos. Os testes não importam as regras, atribuem tabuleiros ou forçam vencedores. Usam símbolos e textos visíveis para escolher ações.

## Entrega

- Tux executa o mesmo `apply`, `connected` e resolver de convenções do modo local. As cores pertencem aos participantes e são consultadas novamente após troca; Tux continua participante 2 quando troca a abertura central.
- Três políticas locais num WorkerScript: Fácil escolhe a primeira colocação legal; Médio procura encurtar a sua rota; Difícil também favorece o bloqueio da rota adversária. Os candidatos são limitados a 36 colocações e 18 substituições, sem pesquisa recursiva ou enumeração de todos os pares. Mesmo sem duas vazias, o gerador conserva substituições legais com duas neutras e uma própria. Os finais raros conservam a resolução original; não há empate por falta de duas vazias.
- Introdução e três exercícios novos: colocação, substituição e conexão. Cada ação é validada e confirmada pelas regras normais; os exercícios distinguem-se de partidas CRJM. Os três exercícios anteriores de últimas casas foram preservados.
- Três pistas graduais. A última prepara uma seleção legal corrigível e traz a zona escolhida para a vista. Revisão repõe a última decisão humana real e compara a original com uma alternativa pela quantidade mínima de casas ainda não conquistadas numa rota. A revisão preserva o resultado e não atribui um vencedor artificial.
- Reiniciar, mudar modo/dificuldade, aprender e sair invalidam gerações pendentes. Durante o cálculo ficam bloqueados Colocar, Substituir, Trocar, Confirmar, Limpar e a seleção do tabuleiro. Botões usam StrongFocus e percurso explícito de Tab/Espaço.

## Reprodução

Executar na worktree desta entrega, com diretório de saída novo:

```sh
python3 tools/run-native-qml-case.py --resource-snapshot /tmp/crjm-native-base \
  --activity menu --from-menu --extra-activity dominorio --extra-activity gatos_caes \
  --extra-activity faisca --extra-activity quelhas --extra-activity atari_go \
  --extra-activity produto --extra-activity y --extra-activity nex \
  --qml-file src/activities/menu/Menu.qml --case tests/crjm/nex-tux.qml \
  --output /tmp/nex-tux-acceptance --offline --timeout 160
```

Para a regressão de duas pessoas, substituir o caso por `tests/crjm/nex.qml` e usar outra saída. O snapshot verifica hashes e o runner compila os recursos desta worktree num runtime privado; renderer software, Docker sem rede, sem GPU ou browser.

## Resultados

- RED: `red/result.json`, falha nativa ao procurar o modo Tux antes da implementação. Um segundo ciclo confirmou a ausência de identificação explícita de Tux; a indicação Tu=P1/Tux=P2 corrigiu-a.
- GREEN final: `tux/result.json`, passou, 0 falhas, 2 passes, nenhum erro QML. Menu, três exercícios, todas as pistas, rato/toque sintético/Tab/Espaço, três dificuldades, partida Fácil até vitória humana natural e revisão com alternativa real, partida Difícil após troca de Tux até resultado natural em 18 rondas e revisão, ajuda após despachar cálculo, reinício imediato, saída durante cálculo e reabertura vazia.
- A prova de bloqueio observou 30 momentos de cálculo real com os controlos humanos desativados.
- Resposta máxima observada de Tux: 195 ms, incluindo a espera do teste após despacho (limite 2000 ms). Maior intervalo observado do heartbeat Qt de 20 ms durante as respostas: 34 ms (limite 250 ms). Abertura da ajuda imediatamente após despacho: 4 ms (limite 1500 ms).
- Regressão: `two-players/result.json`, passou, 0 falhas, 2 passes, nenhum erro QML. Conserva as duas cadeias de referência CRJM, ambas as orientações e troca, substituições e rejeições, três convenções raras, ajuda, reinício, teclado/toque e menu.
- Inspeção visual real dos PNG desktop 1100×760 e retrato 600×900. A inspeção inicial detetou título cortado em retrato: foi corrigido com quebra de linha. Tabuleiro mantém alvos acima de 40 px e deslocação/ampliação. Revisão mostra a consequência da ligação original e da alternativa.

Host medido: Linux x86_64, Intel Core i5-12600K, 16 CPUs lógicos, MemTotal 48 983 916 kB. Esta máquina não é um dispositivo modesto; os valores não demonstram desempenho num tablet físico. Toque sintético não substitui ensaio físico. Não foi validado som nem adequação pedagógica com alunos. O percurso de partida Difícil terminou antes de encher o tabuleiro; o suporte de Tux à substituição sem vazias está no gerador partilhado, sem alegar esse cenário completo como reproduzido nativamente.

Proveniência: regras consultadas no CRJM de atilasos e notas de referência; código, políticas e exercícios escritos independentemente em PT-PT, GPL-3.0-or-later. Não se copiou código, exercícios ou recursos sob a licença educativa CRJM.

Verificação final após proteger o deslocamento diferido contra reinício: `/tmp/crjm17-complete`, 0 falhas/2 passes, resultados copiados em `tux/`.
