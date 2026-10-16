# Orientação espacial e botões do rato

Status: ready-for-agent
Progress: ready-for-review
Type: task
Blocked by: 02, 25

## Aceitação

Inventariar e concluir todos os níveis, conjuntos de dados e modos de
`leftright`, `positions` e `left_right_click`. Interpretar os estímulos realmente
desenhados. Usar relações visuais e um inventário semântico independente dos
recursos, sem ler respostas, estados corretos ou modelos ocultos da atividade.

Cobrir orientações e rotações existentes das mãos, posições relativas e os
botões esquerdo e direito do rato conforme cada atividade. Confirmar resposta
errada, reparação, progressão e conclusão natural, ajuda PT/Escape, foco,
navegação, reinício e seletores apresentados. Verificar a geometria dos gestos
reais e identificar explicitamente se uma falha vem do caso ou do produto.

Usar execução nativa offline privada e fontes congeladas antes da concorrência.
Qualquer defeito exige caso idêntico vermelho e verde. Preservar fontes,
catálogo, casos, recursos efetivos e recibos em arquivos físicos imutáveis.
Registar separadamente os retornos observados do Qt, supervisor e ferramenta.

A auditoria deve funcionar sobre cópia isolada e rejeitar provas adulteradas,
amostras vazias e alterações dos retornos. As verificações permanecem eficazes
com Python otimizado ou recusam explicitamente essa modalidade. Descodificar
áudio confirma leitura por software, sem certificar audição.

Windows 10, dispositivos físicos, revisão pedagógica e linguística docente e
aceitação global permanecem pendentes.

## Answer

80 tarefas primárias concluídas em Qt real offline: 32 mãos em 6 níveis,
26 posições em 4 níveis (2 datasets, 2 modos) e 22 animais em 3 níveis, com
13 erros reparados e
conclusões naturais. As respostas vêm de anotação anatómica dos oito recursos,
geometria/camadas visíveis e semântica peixe/macaco; não de respostas do motor.
Controlos finais: ajuda PT/Escape/foco, navegação/reposição, seletor de posições
reaberto, reinício oferecido no rato e regresso ao menu.

Corrigidos destinos visuais presos aos papéis transitórios do modelo do rato
(18714982c) e manual PT que confundia respostas no ecrã com os botões físicos
do rato (25f91ab4b), ambos com casos idênticos vermelho/verde. Não se alterou
política pedagógica, áudio ou gravações.

[Arquivo físico e limites](../functional-orientation/README.md): fontes/catálogos,
RCC efetivos e 11 recibos, com retorno 0 do Qt separado dos nove retornos externos 0 e dois
vermelhos 1 efetivamente observados após espera. Auditor puro normal/-O e 15 testes
passaram, incluindo cópia isolada e adulterações resealadas. [Verificação](../functional-orientation-verification/README.md).

Nenhum processo pendente; pronto para merger e revisões independentes.
Windows 10, dispositivos, audição, docente e aceitação global permanecem pendentes.

## Integração

Provas integradas para Standards e Spec independentes. `ready-for-review`
não representa resolução final ou aceitação global. Extrações Qt históricas
foram preservadas byte a byte, incluindo espaços finais.
