# Revisão Spec independente — tarefa73

Intervalo fixo cd1d763e8847b87db31d4993d46bfe4e58a0d2c9...047d489e0595f7fcae608ddce46374d2a14dc91f. Inspecionados spec/ticket, README, três alterações de produção, casos, oráculo, cápsula e auditor. Sem Qt, edição de main ou reescrita de índices.

**Sem achados acionáveis; confiança moderada/alta.**

Spec30–35 exige níveis/modos, acertos/erros e evidência. A auditoria pura confirmou14 níveis/102 perguntas,102 negativas reparadas e51 respostas em cada canal físico simulado/virtual. Os12 testes passaram. As300 sondas adicionais são explicitamente separadas:150 de limites e150 de reinício, sem aumentar102.

O solver interpreta a pergunta portuguesa efetivamente desenhada e converte por algoritmo próprio, sem romanConverter/questionValue ou soluções internas. A auditoria independente confere notação canónica, os62 valores fixos e os40 sorteios dentro dos máximos50/100/500/1000. Maiúsculas/minúsculas são exercitadas; os exemplos não canónicos extras e os controlos não duplicam as perguntas principais.

As três correções correspondem aos defeitos reproduzidos por casos idênticos: `Math.floor(...)+1` respeita1..máximo; reset explícito por pergunta funciona mesmo quando o valor se repete; entrada vazia limpa a conversão, impedindo reaproveitar uma resposta correta anterior. A inicialização do teclado segue o sentido da conversão. Os pares vermelhos/verdes conservam as mesmas entradas e fases históricas. Alterações funcionais abrangidas por spec39–40, sem scope creep.

Controlos cobrem ajuda PT/Escape, foco após ajuda, apagar virtual, navegação/reinício, dica e menu. A preferência pública de teclado é usada como fixture; a persistência pelo diálogo global é declaradamente excluída. Score/Bonus e transições decorrem naturalmente.

A cápsula218 fontes conserva as três fases;77 artefactos selecionados e snapshot269 têm raízes SHA imutáveis. Os dez recibos distinguem sete positivos e três vermelhos: Qt termina0 em todos, com supervisor/ferramenta0 ou1 conforme o resultado esperado. Provas intermédias substituídas não entram nas contagens finais.

As imagens são de fim de nível, sem alegar OCR de cada pergunta. Descodificação dos dois WAV não prova audição. Linux/software, sorteios observados, Windows10/escola, hardware, áudio e aceitação docente/global permanecem explicitamente separados.
