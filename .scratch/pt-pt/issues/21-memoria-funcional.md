# Verificar três jogos de memória PT-PT

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 04, 23, 25

## Âmbito

memory-wordnumber, memory-enumerate e memory-case-association: todos os níveis
nos modos de um/dois jogadores, dados determinísticos completos, pares certos
e errados por eventos nativos, viragem/bloqueio, pontos, Bonus e transições.
Reinício, navegação, ajuda/menu e formas numéricas europeias. Perfil novo offline,
recursos privados, hashes e limites físicos/Windows/docente separados.

## Comments

Correção parcial comprovada por Qt nativo: eventos de setas eram tratados duas
vezes. MemoryCommon agora aceita as teclas tratadas e preserva Escape. O caso de
regressão completa um nível e regressa ao menu por Escape.
[Prova red/green](../functional-memory/key-fix.md). O lote completo continua
claimed até concluir todos os níveis/modos dos três jogos.

Ajuda de memory-wordnumber corrigida após prova nativa red/green: as cartas
associam algarismos e palavras, não «imagens desenhadas».
[Detalhes e hashes](../functional-memory/help-fix.md). O lote completo encontrou
saídas 139 em execução paralela; o diagnóstico está coordenado com a tarefa23.
Não há aprovação global e a tarefa continua claimed.

## Answer

O replay final sem debugger passou os 12 casos com snapshot completo selado:
34 percursos (5+4+8 níveis × dois modos), 180 pares corretos, 42 pares errados e
34 terceiros cliques bloqueados. Verifica tempos, pontuação dos dois jogadores,
Bonus/transições, reinício pendente, quatro setas, ajuda, navegação e menu.
Dados determinísticos completos e 21 nomes numéricos europeus reais passaram.

Os 139 iniciais vieram da reescrita de RCC ainda mapeados (prova23). O replay usa
o isolamento25 e conserva as falhas anteriores, sem as relabelar como aprovação.
Apenas os dois defeitos já demonstrados (teclas duplicadas e ajuda incorreta)
foram corrigidos em produção. [Relatório e hashes](../functional-memory/README.md).
Windows, áudio, dispositivos físicos e professor permanecem pendentes; mapa/CSV
ficam com o integrador. O build principal nunca foi escrito pelo implementador.
