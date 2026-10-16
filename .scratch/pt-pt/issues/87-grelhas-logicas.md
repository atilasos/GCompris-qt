# Concluir Sudoku e Calcudoku por regras independentes

Status: ready-for-agent
Progress: open
Type: task
Blocked by: 02, 25

## Aceitação

Inventariar todos os conjuntos configuráveis, níveis e subníveis de `sudoku`
e `calcudoku`, distinguindo tabuleiros fixos e gerados. Completar em Qt Linux
um percurso por cada nível/conjunto oferecido e todos os tabuleiros finitos
fixos apresentados nesse percurso. Não prometer esgotar a geração aleatória.

Resolver usando apenas símbolos/números, posições e pistas desenhadas. Em
Sudoku usar unicidade de linhas, colunas e regiões efetivamente apresentadas;
não presumir caixas 3×3 nas grelhas pequenas. Em Calcudoku usar linhas/colunas,
limites das regiões, alvos e operadores visíveis. Resolver num módulo puro
independente, sem consultar grelhas de solução, campos ocultos, validação do
motor ou funções de vitória. Usar controlos reais para colocar e corrigir.

Cobrir erro/recuperação por nível, conclusão natural, continuação, ajuda PT,
Escape/foco, reinício parcial, menu e configuração/seleção de conjuntos.
Cada defeito exige o mesmo caso negativo/positivo antes/depois. Confirmar
português europeu em instruções e termos matemáticos. Não alterar conteúdos
corretos nem gravações aprovadas por conveniência dos testes.

Usar snapshot269 físico independente, fontes congeladas atomicamente antes
das campanhas e deployments únicos. Preservar RCC/QM efetivos e extrações,
fontes/PO/casos, geometria/pistas e ações, imagens e retornos reais do processo
Qt, supervisor e capturador após espera. Não substituir nem resselar provas
históricas para aceitar uma correção posterior.

Auditor puro portátil sem Git/Qt/checkout original, âncora externa literal,
recusa de vazio e adulteração coerente, testes normais e -O ou recusa explícita,
cópia física independente e proteção contra saída existente. Windows,
dispositivos, audição, revisão docente e estabilidade83 permanecem pendentes.
