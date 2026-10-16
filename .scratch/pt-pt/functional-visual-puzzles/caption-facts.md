# 88 — conferência factual de legendas

Consulta em 2026-10-16, apenas leitura de fontes locais e pesquisa web. Sem Qt,
edições no repositório, browser interativo ou push. Este é um levantamento das
cinco suspeitas e de um problema adicional encontrado; não uma certificação
histórica integral das43 legendas.

Observei `case_result.boards[].instruction` dos recibos
`.scratch/pt-pt/functional-visual-puzzles/inventory-{details,paintings}/result.json`
na árvore pt-visual-puzzles. Os caminhos abaixo são relativos a essa árvore.

## Correções sustentadas

### Details18 — Aichi não é uma câmara municipal

Observado: «Castelo Nagoya, Câmara Municipal de Aichi, Japão.»
`src/activities/details/resource/board/board18_0.qml:14` tem
`Nagoya Castle, Aichi Prefecture, Japan.`; PO PT linhas7207–7208 introduz o erro.
É a localização administrativa do castelo, não a identificação de um edifício
administrativo. A informação turística oficial da prefeitura situa o castelo
em Nagoya, Aichi; a entidade turística municipal dá a mesma localização.

Correção PT proposta: **«Castelo de Nagoya, prefeitura de Aichi, Japão.»**
O inglês original pode permanecer. Não substituir a legenda pelo nome da sede
do governo de Aichi: é outro edifício.

Fontes oficiais:
- [Aichi Now — Nagoya Castle and Hommaru Palace](https://www.aichinow.pref.aichi.jp/en/spots/detail/17/)
- [Visit Nagoya — Nagoya Castle](https://www.nagoya-info.jp/en/spot/detail/1/)

### Paintings11 — nome Katsushika Hokusai

Observado «Katsushika Hokusa, Papoilas - 1833-1834». O erro `Hokusa` já existe
no qsTr de `paintings/resource/board/board11_0.qml:14` e no msgid/msgstr PT
(linhas22511–22512). O British Museum identifica o artista como Katsushika
Hokusai; o Met atribui-lhe Poppies in the Wind e o Rijksmuseum Poppies.

Correção segura: **Hokusa → Hokusai**, no original e no PT. As datas de
Papoilas têm divergências: Met1820–34, Rijksmuseumc.1832; o intervalo atual
1833–1834 não deve ser trocado por uma suposta data unânime. Para rever a data,
identificar primeiro a impressão/reprodução que originou os recortes
`HokusaiPoppies_*.webp`. Não confundir com a obra homónima de Hiroshige.

Fontes primárias:
- [British Museum — ficha biográfica de Hokusai](https://www.britishmuseum.org/collection/term/BIOG1820)
- [Met — Poppies in the Wind, JP1860](https://www.metmuseum.org/art/collection/search/56183)
- [Rijksmuseum — Poppies, RP-P-2023-32](https://www.rijksmuseum.nl/en/collection/object/Poppies--238d097e08aeffd928262a1ddb269016)

### Paintings17 — Pieter Bruegel, o Velho; título da colheita

Observado «Pieter Brugel, Os Agricultores - 1565». O qsTr de
`board17_0.qml:14` é `Pieter Brugel, The Harvesters - 1565`; PO22541–22542.
O próprio museu detentor identifica **Pieter Bruegel the Elder**, The Harvesters,
1565. `Brugel` é erro também do original, não uma opção ortográfica portuguesa.

Correção proposta: **«Pieter Bruegel, o Velho, Os Ceifeiros - 1565»**.
«Os Ceifeiros» é aqui uma tradução descritiva sustentada pelo assunto e pelo
título inglês, não uma alegação de título PT oficial do museu; pode conservar-se
`The Harvesters` como título de referência se se preferir não normalizar títulos.
A data1565 está confirmada.

Fonte: [Met — The Harvesters,19.164](https://www.metmuseum.org/art/collection/search/435809).

### Paintings8 — Benzaiten:1760–70 é impossível para este artista

O qsTr de `board8_0.qml:14` e PO22606–22608 já contêm1760–70;
a tradução não inventou a data. Os recortes chamam-se
`HiroshigeInokashiraSnow_*.webp`. Hiroshige viveu1797–1858.

Atribuição/título correspondem a Inokashira no ike Benzaiten no yashiro yuki no
kei, da série Meishō setsugekka. Coleções primárias divergem na datação:
Spencer1843–1847; Chazen1845; Library of Congress1838–1844; catálogo de exposição
MoMAKyoto/National Museum in Kraków1842–1845. Não é legítimo apresentar um ano
único como consensual nem converter automaticamente1760 em1860.

Correção segura: retirar1760–70. Opção conservadora: manter título/artista sem
data até identificar a reprodução; opção editorial sustentada em Spencer/Chazen:
**«… - década de1840»**, explicitando a fonte escolhida na documentação.

- [Spencer Museum —1928.7262](https://spencerart.ku.edu/art/collections-online/object/7008)
- [Chazen Museum — Snow at Benzaiten Shrine](https://chazen.wisc.edu/collection/5864/snow-at-benzaiten-shrine-on-inokashira-pond/)
- [Library of Congress —2009615461](https://www.loc.gov/pictures/item/2009615461/)
- [MoMAKyoto — lista de exposição, item21](https://www.momak.go.jp/English/wp-content/uploads/sites/2/2025/05/Young-Poland_List_0526.pdf)

### Paintings7 — Grande Onda: datação atual posterior a1823–1829

O qsTr de `board7_0.qml:14` e PO22601–22602 têm1823–1829.
O Met data a obra c.1830–1832; o British Museum,1831, provavelmente finais de1831.

Correção proposta sustentada pelo Met: **«Katsushika Hokusai, A Grande Onda de
Kanagawa - c.1830–1832»**, atualizando também o texto original. É uma data
aproximada de criação/publicação do desenho, não autenticação da impressão
que originou os recortes.1831 também é defensável se documentado com o BM.

- [Met — Under the Wave off Kanagawa, JP2569](https://www.metmuseum.org/art/collection/search/39799)
- [British Museum —2008,3008.1](https://www.britishmuseum.org/collection/object/A_2008-3008-1)

## Achado adicional, distinguir tradução de título oficial

Paintings12: original `Kazusa sea Route - 1830.` em `board12_0.qml:14`;
PO22516–22517 traduz `Marginal de Kazusa`. O Met cataloga Kazusa no kairo como
At Sea off Kazusa, c.1830–1832: assunto de navegação/mar, não avenida marginal.
Proposta descritiva: **«No mar ao largo de Kazusa»** (ou conservar Kazusa no
kairo como título de referência), documentando que não se encontrou título PT
oficial. Não substituir por um título francês inventado.
Fonte: [Met — At Sea off Kazusa, JP2963](https://www.metmuseum.org/art/collection/search/56238).

## Limites

A confirmação acima usa identidade textual/corpus local e fichas de coleção;
não estabelece a proveniência digital de cada impressão recortada. Os restantes
títulos franceses/topónimos podem manter-se como nomes próprios; não foram
traduzidos por conjetura. Nenhuma alteração a imagens, áudio ou recibos foi feita.
