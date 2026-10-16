# Revisão dos checkpoints38,43 e propostas44

Base9594905c7; tip5ef7db807. Standards encontrou dois P2 no executor38:
retoma sem conferir identidade congelada/launcher, e filtros de lição vazios
aceites como sucesso. Spec confirmou o primeiro. O mesmo implementador
corrigiu ambos na tarefa45, conteúdo03e961d28, integração24b03c952f3aeed6a22e2ffdd02dedefb11f3142.

Regressões CLI reais reproduziram e corrigiram PO, IME, launcher e filtros dos
dois jogos; a seleção é rejeitada antes de preparar dados/saída. A retoma
exige os hashes da árvore congelada e do launcher. Os174 recibos históricos
mantêm os seus bytes; os campos de identidade novos não foram inventados
retroativamente e as campanhas antigas não foram repetidas por esta mudança.

Ambos os revisores confirmaram os P2 fechados. Não identificaram regressões
nas três correções de43 nem na preparação de44. O áudio SoundEffect continua
explicitamente não demonstrado. As duas propostas WAV de44 continuam pending,
sem modificar as32 gravações aprovadas. A matriz Hangman ainda decorre.
Os relatórios originais e rechecks estão conservados nesta pasta.
