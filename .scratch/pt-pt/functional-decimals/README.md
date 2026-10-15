# Decimais e quantidades — interação Qt real

A tarefa30 exercita learn_decimals, learn_decimals_additions,
learn_decimals_subtractions e learn_quantities. O inventário independente contém
15 datasets/níveis e79 subníveis configurados:15,12,12 e40 respetivamente.
Cada campanha termina todos os subníveis e regressa naturalmente ao nível1.

## Método reproduzível

`tests/functional_decimals/inventory.py` lê os Data.qml sem executar o gerador.
O controlador QtTest lê os números da pergunta PT visível e calcula em unidades
inteiras: décimos nas atividades decimais e objetos nas quantidades. Arrasta a
seta e cada barra real; na subtração clica o quadrado correspondente ao resultado.
Não atribui modelos, fase, resposta, nível ou pontuação para resolver os puzzles;
não chama o verificador JS, emite Bonus ou encurta animações.

Cada jogo percorre as orientações1100×700 e600×900 e os dois estados do teclado
virtual. Os jogos com fase de escrita usam teclas físicas Qt simuladas ou cliques
nos botões virtuais, incluindo vírgula PT e Backspace. Os outros dois conservam
esses estados globais, mas não têm fase de escrita. Nas campanhas com teclado
virtual liga-se a ajuda visual pelo botão real, quando esse botão existe; nas
outras mantém-se desligada. A subtração não expõe esse botão.

No primeiro subnível de cada dataset, uma representação errada é rejeitada sem
pontuar. Nas operações também se rejeita um resultado escrito errado, apaga-se
e escreve-se o correto. A fase gráfica é sempre completada por interação.
A pontuação, desbloqueio, transições de subnível e Bonus de fim de nível são
observados; cada resposta aceite fica no log e no resultado estruturado.

`audit.py` usa Decimal em Python para conferir a aritmética e a vírgula, e faz
correspondência entre as perguntas observadas e o conjunto de restrições dos
subníveis baralhados. Quatro testes cobrem vírgula, soma que excede o limite,
baralhamento com intervalos sobrepostos e subtração negativa.

Comandos, a partir deste checkout:

```bash
python3 tests/functional_decimals/run.py --snapshot build/decimals-core33/snapshot --output .scratch/pt-pt/functional-decimals/offline-campaigns --jobs 4 --offline
python3 tests/functional_decimals/audit.py .scratch/pt-pt/functional-decimals/offline-campaigns
python3 tests/functional_decimals/run.py --snapshot build/decimals-core33/snapshot --output .scratch/pt-pt/functional-decimals/final-controls --jobs 4 --offline --case controls
python3 -m unittest discover -s tests/functional_decimals -p 'test_*.py' -v
```

Os diretórios de saída têm de ser novos. Cada result.json conserva os hashes
dos recursos selados25, binário, caso injetado, RCC privado e catálogo PT.
O snapshot deriva de uma cópia independente e inclui o core33 recompilado
privadamente; `core-build.json` regista a origem. O build principal não foi
alterado. A execução offline usa Docker com `--network none` e perfis privados.

## Controlos e diagnósticos

Os quatro controlos finais abrem a configuração de datasets, gravam para
reiniciar após uma representação parcial, verificam o estado reiniciado,
navegam próximo/anterior, abrem/fecham a ajuda PT e regressam ao menu. O Save é
um QtQuick.Controls.Button e recebe press/release separados por50ms. Após uma
mudança de nível espera-se um frame antes de guardar um delegado GridView:
o primeiro ensaio imediato de subtração capturou um delegado já substituído e
produziu ReferenceError; `subtractions-controls-settled` conserva o ensaio estável.
Os logs iniciais não são evidência de um defeito persistente corrigido.

O corte inicial da barra era a animação populate/add da Row em Bar.qml359–369:
x/y desde200, duração1500ms, OutBounce, ao mudar os botões do tutorial para os
botões de atividade. `toolbar-timeline-fixed` observa shown/hidden=false durante
todo o período; o centro da seta está abaixo de800px no início e fixa-se em751px
a partir de1600ms, permanecendo assim até3000ms. O clique final usa o centro
completo dentro da janela; não há alteração de produção para esta hipótese.
O primeiro caso toolbar-timeline tinha uma variável QML reservada e foi corrigido
somente na fixture. Os ensaios de diagnóstico anteriores ficam identificados
pelos nomes tracer/v1–v6; os resultados finais são os indicados no índice.

## Limites

Cada campanha cobre uma amostra gerada por cada subnível configurado, não todos
os valores aleatórios possíveis. Não foram selecionadas individualmente todas
as combinações de subsets de datasets: os15 datasets estavam ativos e foram
percorridos integralmente; a configuração foi aberta e gravada sem exclusões.
Sem prova de ecrã físico, dispositivo de áudio, audição, Windows ou aprovação
docente. Os bloqueios dos botões durante feedback pertencem à tarefa33.

## Resultado para revisão

`index.json` fixa os20 resultados finais:16 campanhas e4 casos de controlos,
todos verdes com rede docker-none. Foram concluídos316 puzzles offline e o
oráculo Python confirmou todas as perguntas/respostas e restrições configuradas.
A primeira matriz online também completou316 puzzles; serve de ensaio inicial,
sem substituir a evidência offline final. Não se encontrou defeito persistente
que justificasse alterar produção neste lote. A aceitação do agente limita-se
a estes quatro jogos e aos percursos descritos acima.
