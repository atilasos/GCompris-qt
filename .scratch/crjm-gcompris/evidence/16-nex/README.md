# Nex para duas pessoas

Atividade nativa independente QML/ES modules. Não foi copiado código, imagem ou exercício CRJM. Base confirmada por `git merge-base --is-ancestor integration/crjm-games HEAD` antes de implementar, inicialmente 0885c6dc3.

Seam aprovada: aplicação Qt real, abrir no menu e operar os controlos públicos. Os testes não chamam regras, não atribuem estado da partida e não forçam vencedores. Foram consultadas as regras em `/tmp/crjm-advanced-rules.md` e a referência CRJM. Implementação mantém substituições jogáveis mesmo sem duas vazias.

Decisão: três exercícios reais de «últimas casas» fazem parte desta entrega, para verificar as convenções raras através da interface. Cada posição é criada independentemente: todas as casas negras exceto a linha y=5 branca, interrompida em (5,5), que está vazia ou neutra. O caso misto tem também uma neutra em (5,4). Nenhuma cor está conectada antes de aplicar a convenção. O botão executa a mesma resolução usada no fim de turnos normais, calcula as conexões e identifica o participante vencedor. Não há resultado predefinido. O ticket 17 acrescentará IA e aprendizagem geral.

## Reprodução

```sh
python3 tools/run-native-qml-case.py --resource-snapshot /tmp/crjm-native-base \
  --activity menu --from-menu --extra-activity dominorio --extra-activity gatos_caes \
  --extra-activity faisca --extra-activity quelhas --extra-activity atari_go \
  --extra-activity produto --extra-activity y --extra-activity nex --qml-file src/activities/menu/Menu.qml \
  --case tests/crjm/nex.qml --output /tmp/nex-native-acceptance --offline --timeout 150
```

Usar diretório de saída novo. Snapshot base verifica binário e recursos; o runner compila os recursos nativos deste checkout num runtime privado. Sem rede Docker, renderer software.

## Resultados

- Red: `/tmp/nex16-red/result.json`, falha ao procurar a atividade ainda inexistente no menu.
- Green inicial: `/tmp/nex16-green1/result.json`, 0 falhas. Inspeção visual levou a acrescentar margens e barras de deslocação, e a repor a vista no reinício.
- Ajustes intermédios: animação de fecho da ajuda exigia aguardar a transição antes de clicar no controlo seguinte; a repintura do Canvas passou a usar a identidade explícita do Canvas. Erros encontrados e corrigidos antes da entrega.
- Resultado final: `/tmp/nex16-final`, passou, 0 falhas, 2 passes, nenhum erro QML, renderer software, rede docker-none; ver `result.json` e `native.log` junto deste documento.

Percurso: menu, seleção parcial, correção, limpeza, toque QtTest, ajuda que preserva seleção, colocação, troca de cores/margens mantendo identidades, substituição de duas neutras e uma própria, rejeição da cor errada, Tab e Espaço em todos os botões habilitados, partidas legais de 21 turnos com vitória negra e 22 turnos com vitória branca previamente verificadas contra as ações reais CRJM, bloqueio depois da vitória, três convenções raras, reinício, desktop 1100×700, retrato 600×900 e regresso ao menu. Alvos do tabuleiro têm pelo menos 40 px; a vista desliza quando não cabe na janela, com setas a trazerem o cursor para a zona visível.

Limitações: toque sintético não substitui um dispositivo físico. Não foi validado som ou adequação pedagógica com alunos. Ainda sem Tux, pistas ou revisão de decisões nesta entrega.
