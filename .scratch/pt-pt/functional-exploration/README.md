# Provas Linux das quatro atividades de exploração

A tarefa 84 percorreu todas as apresentações e perguntas oferecidas nas quatro
atividades em português de Portugal. A produção muda apenas o catálogo PT:
86 mensagens revistas. Ajuda, nomes, ortografia, factos e perguntas receberam
correções demonstradas antes e depois. Não há alterações de regras ou respostas
nos modelos internos. A revisão docente continua pendente.

| Atividade | Mapas | Apresentações | Perguntas | Avanços naturais/Bonus |
| --- | ---: | ---: | ---: | ---: |
| explore_farm_animals | 1 | 9 | 18 | 3 |
| explore_world_animals | 3 | 15 | 15 | 6 |
| explore_world_music | 1 | 9 | 18 | 3 |
| explore_monuments | 9 | 65 | 65 | 18 |
| Total | 14 | 98 | 116 | 30 |

O número na barra seleciona o mapa. O Score identifica a fase: apresentações,
reconhecimento por som quando oferecido e reconhecimento por texto. Cada
pergunta recebe uma resposta correta; a primeira de cada questionário recebe
também um erro, recusa sem avanço e reparação. Isso perfaz 16 grupos de erro/reparação.
As fases sonoras incluem repetição. A última vitória regressa naturalmente ao
primeiro mapa e à fase de apresentações.

O oráculo aprende títulos, descrições, fotografias, posições e sons nas
apresentações efetivamente abertas. As respostas usam os enunciados públicos e
esse conhecimento. Os casos não leem índices de perguntas nem respostas dos
modelos internos. As 98 fotografias foram inspecionadas visualmente e comparadas
com os nomes/mapas registados. O auditor verifica essas identidades contra o
registo independente `lessons.json`; isso não substitui uma revisão docente.

Os quatro casos de controlos abrem a ajuda PT, fecham com Escape, verificam o
foco, reiniciam uma fase parcialmente visitada, navegam entre fases e mapas,
verificam uma tecla sem ação e regressam ao menu com Ctrl+W. A configuração não
é oferecida nestas atividades e não é inventada como modo adicional.

As correções incluem didgeridoo, papilas gustativas, hábitos noturnos, nomes de
monumentos, tradução de arenito/habitações nas falésias, unidades de área e
concordâncias. Os [factos verificados](source-facts.md) distinguem correções da
tradução e exceções factuais em relação à fonte inglesa.

As provas têm três gerações independentes e imutáveis:

| Raiz | Observações | SHA256 do sealed.json, ancorado fora da prova |
| --- | --- | --- |
| archive | 20 execuções: 7 pares vermelho/verde e campanhas/controlos finais | b0e234b0267060428c1b1bbc62b3cac0045456e0b7f95fc5ceff7c9c96a0d720 |
| supplement-archive | Par idêntico com 6 painéis: geografia, arenito e habitações | 765b2a4250614ed298ef58bb2a147df108febf39a950703200a4a1b0a1a7ed5c |
| supplement2-archive | Par idêntico com 8 painéis: unidades, materiais, concordâncias e Meidum | 75e6dd5028d64dcdf3e6e18a3fb948aa2f3820af6d5dbf44f3e0707212f48437 |

Cada vermelho tem uma falha de asserção esperada e retorno externo 1; cada verde
tem retorno externo 0. O processo Qt termina 0 em todas as 24 execuções selecionadas.
Os recibos preservam separadamente os retornos observados do lançador,
supervisor e ferramenta. Os suplementos mudam apenas descrições já visitadas;
títulos, perguntas, posições e regras permanecem iguais. Não acrescentam jogos
concluídos nem repetem as quatro campanhas.

Cada raiz conserva PO/fontes/ferramentas congeladas, casos exatos, imagens PNG,
logs brutos, recibos, QM/RCC efetivamente carregados e extrações auditáveis.
A cápsula principal conserva também os RCC importados e os 30 recursos sonoros
realmente observados. Todos esses sons foram descodificados. Nenhum coincide
com um ficheiro do manifesto das 32 vozes aprovadas; não há aprovação humana
transferida para música, sons de animais, feedback ou vozes antigas.

O snapshot independente tem 269 ficheiros. A cápsula conserva o manifesto e os
bytes usados para auditar as observações, mas não os 934 MB do ambiente completo.
É portátil para verificação histórica; executar novamente Qt exige recriar o
ambiente completo. As referências absolutas nos recibos são históricas e o
auditor não as abre.

Os testes adversariais alteram cópias. Um ataque substitui o PO e recalcula o
tar, manifestos, recibos, hashes e selo de forma coerente. A âncora externa
literal recusa essa cópia. Outro caso esvazia as campanhas e demonstra que a
validação de cobertura recusa mesmo um selo confiável. O executor recusa uma
saída existente antes de escrever e o teste compara todos os bytes anteriores.
As 11 verificações passam no Python normal e com `-O`, incluindo numa cópia Docker
sem rede, Git, Qt ou árvore original; os retornos reais estão em
[portable-verification.json](portable-verification.json).

Windows 10/11, equipamento escolar, audição humana, pronúncia e aceitação docente
estão pendentes. Os dois pares legados da tarefa 44 não foram aplicados.
As campanhas demonstram cada item e fase nas ordens realmente observadas, sem
alegar todas as permutações aleatórias possíveis ou aceitação global PT-PT.
