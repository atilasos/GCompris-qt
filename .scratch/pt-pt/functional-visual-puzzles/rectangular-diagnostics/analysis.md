# 88 — Bazille: diagnóstico da métrica, só píxeis

Sem Qt, modelos de níveis, answerIDs, coordenadas de autoria ou alterações ao
repositório/provas. Inputs: seis imagens físicas RGB em
`.scratch/pt-pt/functional-visual-puzzles/canonical/paintings/files/gcompris/src/activities/paintings/resource/image/bazille_rampart_*.webp`,
board20 do inventário público paintings (círculos/frame), candidato registrado
`/tmp/painting-pixel-refined-all22.json`. A screenshot failure.png foi usada só
para inspecionar a composição, não como oráculo de posições nem aprovação do jogo.

## Causa concreta no seam

As seis imagens são RGB sem transparência: dimensões203/204×181/183.
Logo toda a área é opaca após convert('RGBA'). `solver.py` só calcula restrições
de borda plana se `area < width*height*.98`; flat_border_constraints=true não tem
efeito neste caso. Os RGB incluem moldura/linhas negras de recorte. Por exemplo,
percentagem de píxeis max(R,G,B)<32 no bordo exterior de cada ficheiro:

- recorte1: topo100%, esquerda100%;
- recorte3: direita96.2%, topo100%;
- recorte4: esquerda95.6%;
- recorte6: fundo85.8%.

relation() compara contactos com deslocamento0/±1 píxel e média RGB² por par.
A moldura negra entra como conteúdo da pintura: justaposições negras artificiais
podem custar pouco, enquanto uma junta visualmente contínua com uma linha negra
num dos recortes custa muito. O status unique apenas certifica unicidade sob
essa métrica; não certifica continuidade pictórica. O problema não se explica
por overlap8%: o candidato usa apenas0.5525% de sobreposição máxima, e as bordas
negras são opacas. Padding16 também não distingue moldura de conteúdo.

Reapliquei o corpo real de solve numa cópia em memória, restringindo cada domínio
à posição de cada um dos DOIS candidatos já derivados por píxeis (não alterei
solver.py). Isso confirma os custos exatos da métrica original:

| Composição, ordem dos slots públicos0..5 | custo original |
|---|---:|
|2,3,4 /5,6,1 (candidato existente)|9056.401343297863|
|1,2,3 /4,5,6 (candidato independente)|13798.348881891203|

O algoritmo está a otimizar o critério programado; não é uma falha do search
nem evidência de defeito do jogo. A coluna direita do primeiro põe praia acima
do céu e quebra muralha/água. A segunda mantém céu, muralha, água e praia
contínuos. Os números são apenas rótulos de ficheiros; não foram interpretados
como posições durante a procura.

## Candidato independente e ensaio mínimo puro

`python3 /tmp/bazille-pixels.py` enumera720 permutações, com soma da diferença
RGB² média em TODAS as7 adjacências da grelha visível3×2. Para cada lado compara
médias de faixas interiores de largura explícita, sem usar alpha/modelos do jogo.

| Faixa | melhor custo | segundo custo | melhor composição |
|---|---:|---:|---|
|1px|3816.03|3829.52|4,5,6 /2,3,1 — visualmente errada|
|2px|8665.80|13027.88|1,2,3 /4,5,6|
|4px|8199.19|16137.87|1,2,3 /4,5,6|
|8px|11724.37|14482.33|1,2,3 /4,5,6|

O próprio controlo1px falha: sustenta a hipótese de moldura contaminando a
amostragem, em vez de só apresentar um parâmetro que funcionou. Com4px, o
candidato existente teria26355.26, frente8199.19 do independente. São unidades
deste critério novo, não diretamente comparáveis às do critério original.

Artefactos temporários:
- `/tmp/bazille-pixels.py`: enumeração pura, sem consulta a fontes de níveis;
- `/tmp/bazille-candidate.json`: mapping proposto e descrição do critério;
- `/tmp/bazille-contact.png`: contacto visual candidato antigo/independente;
- `/tmp/bazille-force-metric.py`: comparação do corpo real do solver com dois
  domínios fixados a candidatos derivados dos píxeis;
- `/tmp/bazille-relations.json`: contagens auxiliares de contactos/bordos,
  sem se apresentar como instrumentação exata da ordem de amostragem do solver.

Não houve colocação nativa nova nem conclusão de nível. Antes de mudar o helper,
um teste puro pode conservar estes seis recortes como fixture e exigir
continuidade global/recusa, além de verificar que faixas não mascaram
ambiguidades noutros casos. Não extrapolar esta métrica retangular para peças
com alpha irregular sem avaliação própria. Não há autorização implícita para
ler uma imagem de referência inteira ou posições do modelo como resposta.
