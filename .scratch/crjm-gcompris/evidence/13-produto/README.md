# Produto: Tux e aprendizagem

Implementação original em QML/JavaScript. Regras publicadas de Produto consultadas através da investigação CRJM; não foi copiado código, algoritmos, imagens ou exercícios da plataforma CRJM. A atribuição já existente foi conservada. O exemplo didático 2×2→5×0 foi criado para esta atividade.

Comando executado na worktree do ticket:

```sh
python3 tools/run-native-qml-case.py --resource-snapshot /tmp/crjm-native-base --activity menu --from-menu --extra-activity dominorio --extra-activity gatos_caes --extra-activity faisca --extra-activity quelhas --extra-activity atari_go --extra-activity produto --qml-file src/activities/menu/Menu.qml --case tests/crjm/produto-tux.qml --output /tmp/crjm13-final --offline --timeout 240
```

Resultado: 2 passes, zero falhas, zero erros QML. Snapshot Qt 6.10, software rendering e Docker sem rede. Os hashes do código, caso e runtime constam de result.json. Não se modificou a build instalada.

O red inicial, antes de existir o modo, falhou por não encontrar o botão Contra Tux. red-result.json e red-native.log conservam essa prova. O smoke seguinte passou; a aceitação completa revelou problemas de encadeamento de foco ao desativar os seletores e de atualização reativa da seleção da terceira pista, entretanto corrigidos e validados pelo mesmo percurso público.

O caso final abre Produto pelo menu, ativa três dificuldades por Tab/Espaço e verifica uma resposta completa legal em cada uma. Faz a introdução e o exercício com três pistas e toque; preenche o tabuleiro de 61 casas numa partida contra o WorkerScript real, sem alterar o estado nem atribuir resultados. Abre a ajuda sem perder o turno, faz revisão de uma decisão real tardia, experimenta uma alternativa e observa os produtos e tamanhos dos grupos. A revisão não produz outra vitória. Reiniciar ou sair imediatamente após confirmar invalida respostas pendentes; reabrir começa vazio.

A regressão das duas pessoas foi repetida com tests/crjm/produto.qml: 2 passes, zero falhas e zero erros QML; inclui abertura branca, cores de ambos os participantes num turno, correção de seleção, união que reduz pontuação e desempate completo. O comando é igual ao anterior, mudando `--case` e `--output /tmp/crjm13-regression2`.

Medições finais: respostas observadas entre 5 e 60 ms, ajuda 8 ms e maior intervalo de heartbeat 26 ms. Limites do piloto: resposta ≤2 s, ajuda ≤1,5 s e heartbeat <250 ms. A primeira resposta com abertura de ajuda é excluída da lista de tempos de resposta para não contar a espera intencional da transição da ajuda. O cálculo usa um WorkerScript: Fácil amostra uma jogada; Médio avalia até 24 turnos da própria cor; Difícil avalia até 96 turnos de ambas as cores, com limite adicional de 350 ms e confirmação pela mesma regra atómica. Não enumera todas as combinações nem promete uma jogada ótima.

Host real: Intel Core i5-12600K, 16 CPUs lógicos, Linux x86_64. É um computador potente; estes tempos não são uma medição em hardware físico modesto. Os alvos do tabuleiro verificaram pelo menos 36 px em 1100×700 e 40 px em 600×900. Capturas desktop, retrato e revisão foram inspecionadas: texto, tabuleiro e botões estão dentro da página e legíveis.

Toque é sintético QtTest, não ensaio num ecrã tátil físico. Testes mudos não verificam áudio nem adequação pedagógica com crianças. Nenhuma publicação/distribuição foi feita.

Depois de integrar o tip com Atari Go contra Tux e Y para duas pessoas, o caso Tux foi repetido com `--extra-activity y --output /tmp/crjm13-integrated`: 2 passes, zero falhas e zero erros QML. Respostas 4–56 ms, ajuda 4 ms e heartbeat 26 ms, conservados em integrated-result.json e integrated-native.log.
