# Puzzles deslizantes de quinze e dezasseis peças

Status: ready-for-agent
Progress: ready-for-review
Type: task
Blocked by: 02, 25

## Aceitação

Inventariar e concluir todos os níveis e modos de `fifteen` e `sixteen`, incluindo
os controlos comuns de `fifteen`. Reconstituir o tabuleiro a partir dos números
visíveis e das posições desenhadas. Calcular e executar movimentos legais por
um algoritmo independente, sem ler modelos, solução, histórico de mistura ou
listas internas de dicas.

Uma dica realmente apresentada ao jogador pode ser usada como entrada visível.
Nesse caso, documentar o seu uso e verificar independentemente a transformação
do tabuleiro, o sentido do movimento e a ordem final. Não contar uma resolução
com dicas como execução sem dicas. Cobrir as opções e o teclado apresentados,
movimentos sem vitória e reparação, reinício parcial, ajuda PT/Escape, foco,
navegação, dicas, Bonus e menu conforme a interface existente.

Usar snapshot nativo offline privado, com fontes congeladas antes da
concorrência. Qualquer defeito exige caso idêntico vermelho e verde. Preservar
fontes, catálogo, casos, recursos efetivos e recibos em arquivos físicos
imutáveis. Registar separadamente os retornos observados do Qt, supervisor e
ferramenta externa, sem inferir um a partir do outro.

A auditoria deve funcionar numa cópia isolada e rejeitar provas adulteradas,
sequências vazias e retornos alterados. As verificações permanecem eficazes com
Python otimizado ou recusam explicitamente essa modalidade. A descodificação de
áudio confirma leitura por software, sem certificar audição.

Windows 10, dispositivos físicos, revisão docente e aceitação global continuam
pendentes.

## Answer

Concluídos os 14 níveis de cada atividade, sem datasets configuráveis. O quinze
usa busca independente por etapas no tabuleiro desenhado: 383 movimentos de
resolução sem dicas. O dezasseis usa apenas a seta efetivamente realçada da
dica, com rotação conferida independentemente: 115 movimentos, explicitamente
com dicas. São 28 conclusões naturais, incluindo sete níveis numerados e sete
só com imagem por atividade, mais 56 alterações não resolventes e inversas.
Tabuleiros reconstruídos pela geometria e pelos recortes SVG desenhados, com
texto conferido quando exposto. Sem modelos, `val`, `value`, histórico ou
listas internas de dicas.

Controlos e caso adicional demonstram cliques, arrastos, teclado, seleção de
setas, Espaço/Return, dica ligada/desligada, Recarregar parcial no dezasseis,
reinício parcial por navegação no quinze, volta circular, ajuda PT/Escape,
foco e menu. Não há validação errada por botão nem Bonus negativo nestes jogos;
a alteração legal não resolvente mantém o puzzle em curso.

A ajuda do quinze passou de vermelho para verde no mesmo caso após corrigir
um `msgstr` com "todas as peças ... movrt". A inspeção visual revelou inglês nas
placas da paisagem costeira. Uma variante PT altera só os três rótulos para
"Rota", "Costeira" e "milhas", preservando número 125, geometria e original.
A seleção segue o padrão de locale existente; o mesmo caso dirigido passou de
vermelho para verde nos dois consumidores e um ensaio en_US mantém o original.
Não se reclassificam as 28 conclusões anteriores como campanha completa na
arte final: a prova compõe esses percursos com ajuda e arte dirigidas.

Vinte recibos nativos terminados, Qt 0 em todos. Onze provas verdes têm retorno
externo do launcher, supervisor e ferramenta 0. Nove vermelhos/diagnósticos
preservam externos 1; não contam como aprovação. Fontes congeladas antes das
execuções, snapshot privado físico de 269 ficheiros e arquivo físico de três
fases com 673 entradas. Auditor sem Git ou caminhos históricos, cópia isolada,
rotas vazias/adulteração/re-selagem recusadas, Python `-O` recusado. Os 14 testes
unitários e o auditor passam. Dois WAV descodificados em software, sem alterar
áudio ou aprovações.

[Provas, procedimento e limites](../functional-sliding/README.md).
Uma mistura aleatória normal por nível, sem esgotar as permutações possíveis.
Windows 10/11, audição, dispositivos físicos, acessibilidade e revisão docente
continuam pendentes. Nenhum critério global foi aprovado por este lote.

## Integração

Provas integradas para Standards e Spec independentes. `ready-for-review`
não representa resolução final ou aceitação global. A composição do baseline
funcional com provas PT dirigidas não equivale a nova execução final de 28 níveis.
