# Cores no Qt nativo

Quatro atividades, com seleção e mistura por eventos de rato/teclado Qt reais.
Requer Python 3, Qt 6, Docker e os helpers de snapshot da tarefa 25.

```sh
python3 tools/native_qml_resources.py --binary /BUILD/bin/gcompris-qt --output build/colors-origin
python3 tests/functional_colors/prepare.py --origin-snapshot build/colors-origin --output build/colors-final
python3 -m unittest discover -s tests/functional_colors -v
python3 tests/functional_colors/run.py --activity colors --resource-snapshot build/colors-final --output build/colors-new
python3 tests/functional_colors/run.py --activity advanced_colors --resource-snapshot build/colors-final --output build/advanced-new
python3 tests/functional_colors/run.py --activity color_mix --resource-snapshot build/colors-final --output build/paint-new
python3 tests/functional_colors/run.py --activity color_mix_light --resource-snapshot build/colors-final --output build/light-new
```

O primeiro comando só lê o build indicado. O preparador recompila cinco RCC
numa pasta privada e cria uma nova cópia física selada, sem referências a
builds mutáveis. Nunca usar um build partilhado como saída. Cada saída de caso
tem de ser nova. `--case controls` verifica a barra, ajuda e menu; `--exit
escape` escolhe Escape. Os quatro jogos não expõem configuração local.
`--case slider-ranges` verifica os três sliders nos seis níveis das misturas.
`--levels 1` é um tracer parcial, separado das campanhas completas.

O vocabulário explícito em `names.json` associa pedidos PT a identidades de
imagens realmente desenhadas. Não é gerado do dataset ou do catálogo durante
a escolha. As traduções raras e a fidelidade perceptiva da paleta conservam
revisão docente própria. `inventory.py` regista os níveis, fills SVG e antigos
comentários hex, sem impor igualdade entre esses comentários e as imagens.

O solver das misturas só lê `target.color`, a cor do retângulo visível.
Não lê targetColor1/2/3 nem chama getColor ou o validador. Inverte o modelo
aditivo RGB ou complementar CMY e opera botões/sliders. A matemática verifica
o modelo do exercício, sem certificar comportamento de tintas físicas.

```sh
python3 tests/functional_colors/inventory.py > /nova/prova/inventory.json
python3 tests/functional_colors/capture.py --snapshot build/colors-final --evidence /nova/prova
python3 tests/functional_colors/audit.py --evidence .scratch/pt-pt/functional-colors --output /tmp/colors-audit.json
```

O capturador compila `rcc_inventory.cpp` privadamente e compara os bytes que
Qt expõe com a fonte, além dos OGG copiados do MediaPlayer com os RCC PT.
O auditor final usa apenas casos/recibos/identidades arquivados, sem depender
de caminhos operacionais antigos. A sua tabela explícita compõe a campanha
original de borboletas com os quatro níveis de texto corrigido. Para uma
nova campanha integral, adaptar essa seleção explícita de provas.

Os casos exatos vermelho/verde de sliders e de vocabulário estão junto dos
recibos. `sliders.qml` demonstra a área sobreposta do botão; `slider-ranges.qml`
demonstra o bloqueio por snapping no terceiro nível. Para repetir a regressão
lexical isolada, passar o `case.qml` arquivado ao launcher normal, num checkout
isolado com o catálogo anterior/corrigido. Não alterar o build principal.

A reprodução MediaPlayer é observada no componente original. Os SoundEffect
sem dispositivo e a audição física têm limites separados. Nenhuma gravação é
alterada. Windows, dispositivos físicos, touch/mobile, pronúncia e aprovação
docente continuam pendentes.

A verificação histórica acrescentada na tarefa 59 exige os objetos Git da
revisão `53c2fe61ea46e950e58752a9e6ef0a71b5e80c31` e os três manifestos
arquivados. Não usa os ficheiros fonte atuais nem os caminhos operacionais
antigos. Guardar nova saída do auditor fora do índice original. Procedimento e
provas em `.scratch/pt-pt/colors-identity59/README.md`.
