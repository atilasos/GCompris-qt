# Spec — tarefa 37 concluída

Base: `cfab58993`. Tip: `e06c968fc0bc2e6a324177814db9c01cc48b6882`.
Revisão independente do ticket 37, casos, auditor, inventários e recibos;
sem alterações de código ou novas campanhas Qt. Produção PO já revista
separadamente. Não inclui a tarefa 34, da minha autoria.

Sem achados acionáveis no âmbito funcional delimitado e documentado.

Conferi por SHA-256 os 25 resultados finais e os respetivos casos combinados
conservados. Todos declaram passagem, código zero, ausência de timeout e erros
QML. A soma dos recibos confirma 43 percursos, 292 pares do jogador, 11 de Tux,
82 pares errados, 43 Bonus bons e três maus. O auditor exige cada combinação
nível/modo, dimensões independentes, soma das pontuações e capacidade incluindo
as derrotas adicionais; não aceita simplesmente as contagens anunciadas.

O solver identifica pares pelos ficheiros de imagem/som e correspondências
lowerX/upperX, sem ler matchCode ou atribuir pontuação/turnos. Os cliques,
seleções por teclas, temporizadores originais, bloqueios e transições são
observados. Os modos são preparados antes de iniciar o percurso longo,
conforme a seam documentada; os dois casos configuration provam separadamente
seleção, gravação real e configuração persistida nos dois jogos aplicáveis.
Os reinícios usam a seam stop/start declarada; a gravação pela interface cobre
também o reinício nesses seletores.

A prova sonora observa o GCAudio/MediaPlayer original, estados e posição
positiva; compara bytes dos recursos carregados e os sete RCC com a fonte.
As contagens preservadas confirmam 115 recursos observados, os 30 sons
reproduzidos e 18 letras sorteadas. O relatório não transforma a existência
das outras oito rotas no RCC em prova de reprodução, nem a reprodução Qt em
audição ou aprovação de pronúncia. A aprovação das 32 gravações novas não é
estendida às vozes existentes.

A falha inicial Escape está identificada como fixture que ignorava o fecho
do diálogo. Os cinco casos corrigidos usam o evento real; os recibos longos
anteriores conservam os casos exatos e não são apresentados como prova desse
fecho. O ticket resolved refere a verificação delimitada; README e matriz
mantêm Windows, hardware, audição física e revisão docente global pendentes.
