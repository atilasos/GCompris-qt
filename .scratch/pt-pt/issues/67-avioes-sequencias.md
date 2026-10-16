# Sequências numéricas e alfabéticas com avião em PT-PT

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25

## Aceitação

Inventariar dados e concluir níveis/modos de planegame, numbers-odd-even e
alphabet-sequence. Oráculo próprio de ordem numérica, paridade e alfabeto
português por caracteres realmente desenhados. Quando o próximo alvo está
oculto, não ler score.message, dados internos ou soluções para o descobrir.

Movimento real por teclas/gestos expostos, captura certa/errada, animações e
Bonus naturais. Não modificar nuvens, posições, velocidades, relógios ou
progresso. Verificar tutorial completo por UI, maiúsculas/minúsculas, modos
com/sem indicação, reinício, ajuda PT/Escape, foco, navegação e menu.

Recursos QRC/dados/áudio inventariados, snapshot privado offline. Usar
supervisor pós-espera e validar retorno externo ligado ao SHA do recibo.
Fontes, catálogo, casos, lançador/supervisor e recursos ancorados em Git
imutável; rejeitar adulteração com hashes recalculados e provar cópia sem
caminhos antigos. Casos idênticos vermelho/verde para defeitos.

Descodificar áudio não equivale a ouvi-lo ou aprovar pronúncia. Aceitação
global, Windows 10, dispositivos físicos e revisão docente continuam pendentes.

## Answer

Concluídos os quatro níveis de cada atividade por movimento e colisões naturais: sequência numérica 44 capturas, paridade 42 e alfabeto 104, total de 12 níveis e 190 capturas. Os dois últimos níveis de cada jogo ocultam a indicação; o solver só usa textos desenhados e ordem própria, sem ler `score.message`, respostas/modelos privados nem alterar posições, velocidades, relógios ou progresso. Três casos de controlos verificam setas reais, erro/tempestade e recuperação, reinício por navegação, volta circular, ajuda PT/Escape, foco e menu.

O tutorial da paridade foi percorrido integralmente pela UI, oito páginas e três exercícios com erro/correção por cálculo de resto. Um segundo percurso completo confirma teclado após Iniciar e depois de ajuda/Escape sem forçar foco. Não duplica a contagem de capturas.

Única mudança de produção: uma tradução PO de AlphabetSequence repõe k, w e y no alfabeto português moderno. Fonte normativa e pares em [alphabet-fix.md](../functional-planes/alphabet-fix.md). O vermelho nativo definitivo observa l quando o oráculo espera k; o mesmo caso corrigido conclui as 104 capturas, com minúsculas/maiúsculas e indicação oculta. As quatro tentativas diagnósticas de desenvolvimento do controlador ficam preservadas, sem serem aprovadas nem contadas como percursos completos.

[Provas, índice, reprodução e limites](../functional-planes/README.md). Os 13 recibos têm Qt 0 sem timeout; oito verdes exigem lançador/supervisor pós-espera 0, o vermelho lexical e quatro diagnósticos têm retorno externo 1. Cada estado externo liga-se ao SHA do recibo, caso e lançador. Todos os processos terminaram, sem PIDs Qt ativos e com propriedade local dos ficheiros verificada.

Auditor `python3 tests/functional_planes/audit.py` fixa a prova histórica `db1119f63b9c93dacd5839bdc4a7f53c7db4213f` e confronta fontes, catálogo, launcher/supervisor, QResource e snapshots com identidades imutáveis. Vinte e um testes passaram, incluindo cópia deslocada, caminhos/hashes adulterados com reindexação coerente, caso/recibo/estado externo recalculados e recusa de recibo nativo verde com lançador falhado.

Snapshot privado de 269 ficheiros; 237 fontes inventariadas, quatro RCC canónicos e dois assets externos conferidos. Quarenta e sete vozes preexistentes e o efeito de erro passaram em GStreamer para fakesink, sem regeneração. Audição, pronúncia, Windows 10/11, dispositivos físicos, acessibilidade e revisão docente continuam pendentes; a aprovação das 32 adições de outro lote não se transfere. Não houve escrita no build principal, mapa ou CSV nem push. Todos os critérios globais continuam pendentes.

## Integração

Provas integradas; aguardam Standards e Spec independentes. Estado
`ready-for-review` limitado ao lote Linux, sem resolução final ou global.

## Fecho de revisão

Standards e Spec sem achados acionáveis; relatórios em `../review/integration67/`.
Resolução limitada à prova Linux; critérios globais permanecem pendentes.
