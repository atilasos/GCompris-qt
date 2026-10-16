# Revisão Spec independente — tarefa 86

Intervalo fixo `7f285a2dc41a0530c70bee098a5c8866d116bc04...279aeaea6161642fe296c1292127856490ded92e`; commits e diff revistos. Sem Qt/build/push, alterações de main ou capturas.

**Sem achados acionáveis; confiança moderada/alta.**

Ticket86 pede «Construir um grafo de parentesco independente» e proíbe «pessoa correta, índice de resposta, modelos de solução». O observador recolhe SVG desenhados, geometria de pessoas/linhas/anéis, bordas, Eu/?, instrução e opções visíveis. O oráculo divide segmentos nas interseções, encontra pais por ligações ascendentes e cônjuges pelos anéis; deriva relações de ascendência, descendência, irmãos, primos e afinidade. Não usa campos de resposta do motor. Python recalcula o grafo/relações dos registos visuais; fixtures literais verificam essas regras.

A spec30–35 exige jogar/concluir níveis e modos com erros e evidência. Auditor puro confirmou 18+18 níveis, 46 conclusões naturais, 36 erros/reparações, 28 pares não ordenados e dois controlos. Distingue os pares das perguntas e não promete todas as ordens de clique. Os controlos verificam ordem inversa, navegação/extremos, seleção parcial/desmarcação, ajuda/Escape/foco, resposta após ajuda e menu. Score, conjuntos/configuração, Recarregar e teclado de respostas não são inventados onde não existem.

Ticket86 exige «Assinalar ambiguidade de sexo/género». O README delimita corretamente as categorias dos doze SVG como convenções iconográficas: cabelo, rosto, laços ou acessórios não demonstram género. As conclusões dos termos específicos são condicionadas a essa convenção, com revisão pedagógica humana pendente; a geração e as ligações são verificadas geometricamente. Não há certeza invisível atribuída ao aluno.

A produção altera somente dois msgstr, Afilhada→Nora e Afilhado→Genro, coerentes com as relações de afinidade. Ambos os consumidores têm pares lexicais byte-idênticos; sem scope creep ou alteração de motor/dados/imagens.

Fontes/PO/ferramentas, dez RCC/QM efetivos, seis RCC canónicos e 716 extrações físicas correspondem às fases e instrumentação exata dos casos. Âncora literal, retornos Qt/launcher/supervisor/ferramenta separados e saída existente protegida sustentam a cadeia. Todos Qt0; dois vermelhos externos1 permanecem distintos.

Comandos observados: auditor puro e `unittest discover` — 15 testes passaram; auditor `-O` recusado explicitamente. Cópia física e adulterações passam os testes. Runtime alheio aos jogos, audição, Windows/hardware, acessibilidade, revisão docente, estabilidade83 e aceitação global continuam delimitados.
