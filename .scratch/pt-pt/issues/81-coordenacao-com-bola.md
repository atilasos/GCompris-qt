# Coordenação com a bola

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25

## Aceitação

Inventariar e concluir todos os níveis de `ballcatch` e `penalty`. Usar inputs
Qt reais e observar mãos, bola, alvo, barras de progresso, instruções e feedback
desenhados. Verificar sucesso, atraso ou tentativa incompleta, recuperação e
progressão natural. Não ler estados de vitória, respostas, temporizadores,
limiares ou modelos internos para decidir os inputs ou certificar resultados.

Cobrir os inputs apresentados, incluindo setas e mãos clicáveis no apanha-bola
e zonas e botões do rato no penálti. Distinguir cobertura das alternativas de
entrada do produto cartesiano de todas as combinações possíveis. Confirmar os
contratos públicos dos níveis, ajuda PT/Escape, foco, navegação, reinício e menu
conforme a interface. Não alterar relógios, velocidades ou estados do jogo.

Usar snapshot offline privado e fontes congeladas antes da concorrência.
Qualquer defeito exige caso idêntico vermelho e verde. Preservar fontes,
catálogo, casos, recursos efetivos e retornos observados do Qt, supervisor e
ferramenta externa. A auditoria física deve funcionar sobre cópia isolada,
recusar adulteração e cobertura vazia e manter verificações eficazes com Python
otimizado ou recusar explicitamente essa modalidade.

Windows 10, dispositivos físicos, toque real, audição, revisão docente e
aceitação global continuam pendentes.

## Answer

Implementação entregue para revisão independente: 27 rotas concluídas,
18 níveis únicos, 27 erros reparados e controlos públicos. Cinco pares idênticos
vermelho/verde corrigem totais públicos, duas ajudas e barras que sobreviviam
à navegação. Auditor puro de 15 recibos, cinco fases físicas, RCC/QM/sons/casos e
retornos efetivamente observados; testes de cópia, adulteração/reseal/vazio/-O.

O original penalty-complete **não é verde**: Qt139/supervisor1/ferramenta1,
mesmo com asserções 0 e nove níveis. A repetição exata passou normalmente e duas
repetições gdb não reproduziram. Journal/símbolo local delimitam uma ocorrência
em GC QtQml, sem provar causa. O coordenador indicou tarefa própria para o
encerramento antes de aceitar estabilidade global. Resolved regista a entrega
desta implementação, não resolve essa pendência nem a aceitação global.

Ver [provas/limites](../functional-ball/README.md),
[ballcatch](../validation/ballcatch.md) e [penalty](../validation/penalty.md).
Windows, dispositivos, toque, audição e revisão docente pendentes.

Pendência de encerramento: [tarefa 83](../issues/83-encerramento-penalty.md).
