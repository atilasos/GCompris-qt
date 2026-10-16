# Dinheiro e troco em PT-PT

A tarefa 60 testa `money`, `money_cents`, `money_back` e `money_back_cents` no Qt Linux nativo, com perfis privados, locale `pt_PT`, rede Docker desativada e snapshots físicos independentes de 269 ficheiros. O build principal foi apenas origem da cópia selada. Os cinco RCC relevantes foram reconstruídos privadamente a partir de fontes Git congeladas por fase.

## Escopo dos percursos

Há três conjuntos de dados por atividade. Produzem, respetivamente, 23, 23, 29 e 28 níveis em tempo de execução. A campanha percorre os 103 níveis no modo automático e no modo com botão OK, total de 206 puzzles completos. Cada puzzle é uma compra ou troco gerado normalmente, sem controlar aleatoriedade. Não representa todas as combinações aleatórias possíveis.

O oráculo da interface lê os preços nos textos efetivamente apresentados, as imagens das moedas/notas da carteira e, nos jogos de troco, as imagens da quantia entregue pelo Tux. Converte tudo em cêntimos inteiros e procura um subconjunto finito. Não lê `priceTotal`, `Data.paid`, valores privados dos modelos nem chama o validador. Um auditor separado pode ler os datasets para conferir a carteira de cada nível e provar atingibilidade do envelope conservador de montantes. O solver da interface não recebe esses dados.

Os níveis alternam rato e teclado. Os percursos usam cliques reais e Tab, seta para a direita, Espaço e Return; os controlos acrescentam seta para a esquerda e Enter. `MoneyArea` expõe uma ação de clique/toque no momento de largar, sem mover um objeto arrastável. Não se declara validação de uma mecânica de arrasto inexistente.

Para cada puzzle tenta-se um pagamento insuficiente e um excessivo antes do exato, quando essa condição é atingível pelo contrato. No modo automático, uma sequência que passasse pelo total exato já ganharia antes de chegar ao excesso; esses casos ficam explicitamente `available:false`. Com OK testa-se o aviso e a sua duração natural. Os percursos recuperam pelos controlos normais, fazem o pagamento exato e aguardam Bonus e avanço natural, incluindo a volta ao primeiro nível. Não se alteram modelos, progresso, relógios nem animações.

Quatro casos de controlos cobrem título PT, ajuda, foco depois da ajuda, resposta parcial descartada por Gravar, ambos os modos e a sua persistência, exclusão e reposição do primeiro dos três conjuntos de dados com persistência, navegação circular e saída Home ou Escape para o menu. A campanha completa cobre todos os conjuntos selecionados; não há produto cartesiano de cada modalidade de entrada com todos os puzzles.

As correções e pares nativos idênticos estão descritos em [fixes.md](fixes.md). Os vermelhos são falhas esperadas de asserção com saída normal de Qt; não são aprovações. Os 12 puzzles adicionais de `reachability-green` são amostras naturais do nível corrigido e não entram na contagem 206.

## Identidades e reprodução

`phases/` conserva os manifestos completos dos 269 ficheiros selados, o SHA-256 de cada fonte e o mapa realmente exposto por QResource nos cinco RCC. As revisões são `0df3a261b` antes das correções, `29041be63` depois da correção do teclado e `8d9b05007` depois das duas correções restantes. O recibo liga a fonte injetada, o caso exato, o launcher, o catálogo PT, o QM privado, o RCC instrumentado e o snapshot efetivo. Os 17 recursos externos de produtos, fundo e Tux são conferidos com os blobs Git da fase final.

O índice conserva hashes dos ficheiros de prova. O auditor fixa o commit histórico que contém esse índice e confronta os mapas de fontes e recursos com os blobs Git exatos de cada fase. Não abre caminhos absolutos antigos dos recibos nem compara com o PO atual. Uma cópia da pasta de provas pode ser auditada apontando para qualquer repositório que contenha os commits históricos.

```sh
python3 tests/functional_money/audit.py
python3 tests/functional_money/audit.py --evidence /copia/functional-money --repository /clone/GCompris-qt
python3 -m unittest discover -s tests/functional_money -p 'test_*.py'
```

Para uma nova campanha, congelar a revisão, selar recursos e usar uma pasta de saída nova. A preparação não escreve no build principal.

```sh
python3 tests/functional_money/phase.py --revision COMMIT
python3 tests/functional_money/prepare.py --origin-snapshot SNAPSHOT_ORIGEM --source-root build/functional-money/sources/COMMIT --output SNAPSHOT_PRIVADO
python3 tests/functional_money/run.py --revision COMMIT --snapshot SNAPSHOT_PRIVADO --activity money --mode 1 --output SAIDA_NOVA
python3 tests/functional_money/run.py --revision COMMIT --snapshot SNAPSHOT_PRIVADO --activity money --controls --output OUTRA_SAIDA
python3 tests/functional_money/capture.py --revision COMMIT --snapshot SNAPSHOT_PRIVADO --output CAPTURA_NOVA
```

Os processos reais têm de terminar antes de criar o índice. As ferramentas não alteram a aprovação histórica ao executar uma nova campanha.

## Limites

Os três WAV de pagamento, remoção e erro têm identidade Git exata e descodificação GStreamer para `fakesink`. Isso não prova reprodução num dispositivo nem audição. O Qt foi executado sem dispositivo de áudio e em modo offscreen. Sem aprovação de Windows, hardware físico, acessibilidade, perceção visual, pronúncia ou adequação pedagógica. A revisão final do professor e os critérios globais continuam pendentes.
