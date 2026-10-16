# Contagens públicas dos níveis

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25

## Aceitação

Investigar os candidatos do relatório [relatório estático](../public-level-contracts/public-level-candidates.md). São
hipóteses estáticas, sem defeitos confirmados. A tarefa 81 reproduziu o padrão
em dois jogos: a barra percorria nove níveis, mas `activity.numberOfLevel`
permanecia zero. Esse contrato é usado pelas sequências de atividades.

Reproduzir cada candidato no Qt nativo antes de corrigir. Confirmar que existe
um seletor de níveis da atividade, que o total publicado está incorreto e que
o arranque terminou. Um tutorial ou modo sem níveis pode usar zero
legitimamente. Registar exclusões com a respetiva evidência. O galo e o penálti
ficam fora desta tarefa, pois as tarefas 80 e 81 já tratam esses casos.

Para cada defeito confirmado, preservar um caso idêntico vermelho e verde,
com total público, nível atual, seletor desenhado e navegação real. Usar uma
única origem da contagem e respeitar os modos sem seletor, as heranças e os
conjuntos de dados existentes. Não alterar regras, respostas ou dificuldade.
As contagens esperadas vêm do inventário de fontes, sem soluções ocultas.

Usar snapshots offline privados, fontes congeladas antes da concorrência e
arquivos físicos com fontes, casos, recursos efetivos e retornos observados do
Qt, supervisor e ferramenta. Criar uma verificação reproduzível que impeça a
reintrodução do padrão incorreto, com testes de adulteração e cópia isolada.

Esta tarefa verifica metadados e navegação. Não acrescenta conclusões de jogos
à cobertura funcional nem aprova colunas globais do CSV. Windows, dispositivos,
áudio e revisão docente continuam pendentes.

## Answer

Confirmados e corrigidos contratos públicos de níveis em 24 atividades/variantes,
sem alterar regras, respostas ou dificuldade. Os casos preservados usam o
seletor desenhado e cliques reais 1 → 2 → 1; os mesmos casos falham antes e
passam depois. Em polígonos/tutorial também foi corrigida a publicação do nível
atual. Damas a dois e polígonos/livre mantêm total zero sem seletor.

O [relatório e limites](../public-level-contracts/README.md) descreve o arquivo
físico compacto com 24 pares vermelho/verde e dois controlos, recursos Qt
extraídos, fontes congeladas e retornos observados separadamente. Auditor puro
normal e otimizado, sete adulterações com selo recalculado, cópia sem árvore
original/Git/ferramentas Qt/rede e guarda de regressão passaram.

Não foram acrescentadas conclusões funcionais nem alterações ao CSV. Galo e
penálti continuam nas tarefas 80/81. O manifesto de 269 recursos está preservado;
a cápsula compacta não inclui o runtime completo necessário a repetir Qt.
Windows, equipamento, áudio, pronúncia e revisão docente continuam pendentes.
