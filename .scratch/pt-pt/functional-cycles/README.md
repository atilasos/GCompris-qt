# Eclusa e ciclos da água e da energia

Prova finita em Linux, com rede desativada e utilizador 1000. O ticket 85
continua sujeito a revisão independente. Não constitui aceitação global,
validação Windows, equipamento tátil, audição ou revisão docente.

| Atividade | Percurso observado | Erro e recuperação |
| --- | --- | --- |
| canal_lock | Uma viagem de ida e volta, duas pernas e 12 ações válidas | Barco bloqueado, comporta com água incompatível e válvulas opostas |
| watercycle | Um ciclo completo, dez etapas e quatro páginas introdutórias | Bombagem sem água recusada, seguida do fornecimento correto |
| renewable_energy | Três níveis e quatro páginas introdutórias | Três tentativas sem potência suficiente e corte natural de grande consumidor após expiração do vento |

As ações usam cliques e teclas reais. O planeador da eclusa usa uma máquina
independente de posições, alturas e interbloqueios. O auditor compara as
observações geométricas com esse plano. Na água verifica evaporação, nuvem,
chuva, rio, bombagem, tratamento, armazenamento, chegada a casa e duche.
Na energia soma os valores W desenhados e verifica consumidores e luzes.
Não modifica relógios, animações, água ou potência para concluir os percursos.
As conclusões produzem cinco Bonus naturais, um na eclusa, um na água e três
na energia. A volta da eclusa descarrega a madeira sem outro Bonus.

As únicas alterações de produto são oito traduções PO. Sete corrigem
"fecho de canal" para "eclusa" e explicam comportas, válvulas e água dentro
da eclusa. Uma substitui o prazo inexistente da água pelas condições do
duche. Os dois pares de casos lexicais têm bytes idênticos antes/depois.
Nenhuma lógica QML ou gravação foi alterada.

## Fontes e retornos

`config.py`, em `tests/functional_cycles`, identifica três fontes congeladas.
Os percursos completos usam `045ff0d763ff89c9ebd6fcb849d11d4495f0b6c7`.
Depois, `58e67c399e4de26d84d02d3d43080a488ed6b9cd` altera apenas a frase
da água. Nessa fonte final foram executados o mesmo caso lexical da água,
os três controlos e o carregamento das imagens. Os três percursos completos
não foram repetidos depois da última alteração de texto.

Os 18 recibos históricos ficam intactos: 11 positivos, dois negativos
lexicais e cinco diagnósticos dos testes. Todos os processos Qt terminaram
com zero. Os sete casos negativos têm retorno externo um. Os retornos do
supervisor foram observados pelo capturador após espera, ligados por SHA
ao recibo, caso e launcher. Nenhum retorno 139 ocorreu neste lote.

Os dois primeiros testes da eclusa mediam a água durante a animação inicial.
Os três primeiros controlos clicavam durante a transição de saída da ajuda.
Os testes finais aguardam estabilização geométrica e `pageView.busy=false`.
Estes cinco negativos são falhas dos testes, não defeitos corrigidos no jogo.

Cada execução conserva RCC e QM efetivos e extrações físicas. Há também cinco
RCC canónicos completos e 271 entradas extraídas. O inventário completo do
runtime tem 269 ficheiros. Os restantes bytes desse runtime e o binário não
estão neste arquivo; a sua identidade fica no manifesto, não numa alegação
de disponibilidade física. As três cápsulas de fonte são físicas.

Foram carregadas 110 imagens, 75 distintas, com `Image.Ready` e dimensões
positivas no Qt. Os 21 sons selecionados foram descodificados pelo GStreamer.
Descodificação não comprova audição nem pronúncia. A aprovação humana das
32 gravações refere-se exclusivamente ao respetivo manifesto anterior.

Os três controlos finais cobrem ajuda, Escape e regresso ao menu; água e
energia reiniciam um estado parcial, e energia percorre os níveis oferecidos.
O JSON antigo de `controls-water2` omite a escala da torre. O caso QML físico
contém e passou `tryCompare(towerfill, 'scale', 0, 3000)`. O auditor portátil
verifica apenas os valores exportados e não recalcula essa escala omitida.
O modelo para futuras execuções passou a exportá-la; o caso histórico mantém-se.

## Verificação reproduzível

Na raiz do checkout:

```sh
python3 tests/functional_cycles/audit.py
python3 -m unittest discover -s tests/functional_cycles -p 'test_*.py'
python3 -O -m unittest discover -s tests/functional_cycles -p 'test_*.py'
python3 tests/functional_cycles/portable.py
```

Os 13 testes passaram nos dois modos. Incluem cópia física independente,
RCC ausente, QM corrompido, recibo e metadados coerentemente resselados,
geometria adulterada, armazenamento insuficiente, aritmética errada, conjunto
vazio e preservação de saídas existentes. A cópia física também passou num
contentor Python sem rede, Git, Qt ou checkout original, normal e `-O`.
O auditor não depende de `assert`.

`index.json` ancora 1010 artefactos com SHA-256. A âncora externa literal do
auditor é `d9751aa922a996aac2143a79e67ad5db6ed629e4bac4f27ea1810d987f9b70d3`.
Não regenerar o índice para aceitar alterações. Esta documentação e as
verificações posteriores não reescrevem as capturas históricas.
