# Ticket 05: Gatos & Cães contra Tux

A fronteira confirmada é a atividade Qt real, aberta pelo menu. A implementação
partilha as regras da partida de duas pessoas com um WorkerScript ES local.
Não importa código, arte ou textos pedagógicos CRJM. A dificuldade fácil sorteia
uma colocação; média compara mobilidade; difícil compara até doze respostas
para cada colocação candidata. O aluno vê estes limites na seleção e na ajuda.
Não se promete um adversário perfeito.

## Reprodução

A partir desta worktree, com diretório de saída novo em cada execução:

```sh
python3 tools/run-native-qml-case.py \
  --resource-snapshot /tmp/crjm-native-base \
  --activity menu --from-menu \
  --extra-activity dominorio --extra-activity gatos_caes \
  --extra-activity quelhas --extra-activity faisca \
  --qml-file src/activities/menu/Menu.qml \
  --case tests/crjm/gatos-caes-tux.qml \
  --output /tmp/gatos05-merged-tux --offline
```

Regressão de duas pessoas: substituir o caso por `tests/crjm/gatos-caes.qml`
e a saída por `/tmp/gatos05-merged-two`.

## Ciclo e âmbito

O primeiro caso nativo foi escrito antes da implementação: abriu a atividade
pelo menu e falhou em `Tux mode available`, sem erros QML. Evidência em `red/`.
Os testes foram depois alargados no mesmo ponto de entrada. Uma execução
intermédia identificou uma contagem esperada errada na revisão: são 58 casas
para a primeira colocação Cão, pois duas das quatro vizinhas do Gato já são
excluídas pela zona central. O resultado esperado foi corrigido por essa
contagem independente, sem alterar as regras para satisfazer o teste.

O caso Tux verifica respostas das três dificuldades, proibição da zona central
na abertura Cão e ausência de vizinhos Gatos ortogonais, introdução, exercício
preparado de vizinhança, três pistas e rejeição de uma jogada inválida. Tab e
Espaço ativam modo, Aprender e Pista. A partida completa usa apenas casas
permitidas observáveis; o teste não substitui IA, regras, posição ou vencedor.
A revisão recupera a abertura efetivamente jogada, rejeita repeti-la e compara
uma alternativa com as 58 casas originais, sem anunciar nova vitória.
Também verifica ajuda que conserva a posição, reinício durante cálculo,
saída durante cálculo e dimensão das casas em computador e retrato.

A regressão conserva o transcript CRJM legal de 33 jogadas, abertura especial,
rejeições, teclado, toque sintético e vitória natural por bloqueio.

Capturas desktop/retrato foram inspecionadas: tabuleiro e controlos legíveis,
sem sobreposição; casas superiores a 40 px nos dois tamanhos testados.

Software renderer, Qt 6.10.2, Linux x86_64 e Docker com rede desativada.
O snapshot independente e os hashes dos recursos estão nos resultados.
Este host é Intel Core i5-12600K, 46 GiB RAM: não representa equipamento
modesto. Toque físico, desempenho em tablet real e avaliação com alunos
continuam sem validação. Não foi alterado o runner, o core ou outros jogos.

## Resultados finais

Tux e regressão duas pessoas: duas passagens, zero falhas e zero erros QML
por execução. Resposta Difícil durante a partida: máximo 158 ms excluindo
a primeira medição de 590 ms, que inclui abrir/fechar ajuda e a transição.
Ajuda abriu em 2 ms; maior intervalo do heartbeat de 10 ms foi 24 ms.
Os limites do piloto (resposta 2000 ms, ajuda 1500 ms e heartbeat 250 ms)
foram cumpridos neste host. Amostras brutas em `timing.json`.

Validação realizada depois de integrar a ponta `2cc696b97` na branch própria;
foi incluído o RCC de Faísca e Quelhas além dos jogos diretamente usados.
