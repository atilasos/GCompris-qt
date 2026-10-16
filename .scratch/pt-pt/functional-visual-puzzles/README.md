# Pormenores, pinturas e diferenças em Linux

Foram concluídos 53 tabuleiros: 21 de pormenores, com 106 peças; 22 pinturas,
com 261 peças; e dez níveis de diferenças, com 35 diferenças encontradas.
Cada tabuleiro inclui uma tentativa errada, correção, Bonus e continuação
naturais. Os três percursos finais regressam ao menu após o último sucesso.
São provas finitas em Linux, sem aceitação global das 203 atividades.

Os percursos finais são `details-complete2`, `paintings-complete2` e
`photo-complete1`. Os três casos finais de controlos são `controls-details1`,
`controls-paintings1` e `controls-photo2`. Verificam ajuda portuguesa, Escape,
retoma de interação, reinício parcial e menu durante atividade. Pormenores e
pinturas exercitam teclado e rato. As diferenças usam rato e a barra deslizante
real, que sobrepõe as imagens. Os três conjuntos de pormenores foram selecionados
pela configuração e apresentam 8, 6 e 7 níveis.

## Alterações e confirmação

A única alteração de produto são seis traduções em `poqm/pt/gcompris_qt.po`:
Aichi, Hokusai, Bruegel e três legendas de obras. Os dois casos de legendas
registam 43 textos por cor. Antes da alteração havia uma divergência em
pormenores e cinco em pinturas; os mesmos casos passaram sem divergências
após a correção. Fontes de museus e limites da atribuição estão em
[caption-facts.md](caption-facts.md). A data impossível da gravura de Hiroshige
foi retirada sem inventar uma datação consensual.

O percurso final de pinturas usa o PO corrigido. O percurso de peças de
pormenores precede a alteração da sua legenda; a confirmação dessa legenda
vem do caso suplementar verde. Não se afirma que ambos usaram o mesmo QM.
Não foram alterados o motor do jogo, os ficheiros de imagens ou as vozes.

## Oráculos visuais

Os pormenores são localizados pelos píxeis opacos das peças no fundo da imagem.
As diferenças são calculadas dos recortes da cena inteira e da geometria
realmente apresentada. Os PNG obtidos inicialmente de itens individuais
estavam incompletos; ficam preservados como diagnóstico, sem servirem de
oráculo para as diferenças.

Nas pinturas, os círculos laranja visíveis fornecem destinos e uma colocação
neutra calibra a escala. O comparador usa alfa e continuidade RGB, com parâmetros
explícitos de sobreposição de 8%, margem de 16 píxeis e orçamento de 10000 nós.
O quadro 20 usa um modelo retangular limitado a imagens opacas e grelha regular:
as faixas RGB de 2, 4 e 8 píxeis têm de concordar no mínimo único. A moldura preta
induziu uma ordenação visualmente errada no modelo anterior. Não se usaram
coordenadas de resposta da autoria, índices de solução ou funções de resolução
do motor. Estes métodos geram candidatos; os acertos são confirmados pelos
percursos reais e pelo Bonus.

`derive_paintings.py` recalcula os 22 candidatos de imagens, inventário e
calibração físicos. Os outros 21 mapeamentos mantêm-se após a correção do
comparador do quadro 20. Os modelos anteriores, incluindo as cinco recusas
iniciais e o candidato errado, permanecem guardados.

## Execuções preservadas

Há 19 execuções nativas: 13 com retorno externo zero e seis com retorno externo
um. Todas terminaram com retorno Qt zero. As seis negativas são dois testes
precoces do OK, uma verificação precoce da animação de sobreposição, o percurso
parcial de pinturas com candidato errado no quadro 20 e os dois casos vermelhos
de legendas. Nenhuma negativa foi substituída por um recibo verde.

O primeiro percurso de pinturas concluiu 19 quadros; o piloto concluiu três.
Essas repetições não são somadas aos 53 tabuleiros finais. Os testes precoces
do OK passaram a aguardar a propriedade pública `okEnabled`; a sobreposição
passou a aguardar a geometria animada. Estas foram correções dos testes.

`external-observations*.json` são declarações do root sobre retornos realmente
observados após espera das sessões de execução, com sessão e identificador de
saída. Não são assinaturas autónomas da plataforma. Os recibos internos
conservam separadamente os retornos do Qt, launcher e supervisor.

## Artefactos e limites

Os sete RCC canónicos têm 836 entradas. Os 19 RCC instrumentados efetivos têm
1014 entradas extraídas pelo inspetor QtCore, com QM efetivos, comandos e hashes
em `effective-exports*/`. Pormenores e pinturas substituem realmente
`babymatch.rcc`; diferenças substitui `photo_hunter.rcc`. As fontes congeladas
e os deployments privados foram retidos desde cada execução.

A verificação de recursos abriu ou renderizou 562 imagens e descodificou quatro
WAV completos com GStreamer para `fakesink`. O primeiro ensaio de recursos
falhou por falta de `rsvg-convert`; o segundo usa librsvg e cairo disponíveis.
Estas verificações não demonstram audição, qualidade sonora ou equipamento.
Não transferem a aprovação das 32 gravações para os efeitos deste lote.

O snapshot físico tem 269 ficheiros e executável SHA-256
`3a226ee745c25aa8cf5e77d7cfb438c83dc6956091e6230053598cca659314bb`.
O isolamento sem rede usa a imagem Docker
`sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b`.
O wrapper faz chroot no host e não sela todas as bibliotecas Qt, plugins,
libc ou QtTest do host. O digest Docker não identifica a distribuição Qt inteira.
A futura cópia portátil da cápsula destina-se ao auditor puro, não a reproduzir
sozinha toda a execução nativa.

A auditoria portátil e a revisão independente ainda estão em preparação.
Windows 10, Windows 11 manual, dispositivos, audição, revisão docente,
a investigação 83 e todos os critérios globais continuam pendentes.
