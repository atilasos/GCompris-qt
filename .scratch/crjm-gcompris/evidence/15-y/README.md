# Ticket 15 — Y contra Tux

Base confirmada: integration/crjm-games d8f738283. Trabalho em work/crjm-15,
com merge da integração até 5492a958b antes da validação final integrada.
TDD pelo seam aprovado: aplicação Qt real, aberta pelo menu. Red com o controlo
Contra Tux ausente: 1 falha, 1 passagem. Green: 0 falhas, 2 passagens, sem erros
QML. Regressão ticket 14: 0 falhas, 2 passagens, sem erros QML.

```sh
python3 tools/run-native-qml-case.py \
  --resource-snapshot /tmp/crjm-native-base \
  --activity menu --from-menu \
  --extra-activity dominorio --extra-activity gatos_caes \
  --extra-activity faisca --extra-activity quelhas \
  --extra-activity atari_go --extra-activity produto \
  --extra-activity y --extra-activity nex \
  --qml-file src/activities/menu/Menu.qml \
  --case tests/crjm/y-tux.qml --output /tmp/y15-desktop-small --offline
```

Para a regressão, substituir o caso por `tests/crjm/y.qml` e o destino por
`/tmp/y15-final-regression`. O snapshot é o runtime nativo independente e
verificado do piloto; não substitui a compilação dos recursos QML atuais pelo runner.
O resultado regista hashes dos recursos, código do caso, isolamento docker-none,
renderer software e executável Qt sem browser ou GPU. O grafo factual e a sua
proveniência continuam sem alterações.

Cobertura: todas as dificuldades realmente calculam; Fácil coloca uma peça
vermelha legal; Médio e Difícil adotam uma abertura Azul num canto, mantêm Tux
como participante 2 e respondem com exatamente uma peça Azul à peça Vermelha
do aluno. Uma partida Hard completa chega à vitória real de Tux após 42 decisões
humanas. Não há mock, injeção de vencedor ou substituição das regras. A revisão
retoma a decisão real A1 e permite comparar A2: grupo de uma peça em ambos os
casos, dois lados no canto original e um na alternativa. O exercício preparado
completa o grupo azul com toque em A9, usando a deteção normal de vitória.

Tab/Espaço ativam modo, três dificuldades, introdução, exercício, pistas, revisão,
ajuda, reinício e zoom. Rato ativa os controlos e scroll; toque QtTest conclui o
exercício. Saída e reinício imediatamente após agendar uma resposta real verificam
a invalidação sem esperar que o worker conclua. Reabertura conserva um tabuleiro
vazio, sem peças tardias. A ajuda abre e fecha sem perder a posição.

Inspeção visual realizada nas capturas: desktop 1100×1050 mostra o grafo inteiro;
1100×700 mantém modos, pistas e controlos inteiros, com viewport de pelo menos
200 px e tabuleiro percorrível, e permite uma colocação humana com resposta Tux;
retrato 600×900 com zoom mantém controlos visíveis e acesso por scroll/setas aos
nós inferiores. Todos os alvos do tabuleiro conservam 44×44 px.

Medições observadas: resposta máxima 114 ms (inclui o intervalo de observação e,
nas aberturas, consulta da ajuda), heartbeat máximo 219 ms, abertura da ajuda
61 ms. Limites do piloto: 2000/250/1500 ms respetivamente. Host Linux com Intel
Core i5-12600K, renderer software, rede isolada. Estes resultados não demonstram
desempenho num dispositivo modesto. Toque é sintético; não foi feita avaliação
com crianças, teste num tablet físico ou validação de áudio.
