# Validar desenho livre e rodas de desenho

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25, 82

## Aceitação

Inventariar `simplepaint`, `sketch` e `drawing_wheels` pela oferta efetiva de
níveis, modos, ferramentas, fundos, paletas, opções e formatos. Distinguir
percursos de criação livre e níveis apresentados. Não inventar exercícios,
respostas certas ou Bonus num editor livre. Todos os recursos fixos e escolhas
devem ter inventário/verificação; combinações livres não se declaram esgotadas.

Concluir fluxos reais de criação por cada nível/modo e classe de ferramenta
exposta. Desenhar por rato e pelos controlos de teclado oferecidos, mudar
cores/tamanho/fundo/opções, verificar marcas efetivamente pintadas, apagar e
corrigir, desfazer/refazer onde exista e preservar o trabalho nas operações
que o prometem. Nas rodas cobrir os dois níveis e opções distintas, reprodução,
pausa/paragem e resultado geométrico independente das opções desenhadas, sem
alterar temporizadores ou modelos para obter o resultado.

Quando oferecido, guardar, abrir novamente e criar novo desenho pelos diálogos
reais. Verificar o conteúdo físico SVG/PNG e o resultado desenhado depois de
abrir, incluindo nome português com acentos, sempre em perfil e saídas novos.
Não chamar funções internas de guardar/carregar para contornar os controlos.
Não substituir criações ou ficheiros existentes. Não exigir formatos não
oferecidos pela atividade. Cobrir ajuda PT, Escape/foco, reinício parcial,
regresso ao menu durante a criação e depois de guardar/concluir um fluxo e
configuração e seleção de níveis efetivamente oferecida.

O oráculo usa píxeis e geometria observada, equações do desenho quando
aplicáveis e conteúdo dos ficheiros guardados; não lê o histórico interno
como se fosse imagem nem valida apenas contadores. Capturas de widgets devem
ser comparadas com a cena completa para evitar recortes incorretos da API QtTest.
Todo defeito requer o mesmo caso antes/depois, sem acrescentar funcionalidades.

Usar snapshot de 269 ficheiros físico independente, fontes congeladas atomicamente antes
do pool e deployments retidos. Preservar RCC/QM efetivos, extrações físicas,
fontes/PO/casos, imagens/desenhos, retornos reais Qt/supervisor/capturador após
espera. Auditor puro portátil sem Git/Qt/árvore original, âncora externa literal,
negativas físicas/coerentemente recalculadas/vazio, normal e -O ou recusa
explícita, cópia isolada e proteção contra saída existente. Arquivos históricos
ficam intactos. Windows, dispositivos, audição, docente, estabilidade da tarefa 83 e
aceitação global permanecem pendentes.


## Entrega para revisão independente

Review: ready-for-review

[Provas e limites](../functional-creation/README.md),
[proveniência histórica](../functional-creation/resource-provenance.md) e
validações próprias de Simplepaint, Sketch e DrawingWheels em `validation/`.
31 níveis, 61 escolhas da paleta, 23 rotas de ferramentas e dois níveis de rodas,
com criação livre distinta de puzzles. Paletas, opções, padrões e fundos têm
inventário e verificações próprias; as combinações livres não são esgotadas.
Dois defeitos reproduzidos com caso idêntico antes/depois: sete rótulos partilhados
apenas obsoletos no PO e seleção de cor fora da área visível no Simplepaint.
O launcher mantém software por defeito e oferece Xvfb privado para OpenGL/Mesa.

Cápsula física imutável de 43 recibos, incluindo diagnósticos não contados,
RCC/QM/extrações, fontes e casos. Âncora externa literal
`9b8e6aab0aac15a3c9f8bcd73dcaac8b62a0eb7040181f6c874dd51e27ebeb61`.
Auditor portátil `python3 tests/functional_creation/audit.py`, testes de cópia,
adulteração física/coerente, saída existente e recusa de Python -O.
Os retornos externos distintos dos nativos são preservados, inclusive
DrawingWheels controlos Qt/supervisor 0 e capturador 1 por SVG vazio ausente.
Nenhum recibo antigo foi reescrito. Todos os processos nativos terminaram.

Progress permanece claimed até integração e revisões independentes. Windows,
dispositivos, audição, revisão docente, estabilidade 83 e aceitação global pendentes.


## Suplemento de revisão das imagens

Os dois P2 Spec e o P3 Standards têm correção em suplemento independente,
sem novas execuções Qt ou alteração da cápsula original. O auditor suplementar
verifica dez PNG físicos contra cenas completas, os SVG/PNG e a reabertura dos
dois níveis das rodas, o efeito visual de desfazer/refazer e preservação exata
em três cancelamentos. As diferenças de rasterização e tolerâncias estão
explicitadas, com negativas para desenhos vazios/errados e perda de trabalho.
As três ferramentas futuras partilham o helper de compilação/exportação RCC;
as versões históricas permanecem arquivadas intactas.

[Suplemento e métricas](../functional-creation-review/README.md).
Progress permanece claimed, Review ready-for-review para recheck independente.
Não se amplia cobertura nem aceitação global.


A guarda futura adicional recusa symlink pendente e qualquer saída existente
antes de resolver o caminho nas três ferramentas, com cinco testes CLI finais
que preservam link, alvo ausente e bytes existentes. Sem novo Qt ou alteração
da cápsula e capturadores históricos.


## Answer

Resolvida no âmbito Linux finito após integração e rechecks independentes
[Spec e Standards sem achados pendentes](../review/integration89/).
Simplepaint tem 31 níveis e 61 escolhas de cor verificadas; Sketch tem 23 rotas
reais de ferramentas e fluxos de criação, desfazer/refazer, gravar/abrir e fundos;
DrawingWheels cobre os dois níveis, 30 combinações fixas, paragem/retoma e
geometria independente. Não são puzzles nem combinações livres esgotadas.

O [suplemento de revisão](../functional-creation-review/README.md) verifica dez
PNG físicos, reabertura das rodas, desfazer/refazer e preservação em três
cancelamentos. O merger confirmou 31 testes puros finais, sessão 52501,
chunk dde929, retorno 0 após espera. A cápsula literal e todos os recibos e
retornos históricos ficam intactos, incluindo diagnósticos e capturador 1.

Três ligações de evidência no CSV não aprovam nenhuma coluna global. Windows,
Windows da escola, dispositivos, audição, revisão docente/linguística,
estabilidade 83 e aceitação global permanecem pendentes. Sem Qt, build ou push
neste fecho; o teste de arranque principal é uma verificação posterior separada.
