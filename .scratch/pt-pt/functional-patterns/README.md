# Padrões, mosaicos e polígonos, tarefa90

Este lote verifica percursos finitos Linux offline. Não aceita globalmente jogos,
Windows, equipamento, audição, apreciação docente ou estabilidade da tarefa83.
Nenhum texto, áudio ou regra dos quatro jogos foi alterado por este lote.

## Percursos concluídos

Redraw:38 tabuleiros fixos,1520 células, três conjuntos configuráveis.
Redraw Symmetrical:21 tabuleiros fixos,645 células, três conjuntos.
Mosaic:22 níveis,321 posições, quatro conjuntos. As perguntas são geradas;
foi concluída uma amostra corrente por nível, sem esgotar as permutações.
Polygons:9 instruções do tutorial,9 rejeições de pontos colineares,9 reparações
por exemplos geométricos independentes e9 continuações naturais. O piloto
inicial é separado e não acrescenta um décimo nível.

Há90 conclusões primárias,90 erros reparados,59 padrões fixos e22 perguntas
Mosaic geradas. Cada atividade regressou ao menu após o sucesso final.
O modo livre de Polygons tem zero níveis: foram desenhadas nove classes de
exemplos, sem Bonus inventado. Arrasto, duplo clique, setas, seleção, Delete,
criação por teclado, reinício, ajuda/Escape e menu foram observados.

Os controlos finais são controls2-redraw, controls3-redraw_symmetrical,
controls3-mosaic e polygons-controls2. Os dois modos Redraw exercitam14 efeitos
de dígitos cada, seis pinturas e seis apagamentos por teclado, oito movimentos
de cursor e duas células por arrasto. Mosaic exercita seis pinturas e oito
movimentos com Tab/Espaço/Return/Enter. As configurações3/3/4 são operações de
configuração, sem crédito extra de conjuntos resolvidos. O realce Mosaic fica
0,5px deslocado da imagem; admite-se até1px só no cursor. Células, planos e
cliques mantêm correspondência estrita.

## Histórico e identidade

São23 processos Qt terminados com zero. Os supervisores/capturadores externos
terminaram16 vezes com zero e7 com um. As falhas são fixtures conservadas:
duas calibrações que excluíam a barra; duplo clique com API inexistente; três
controlos iniciais; uso do centro do cursor no lookup estrito da célula Mosaic.
controls2-redraw_symmetrical terminou nativamente com zero mas não mudou a
célula antes do menu. Fica como parcial, substituído pelo controls3 que exige
mudança real. Nenhum destes diagnósticos é declarado defeito de produto.

Os oráculos usam cores/píxeis e geometria públicos, sem matrizes de resposta,
modelos ou validadores internos. Os recursos de autoria só servem ao inventário
e à comparação posterior. A paleta de sete cores foi calibrada por pintura
real, incluindo branco Qt ARGB #33ffffff. Os25 SVG Mosaic têm assinaturas RGBA
únicas.963 recortes reais foram classificados a partir das imagens físicas;
6078 células opacas e6912 translúcidas foram verificadas nas duas grelhas das
177 cenas Redraw/Sym, com fundo independente. A geometria Polygons e os
segmentos foram conferidos contra os estados e cenas efetivos.

A cápsula tem1260 objetos,5330 caminhos lógicos,10 fontes históricas e23 casos.
Inclui executável, seis RCC canónicos selecionados,23 RCC/QM privados, extrações,
casos, fontes, PNG, observações e dados dos algoritmos. O RCC guesscount também
foi conservado/descodificado; isso não é cobertura funcional de guesscount.
Foram descodificadas120 imagens e15 efeitos/sons canónicos, sem audição humana.

Índice literal:4c02249ea9e0473f6956c72cdc98803e09689d1e184d55ead4292640ce37a1bf.
ZIP original:44267275 bytes,
e44a60043d53db36589a11e0b4f04a9646a0c677e40ebdb41ceafdf034350ce6.
As duas partes em portable-capsule preservam esses bytes, sem reancorar o índice.
Os diretórios originais gerados continuam na árvore de implementação até revisão;
o arquivo portátil conserva os seus ficheiros físicos sem exigir essa árvore.

O coletor inicialmente guardou historical_output relativo. Os dois primeiros
auditores recusaram corretamente a reconstrução da instrumentação. O auditor
final reconcilia essa descrição com o caminho absoluto do deployment registado
no recibo nativo, e confere todos os bytes do RCC instrumentado. Não altera
índice, recibos ou RCC para o fazer. O coletor futuro grava caminhos absolutos.
As falhas e o primeiro sucesso estão em audit-verification.

O snapshot próprio tem269 ficheiros. Não sela bibliotecas Qt/plugins/libc do
host, nem a imagem Docker é uma distribuição Qt autónoma: o wrapper monta o
host para executar Qt. A cópia pura Python3.12/Pillow12.1.1 não dispõe de
Git/Qt/rede/checkout e verifica os artefactos, não repete o jogo.
Os dois modos normal e -O passaram, incluindo cópias adulteradas fisicamente e
coerentemente, prova vazia e proteção de saída. Quinze testes do auditor passaram
nos dois modos. Os módulos independentes têm testes e provas próprios.

## Repetir a auditoria

```sh
python3 tests/patterns_audit/audit.py --evidence .scratch/pt-pt/functional-patterns/portable-capsule
```

Fonte e comandos de cópia isolada: tests/patterns_audit/portable.py.
Relatórios de retorno, hashes e isolamento: audit-verification/portable.json.
A âncora permanece literal. As declarações externas do responsável são registos
com sessão/chunk reais, não assinaturas produzidas pela plataforma.
