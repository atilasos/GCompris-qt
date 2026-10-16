# Dinheiro e troco em PT-PT

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25

## Aceitação

Inventariar dados e concluir níveis e modos de money, money_cents, money_back e money_back_cents.
Oráculo próprio de cêntimos inteiros. Ler notas, moedas, preços e troco visíveis, operar arrastos/cliques reais. Verificar pagamentos exatos, insuficientes e excessivos conforme o contrato. Cobrir datasets, níveis e modos expostos.

Entradas reais, animações e Bonus naturais. Reinício, ajuda PT, foco,
navegação, seleção persistida e menu conforme aplicável. Conferir recursos QRC
e dados de todas as variantes com identidades históricas exatas. Cada defeito
exige caso nativo idêntico antes/depois. Usar snapshot privado, offline e
perfis novos. Não alterar modelos, progresso, relógios nem chamar soluções.

Ferramenta de auditoria reproduzível e testes de adulteração material, sem
caminhos absolutos de worktrees antigas ou dependência do catálogo corrente.
Provas Linux não aprovam Windows, dispositivos físicos, audição ou pedagogia.
Todos os critérios globais continuam pendentes.

## Answer

Concluídos os quatro jogos nos três conjuntos de dados de cada um, 103 níveis em cada um dos dois modos de validação: 206 puzzles naturais completos, 106 pelo rato e 100 pelo teclado. Há 204 pagamentos insuficientes e 197 excessivos explicitamente executados; os restantes ficam indisponíveis no recibo quando a carteira ou a validação automática impede atingir essa condição sem ganhar antes. Quatro casos separados concluem ajuda PT, foco, reinício parcial, opções e seleção persistidas, navegação circular e menu.

Três defeitos receberam pares nativos de caso SHA-256 idêntico: teclado bloqueado em pagamento automático incompleto, cliques durante feedback de erro e carteira impossível no nível 20 de money_cents. O último foi reproduzido com preços visíveis de 18,39 €; uma nota adicional de 10 € permite pagar todo o envelope conservador de montantes. Auditoria separada demonstra atingibilidade nos 103 níveis; a prova UI não lê o alvo privado. O caso corrigido concluiu mais 12 compras naturais.

[Procedimento, provas e limites](../functional-money/README.md), [correções](../functional-money/fixes.md). Auditor `python3 tests/functional_money/audit.py` fixa a prova histórica `ee3eb60d751c4463f0781560f729dba1aa8354a8`, confere fontes, launcher, catálogo, todos os mapas de QResource e os 269 ficheiros de snapshot por fase. Aceita uma cópia deslocada e rejeita adulterações dos recibos, casos, caminhos, hashes de fonte/RCC/catálogo e manifesto, incluindo reindexação indevida. Onze testes unitários passaram.

Os 18 recibos têm saída normal Qt 0, sem timeout e com propriedade local verificada; três são vermelhos esperados de asserção, quinze verdes. Todos os processos deste lote terminaram e não há PIDs Qt ativos. Os três WAV passaram em GStreamer para fakesink. Windows, dispositivos físicos, audição, acessibilidade e revisão docente continuam pendentes, bem como todos os critérios globais. Não há alterações ao mapa/CSV nem ao build principal.
