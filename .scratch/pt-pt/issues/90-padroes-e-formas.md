# Concluir padrões, mosaicos e polígonos por geometria visível

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25, 88

## Aceitação

Inventariar os conjuntos, níveis, modos e tabuleiros de `redraw`,
`redraw_symmetrical`, `mosaic` e `polygons` pela aplicação e pelos recursos
físicos. Distinguir conteúdo fixo de geração aleatória; percorrer todo o
conteúdo fixo e todos os níveis/modos, declarando limites de amostragem onde
existir geração. Não contar navegação ou arranque como conclusão.

Resolver padrões a partir dos píxeis, cores, linhas, simetria e geometria
realmente apresentados. Nas áreas editáveis, usar entradas reais de rato ou
teclado oferecidas pelo jogo. Não ler matrizes de resposta, identificadores
ocultos, modelos de solução ou funções internas de validação para gerar
respostas. Recursos de autoria podem servir ao inventário posterior e à
comparação da cobertura, nunca ao oráculo de respostas.

Distinguir o tutorial de Polígonos do seu modo livre, sem impor níveis artificiais ou exaustão de todos os polígonos possíveis. Inventariar e provar os comportamentos e classes finitas apresentados no modo livre, sem inventar Bonus onde não existir.

Observar uma tentativa errada e reparação por tabuleiro ou nível gerado,
feedback, conclusão e continuação naturais, ajuda PT, Escape e retoma de foco,
reinício parcial, configurações/conjuntos e menu durante atividade e após
sucesso. Identificar os controlos e atalhos realmente oferecidos. Conferir
terminologia PT-PT e recursos offline. Cada defeito de produto requer o mesmo
caso vermelho/verde e a menor correção demonstrada.

Usar a metodologia física dos lotes 85 a 88: snapshot independente, fontes
congeladas antes das execuções, deployments privados retidos, RCC/QM reais,
extrações físicas, casos e logs originais, screenshots da cena inteira,
recibos e retornos Qt/supervisor/capturador/externo observados após espera.
Conferir recortes de itens individuais com a cena inteira antes de os usar.
O ambiente gráfico deve corresponder ao exigido pela aplicação; não forçar
ativação de atividades desativadas pelo renderer.

Preservar todos os negativos e pilotos separadamente dos percursos finais.
Auditor puro com âncora externa literal, cópia física portátil sem Git/Qt/rede,
normal e -O ou recusa explícita, negativas físicas e coerentemente recalculadas,
vazio e proteção de saídas existentes. Não transferir a aprovação das 32 vozes
a outros sons. Windows, dispositivos, audição, docente, estabilidade 83 e
critérios globais permanecem pendentes. Trabalho só no fork.

## Implementação para revisão

Review: completed

Provas em ../functional-patterns/README.md.90 conclusões primárias,90 erros reparados; modo livre separado.23 execuções Qt com zero, sete fixtures externas negativas e um histórico parcial distinguido. Auditor com duas âncoras literais, fontes/recursos físicos, negativas coerentes e cópia Docker normal/-O passou.15 testes externos passaram nos dois modos. CSV152 ligações finitas,203 atividades e todos os critérios globais pending. Sem alterações de produto neste lote. As revisões independentes posteriores estão arquivadas no Answer.


## Answer

Resolvida no âmbito Linux finito após integração `2643942b9` e
[revisões Spec e Standards sem achados](../review/integration90/README.md).
Foram concluídos 38 padrões fixos, 21 padrões simétricos fixos,
22 perguntas Mosaic geradas e nove níveis do tutorial Polygons,
com 90 erros reparados e continuações naturais. Mosaic conserva o limite
de uma pergunta gerada por nível. Os nove exemplos do modo livre de Polygons
não são níveis nem conclusões adicionais.

Os controlos finais cobrem ajuda/Escape, retoma, reinício parcial,
configurações 3/3/4 e regresso ao menu durante atividade e após sucesso.
Sym2 permanece parcial, substituído pelo Sym3 com mudança real da célula.
Os dois auditores físicos independentes terminaram com zero, sessões 72889
e 49869, chunks 25143f e 674ded. A cápsula literal, os 23 recibos e todos os
negativos permanecem intactos. Nenhum código de produto ou áudio mudou no lote.

Quatro ligações de evidência mantêm todas as colunas globais `pending`.
Windows, escola, dispositivos, audição, revisão docente/linguística,
estabilidade 83 e aceitação global continuam pendentes. Este fecho documental
não executou Qt, builds ou publicação e não altera a tarefa 44 posterior.
