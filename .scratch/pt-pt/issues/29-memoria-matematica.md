# Validar a memória matemática

Status: ready-for-agent
Progress: claimed
Type: task
Blocked by: 02, 21, 25

## Âmbito

As catorze variantes memory-math, incluindo as sete variantes contra Tux.
Dados completos, contas/respostas independentes, todos os níveis e modos expostos,
pares certos/errados, turnos, pontuação, bloqueio, transições e conclusão por Qt
real. Sem manipular pontuação, duração ou correspondência do motor para resolver.
Cobrir navegação, ajuda PT, reinício e retorno ao menu; distinguir fixtures de
gestos não testados. Reusar os snapshots selados e a infraestrutura de 21.
Windows, audição, hardware e aceitação docente permanecem critérios separados.

## Comments

- Início em `8f2675d54`, worktree `pt-functional-memory-math`. Seams autorizados:
  dados originais/Qt, eventos reais nas cartas/teclas, Score/Bonus, turnos e
  configuração pedagógica pelo ciclo normal de carregar datasets e stop/start.
  A configuração da seleção de tabelas/modo é uma fixture explícita; não será
  apresentada como cobertura de todos os gestos do diálogo de opções.
- Inventário confirmado: 138 datasets, 14 variantes. `mult-div` e `mult-div-tux`
  têm nove tabelas, de 2 a 10; as outras variantes têm dez, de 1 a 10. O lote
  completo corresponde a 207 percursos nível/modo antes de eventuais repetições.
- As contas usam oráculo independente por contagem e relações inversas. Três
  testes Node passam, com 3748 pares em duas ordens de mistura, ambas as ordens
  dos operandos e rejeição explícita de respostas erradas/duplicadas.
- Lote nativo em execução com snapshot próprio, cópia integral e selada de 269
  ficheiros, core/memory e 14 RCC de dados recompilados privadamente. Nenhum
  binário ou RCC do build principal foi alterado.
