<!-- SPDX-FileCopyrightText: NONE -->
<!-- SPDX-License-Identifier: CC0-1.0 -->
Não encontrei violações de normas documentadas. A restrição de contribuições com IA do README é afastada explicitamente pela especificação deste fork. Excluí regras já verificadas por ferramentas, como REUSE e formatação.

As seguintes observações são heurísticas de manutenção, não erros funcionais demonstrados:

- **P3, possível Duplicated Code**, `src/activities/nex/nex.mjs:10`, também linhas 49 e 64. Os três percursos repetem `for (const [dx,dy] of [[1,0],[-1,0],[0,1],[0,-1],[1,-1],[-1,1]])`, a conversão de coordenadas e os limites do tabuleiro. A definição de vizinhança usada na vitória pode divergir da usada pela avaliação e pelas pistas. Concentrar a geometria numa tabela de adjacência local ao Nex permitiria às três funções usar os mesmos vizinhos, sem criar um motor transversal aos jogos.

- **P3, possível Duplicated Code**, `src/activities/quelhas/quelhas.mjs:19` e `:37`. `hasMove` e `pairs` repetem `var other = i + (vertical ? 10 : 1)` e o predicado `other < 100 && (vertical || i % 10 < 9) && !board[i] && !board[other]`. Uma alteração futura pode fazer a deteção do fim da partida discordar da avaliação das opções. Uma pequena função de elegibilidade partilhada preservaria a saída antecipada de `hasMove`.

- **P3, possível Mysterious Name**, `src/activities/nex/nex.mjs:28`. `export function rare(board, own)` não indica que resolve finais especiais, modifica uma cópia do tabuleiro e calcula o vencedor. O comentário explica esse contrato, mas os chamadores precisam de o procurar. Um nome como `resolveSpecialEnding` tornaria a operação explícita.

Total: zero violações documentadas e três observações heurísticas P3. Não identifiquei um bloqueio de integração neste eixo.
