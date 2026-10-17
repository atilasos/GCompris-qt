<!-- SPDX-FileCopyrightText: NONE -->
<!-- SPDX-License-Identifier: CC0-1.0 -->
# Revisão final da integração CRJM

Comparação revista: `620fde9e5...9dfb5b79421f0b78534303941c5d4eb9310c89e0`.
As duas revisões foram independentes e estáticas. Leram o código e a evidência
nativa da tarefa 18. A restrição de contribuições do README não se aplica a esta
integração privada no fork, conforme o âmbito aprovado.

## Normas

Zero violações de normas documentadas. A revisão identificou três observações
heurísticas de manutenção P3. Todas foram tratadas nesta etapa.

| Observação | Alteração |
| --- | --- |
| Nex repetia geometria em vitória, distância e candidatos | Uma tabela de adjacência local ao módulo calcula os seis vizinhos, na mesma ordem e com os mesmos limites. Os três percursos usam essa tabela. |
| Quelhas repetia elegibilidade de pares em `hasMove` e `pairs` | O predicado privado `eligiblePair` concentra a elegibilidade. `hasMove` continua a devolver `true` no primeiro par disponível. |
| `rare` não descrevia o efeito | A função exportada chama-se `resolveSpecialEnding`; o chamador foi migrado e a API anterior foi removida. |

A alteração mantém a indexação, a ordem dos vizinhos e candidatos, os critérios
de vitória e a precedência dos finais especiais. Não introduz um motor comum
entre jogos. A evidência está em `evidence/review-fixes/`.

## Especificação

Zero desvios funcionais confirmados. A revisão encontrou os oito jogos nativos,
modos de duas pessoas e Tux, políticas locais limitadas, aprendizagem, pistas,
revisão, ajuda e reinício. Não identificou expansão de âmbito não autorizada
nem uma implementação demonstravelmente incorreta dos requisitos.

Os relatórios integrais de ambos os eixos acompanham esta nota em
`evidence/review-fixes/standards.md` e `spec.md`.

## Validação após a revisão

Esta é a fase de refactor da revisão, após a implementação e os testes de
aceitação. Não se inventou uma falha funcional nem se criaram testes acoplados
às novas funções privadas. Os quatro casos Qt existentes de Nex e Quelhas
verificam o comportamento na fronteira aprovada, desde o menu real.

Os quatro percursos passaram, sem falhas, erros QML ou eventos OOM.
Os dois RCC foram novamente compilados pelo CMake a partir desta worktree.
Os quatro casos usam esses RCC sem `--extra-activity`, offline e com cota
virtual de 1 CPU e 512 MiB. A matriz completa de 18 casos da tarefa 18 permanece
como evidência dos restantes recursos, cujo conteúdo não mudou. O manifesto
final e a relação com o manifesto anterior ficam na evidência desta revisão.

Tablet físico, equipamento escolar, som físico e observação com crianças
continuam pendentes. Não houve publicação nem autorização de distribuição
externa decorrente desta revisão.
