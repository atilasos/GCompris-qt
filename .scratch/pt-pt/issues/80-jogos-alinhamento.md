# Jogo do galo e quatro em linha

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25

## Aceitação

Inventariar e jogar até ao fim todos os níveis e modos de `tic_tac_toe`,
`tic_tac_toe_2players`, `align4` e `align4_2players`. Reconstituir o tabuleiro a
partir das peças e posições efetivamente desenhadas. Determinar jogadas legais,
linhas vencedoras, empate, alternância e resultado por regras independentes.
Não ler modelos, vencedor, estado de vitória, respostas da IA ou soluções
ocultas. A pontuação e o feedback desenhados são resultados observáveis.

Uma derrota válida contra a IA pode concluir uma partida. Distinguir vitória,
derrota e empate e não prometer vencer uma IA perfeita. Nos modos de dois
jogadores, executar percursos finitos que cubram os vencedores apresentados e
o empate quando aplicável. Verificar jogadas ilegais sem alterar o tabuleiro,
turnos, conclusão natural, pontuação, reinício parcial, navegação, teclado,
ajuda PT/Escape, foco, opções e menu conforme cada interface.

Usar snapshot offline privado, fontes congeladas antes da concorrência e casos
idênticos vermelhos e verdes para qualquer defeito. Preservar fontes, catálogo,
casos, recursos efetivos e os retornos observados do Qt, supervisor e ferramenta
externa. A auditoria física deve funcionar sem Git, Qt ou caminhos anteriores,
recusar adulteração e cobertura vazia e manter verificações eficazes sob Python
otimizado ou recusar explicitamente essa modalidade.

Windows 10, dispositivos físicos, audição, revisão docente e aceitação global
continuam pendentes.


## Answer

42 partidas terminadas e 506 colocações verificadas por regras independentes do tabuleiro SVG desenhado. Cinco níveis IA do galo e seis de quatro-em-linha, ambos os jogadores iniciais; nos dois modos com amigo, quatro direções por ambos os vencedores e dois empates cada. Sem datasets nem seletores de nível com amigo. Quatro controlos completos; pontuação, alternância, recusa de jogadas ilegais, reinício parcial, anterior/seguinte e wrap, teclado exposto, ajuda PT/Escape, foco e menu.

Correções reproduzidas por mesmos casos vermelhos/verdes: três frases PT, publicação inicial dos cinco níveis do galo, empate prematuro de quatro-em-linha com 40/39 peças, e coluna do teclado calculada antes de Grid ter layout após reinício. Arquivo físico com quatro fases e 982 fontes, três inventários de snapshots físicos de 269 ficheiros, quatro WAV descodificadas sem audição. As 42 partidas anteriores são compostas explicitamente com os verdes finais dirigidos do layout, sem atribuir-lhes nova execução integral.

[Provas e limites](../functional-alignment/README.md). Auditor físico portátil sem Git/Qt/caminhos históricos, âncoras literais, negativas de cobertura vazia/fonte/catálogo/caminho/caso/status e adulteração coerente com novo selo; Python -O recusado. Retornos Qt, launcher, supervisor e ferramenta observados separadamente. Os quatro diagnósticos de parser interrompidos operacionalmente (Qt137, externos1) são preservados e não contam para cobertura. Todos os processos nativos terminaram antes da entrega. Windows, dispositivos físicos, audição e revisão docente permanecem pendentes.

## Integração

Provas integradas para Standards e Spec independentes. Estado
`ready-for-review`, sem resolução final ou aceitação global.

## Revisão independente

P2 de preservação física corrigido em suplemento, com SHA históricos exatos
e provas anteriores intactas. Standards suplementar e Spec recheck sem
achados restantes; [relatórios](../review/integration80/README.md).
Resolvida no âmbito Linux finito; Windows/hardware/áudio/docente/global pendentes.
