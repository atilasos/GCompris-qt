# Jogo do galo e quatro em linha

Status: ready-for-agent
Progress: ready
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
