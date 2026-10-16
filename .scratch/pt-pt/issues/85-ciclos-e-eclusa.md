# Concluir as simulações de água, energia e eclusa

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25

## Aceitação

Inventariar e concluir os percursos apresentados de `canal_lock`, `watercycle`
e os três níveis de `renewable_energy`. Distinguir simulação livre, páginas de
introdução e nível; não inventar um conjunto de exercícios onde não existe.
Usar regras físicas independentes e apenas portas, água, barco, interruptores,
produtores, consumidores, instruções e feedback desenhados para decidir ações.
Não ler estados internos de resposta ou acionar funções do motor para ganhar.

Na eclusa, fazer viagem completa nos dois sentidos e verificar bloqueios reais
de portas incompatíveis. Na água e energia, concluir o objetivo através dos
controlos reais, observar dependências, erro/recuperação e continuação quando
oferecida. Não alterar relógios, velocidade do barco, níveis de água ou energia.
Cobrir introdução, ajuda PT/Escape/foco, reinício parcial e navegação oferecidos,
menu durante atividade e após sucesso; equipamento tátil fica pendente.

Cada defeito exige o mesmo caso antes/depois. Usar snapshot269 independente,
fontes congeladas atomicamente e deployments únicos. Preservar fontes/PO/casos,
QM/RCC efetivos físicos, extrações instrumentadas, imagens e retornos Qt,
supervisor e ferramenta observados após espera. Arquivos históricos intactos.
Auditor puro portátil sem Git/Qt/árvore original, âncora externa literal, recusa
coerente de adulteração/vazio, eficácia em -O ou recusa explícita, e proteção
contra sobreposição de saída antes de qualquer escrita.

Descodificação não é audição; não transferir aprovação32 a outros sons.
Windows, dispositivos, áudio, revisão docente, estabilidade83 e global pendentes.

## Entrega para revisão

Provas e limites em [functional-cycles/README.md](../functional-cycles/README.md).
Oito traduções corrigidas, dois pares lexicais negativos/positivos, três
percursos finitos, três controlos e 18 recibos nativos preservados. Auditor
puro e 13 testes passaram normal e `-O`; cópia física isolada passou sem
Git/Qt/checkout. Revisão independente pendente; não fechar por esta entrega.

## Correção da revisão Spec85

A revisão identificou falta de regresso ao menu após sucesso. Foram acrescentadas
três repetições completas com navegação real, fontes finais, RCC/QM e recibos
novos, sem modificar os 18 históricos. Ver [suplemento](../functional-cycles-menu/README.md).
O suplemento aguarda nova revisão antes de fechar a tarefa.

## Fecho de revisão

P2 corrigido e fechado por Spec recheck e Standards do suplemento, sem
achados acionáveis; [relatórios](../review/integration85/). Resolução limitada
aos percursos Linux finitos publicados, sem aumentar cobertura única ou globais.
