# Validar Descobrir a palavra e Letra na palavra

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 04, 25

## Âmbito

hangman e letter-in-word: todos os datasets, níveis e modos expostos.
Verificar dados PT, palavras e acentos, respostas corretas/erradas, teclados
físico simulado e visual quando expostos, maiúsculas/minúsculas, mensagens,
pontuação/Bonus/transições e conclusão por eventos Qt reais. Oráculo separado
da lógica de correspondência do jogo. Não substituir fonemas nem alterar
políticas pedagógicas sem identificar o comportamento atual.

Cobrir ajuda, reinício, navegação e menu, perfis privados e rede desligada,
recursos selados. Nos elementos aleatórios, auditar o corpus completo e declarar
a amostragem das interações. Não simular correspondências/pontuação.
Windows, audição física, dispositivos e professor permanecem pendentes.


## Answer

Matrizes Linux Qt offline concluídas: Hangman116 campanhas/4824 palavras,
todas as23+6 lições e quatro modos de pistas; Letra na palavra174 campanhas/
1740 perguntas,23+6 lições,5/11 cartões e três capitalizações. Oráculos
independentes aprovados; amostragem de tabuleiros aleatórios explicitada.
Controles, derrota e acentos/preedit/commit exercitados por eventos reais.
1090 imagens e1090 gravações PT localizadas na aplicação.

Corrigidos nove espaços exteriores do corpus, publicação do total de níveis
de Letra na palavra e reinício do contador de Hangman, com provas anteriores/
posteriores preservadas. A retoma conservou oito lições/modos completos e
executou só as108 combinações restantes depois de confirmar que o processo
anterior tinha parado. Os PIDs e o fim real com saída0 foram observados;
não se confia na sobrevivência de sessões após finalizar um turno.

Índice final e limites em `../functional-word-letters/index.json` e README.md.
Sem aprovação Windows, dispositivos, audição/pronúncia ou docente. Os dois
pares semânticos suspeitos permanecem separados na tarefa44. Isto não declara
funcionais/concluídas as203 atividades globais.
