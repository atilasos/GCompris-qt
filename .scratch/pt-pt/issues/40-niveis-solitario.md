# Publicar os níveis e o nível atual do Solitário

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25

## Âmbito

PegSolitaire mantém numberOfLevel/currentLevel privados sem os publicar no
ActivityBase. Provar por Qt o contrato de contagem e navegação nos quatro
tabuleiros e corrigir apenas a sincronização. As sequências consultam esses
valores públicos. Não atribuir vitórias nem chamar validadores para provar
uma sequência completa. A prova não representa conclusão dos puzzles.

Conservar vermelho/verde e comandos, perfil novo offline e recursos privados.
O funcionamento integral dos tabuleiros/modos exige um lote próprio; Windows,
dispositivos e professor continuam pendentes.

## Resultado

Dois handlers sincronizam os metadados públicos. Prova nativa vermelho/verde
com oito transições reais e quatro descrições PT: [evidência](../solitaire-levels/README.md).
O âmbito restrito está concluído; o jogo integral permanece por validar.
