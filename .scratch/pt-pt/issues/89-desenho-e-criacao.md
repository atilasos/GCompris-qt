# Validar desenho livre e rodas de desenho

Status: ready-for-agent
Progress: open
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
