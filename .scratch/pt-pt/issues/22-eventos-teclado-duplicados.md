# Diagnosticar eventos de teclado duplicados

Status: ready-for-agent
Progress: claimed
Type: task
Blocked by: 02

## Âmbito

Inventariar handlers genéricos de teclado e provar no máximo cinco casos neste
primeiro lote. Uma seta deve mover uma posição e Escape deve continuar a abrir
o menu. Não remover ActivityBase.forwardTo globalmente. A memória pertence à
tarefa 21; não editar. Corrigir apenas defeitos reproduzidos com QtTest nativo,
RCC privado e o executável real. O inventário estático não valida as 203 atividades.

## Prova reproduzível

`python3 tools/inventory-key-handlers.py` gera o inventário em
`../keyboard-events/inventory-before.json`. A análise procura aceitação explícita no
handler e nas funções JavaScript diretamente delegadas; é uma triagem, não
uma prova de execução ou de todos os ramos.

## Entrega do primeiro lote

Cinco defeitos reproduzidos e corrigidos: babymatch, algorithm, lightsoff,
align4_2players e money. Evidência antes/depois e limites em
`../keyboard-events/README.md`. Apenas teclas reconhecidas são aceites;
ActivityBase e memória não foram alterados. As restantes candidatas continuam
sem prova nativa nesta tarefa; a tarefa global mantém-se claimed.

## Segundo lote

Dez motores ensaiados: nove defeitos reproduzidos e corrigidos e um controlo
negativo, learn_digits, que passou sem alterações. Provas e limites no mesmo
README e em `../keyboard-events/batch2/summary.json`. Inventário atualizado:
sete candidatos estáticos, dos quais learn_digits não reproduz o defeito;
crane, guess24, note_names e três listas de diálogo/menu permanecem sem prova
nativa neste lote. `Progress: claimed` mantém a pendência explícita.
