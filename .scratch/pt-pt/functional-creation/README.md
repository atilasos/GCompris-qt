# Desenho e criação, tarefa 89

Validação nativa offline de `simplepaint`, `sketch` e `drawing_wheels`.
As provas são compostas por fases explícitas. Não representam aprovação global,
audição, Windows, equipamento físico, apreciação docente ou estabilidade da tarefa 83.

## Oferta e percursos

Simplepaint oferece 31 níveis de fundos e grelhas, com paletas simples de 12 e
avançada de 49 escolhas. `simplepaint-levels-v5` pinta por rato e teclado, apaga,
reinicia cada nível, verifica os píxeis, navegação circular, ajuda e menu.
`simplepaint-palettes-green` percorre as 61 escolhas pela interface, verifica
visibilidade do seletor e a cor efetivamente pintada. A transparência da primeira
escolha conserva o fundo; apagar tinta existente está provado nos 31 níveis.

Sketch é um editor livre, não uma série de exercícios. `sketch-tools-v3` verifica
23 rotas com marcas reais: seis pincéis, seis geometrias, três gradientes, carimbo,
texto e seis borrachas aplicadas sobre tinta existente. O pincel de preenchimento
recebe um polígono fechado. Há texto português com acentos, `OLÁ CRIAÇÃO`.
`sketch-tracer-v6` desenha, desfaz, refaz, guarda `CRIAÇÃO.png`, cria novo, abre
o ficheiro pelo diálogo e compara os píxeis, antes de ajuda e menu.

Os prefixos completos de `sketch-controls-v5` inventariam 12 paletas de nove
cores, três controlos HSL, 18 opções de ferramentas, espelho, 14 padrões,
42 fundos e configuração persistente de desfazer. Cancelar saída e nova imagem
preserva o trabalho. Esse caso termina com uma expectativa falhada ao escolher
um fundo após rolar a lista, não é contado como caso integral aprovado.
Os ensaios dirigidos `sketch-background` e `sketch-background-v2` separam o fluxo
sem rolagem, com capturas completas e ficheiros próprios. Não há alegação de
esgotar as combinações livres de paletas, opções, carimbos e desenhos.

DrawingWheels tem dois níveis, sete tamanhos fixos de roda e 30 combinações
fixas válidas no primeiro, controlos deslizantes no segundo.
`wheels-levels-v4` opera todas as escolhas fixas, desenha nos dois níveis com
opções diferentes, pára, espera sem movimento, retoma e aguarda a conclusão
natural. Guarda e abre SVG e PNG. O oráculo geométrico usa os centros e a caneta
desenhados e os números visíveis, com equação de rolamento de círculos,
sem ler pontos internos. A tolerância de três píxeis cobre a precisão aproximada
dos centros e dos vetores exportados. Não ajusta parâmetros ao resultado.
`wheels-controls-v2` cobre navegação circular, paletas, configuração persistente,
saída parcial cancelada, gravação, abertura, fundo, ajuda e menu.
O Qt e supervisor deste caso terminam com zero. O capturador histórico termina
com um ao procurar `FUNDO.svg`, ausente para o desenho vazio que produziu
`FUNDO.png`. O suplemento conserva os cinco ficheiros reais e a ausência do
sexto, sem alterar recibo nem inventar um SVG. Os SVG não vazios dos dois níveis
sustentam a verificação vetorial e a reabertura.

Sketch oferece importar SVG, PNG, JPG, JPEG e WEBP e guardar PNG. DrawingWheels
oferece abrir SVG e guardar SVG com PNG associado. Foram exercitados os formatos
PNG em Sketch e SVG/PNG nas rodas. A enumeração das extensões de importação de
Sketch não significa cinco percursos de reabertura.

## Correções com reprodução

Sete traduções de `ColorSelector` estavam apenas obsoletas no PO e apareciam em
inglês: Paleta de cores, Repor paleta, Cor selecionada, Matiz, Saturação,
Luminosidade e Repor cor. Os casos `sketch-labels-red`/`green` e
`wheels-labels-red`/`green` usam casos idênticos, com PO corrigido em
728cfdc72f48e048b70d969d22ef166c2206bb8e. Nenhum áudio novo ou alterado.

Simplepaint selecionava por teclado cores fora da área visível. O caso idêntico
`simplepaint-palettes`/`simplepaint-palettes-green` reproduz e verifica a correção
de uma linha em 416ddcc9dd331e8072c7f4a7e69bf3339ac86655, deslocando a lista
até à escolha atual. Os 31 níveis e 23 ferramentas anteriores conservam validade
nos seus limites, mas não são apresentados como repetição integral após estas
correções. As verificações dirigidas e controlos finais compõem a prova final.

## Execução e recursos

Snapshot próprio de 269 ficheiros, independente do build principal, sem alterações
a esse build. Os snapshots físicos privados e deployments são conservados até
à revisão. A cápsula portátil retém todos os RCC/QM efetivamente substituídos,
as extrações Qt correspondentes, fontes congeladas, casos exatos, imagens,
ficheiros criados, estados e os 43 fornecedores físicos das 159 imagens fixas.
O manifesto de 269 identidades não se apresenta como arquivo portátil de todas
as bibliotecas e dados externos não utilizados. Consulte
[resource-provenance.md](resource-provenance.md) para os dois ficheiros de outro
jogo não executados, recuperados por identidade Git histórica.

O launcher conserva software por defeito. O caminho opcional OpenGL usa Xvfb
privado dentro do contentor sem rede, com Mesa por software, socket privado e
host só de leitura. A cena confirma `useSoftwareRenderer=false`; isso demonstra
este renderer Qt, não uma placa gráfica física. Imagem efetiva
`sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b`.
Ficheiros privados com UID/GID 1000. O Xvfb é arquivado com identidade e copyright.

A janela privada sem gestor precisa de `requestActivate()` antes dos atalhos,
uma ação pública de foco. Uma tentativa de corrigir foco no produto não resolveu
o ambiente e foi revertida. Não há alteração final de foco em Sketch ou nas rodas.

Diagnósticos permanecem separados da cobertura. Incluem uma tentativa de usar
carácter Unicode diretamente em QtTest que terminou com código nativo 250,
substituída por enums Qt explícitos, e um capturador interrompido com código
nativo 137. Não se infere sinal nem defeito do produto. Dois erros iniciais de
transcrição de chunk estão conservados em `tool-exit-recording-error.json`;
os registos canónicos usam as respostas observadas posteriormente. Não são
recibos nativos adicionais. Nenhum diagnóstico é contado como percurso aprovado.
Qt, launcher, supervisor e capturador são registados separadamente após espera.

## Repetição da auditoria

`python3 tests/functional_creation/audit.py` usa apenas Python e a cápsula. O ZIP físico está repartido em blocos de 8 MiB, com identidade conjunta literal e sem alterar o arquivo original.
Os 16 testes finais constam de `tests-final.log`; os retornos observados da auditoria e testes estão em `index.json`.
`python3 -m unittest discover -s tests/functional_creation` verifica oráculos,
fronteira da saída e adulteração. A cópia portátil precisa de `audit.py`,
`pixels.py`, `curves.py` e da pasta `portable-capsule`, sem Git, Qt ou árvore histórica.
Python `-O` é recusado explicitamente. A âncora literal fica fora da cápsula e
recusa também recálculo coerente dos manifestos e identidades interiores.
Não escrever numa raiz já selada. Um novo ensaio exige saída nova e
`run-native-qml-supervised.py --keep-deployment` através do capturador.
