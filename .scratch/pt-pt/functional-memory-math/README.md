# Memória matemática: checkpoint de verificação

A tarefa 29 continua em execução. O índice `checkpoint.json` é produzido por
`tests/functional_memory_math/summarize.py --partial` e identifica expressamente
os casos ainda sem resultado. Não constitui aprovação das 14 variantes.

Já passaram os 56 casos auxiliares, nas 14 variantes: ajuda PT/navegação/menu,
Escape, reinício e seleção de datasets. Os 138 objetivos de tabelas em português
foram confirmados no Qt. O reinício inclui uma carta aberta e um turno pendente
do Tux, sem encurtar os timers. As seleções de uma, duas ou todas as tabelas são
fixtures pelo mecanismo original levelFolder, não gestos exaustivos do diálogo.

O checkpoint inicial de gameplay contém quatro atividades completas: adição e
subtração, com e sem Tux. São 60 percursos nível/modo, com 298 pares corretos do
jogador, 17 do Tux, 110 pares errados e 110 terceiros cliques bloqueados. Estão
incluídas duas derrotas deliberadas contra Tux e uma derrota natural, com Bonus
negativo e repetição do nível, seguida da vitória necessária para avançar.

Os quatro testes de dados passam e verificam 138 datasets em duas ordens de
mistura, 3748 pares gerados, contas, tabela/operandos e respostas completas das
variantes mistas. A aplicação usa a sua aleatoriedade original.

Todos os casos usam o mesmo snapshot independente, com 269 ficheiros. O manifesto
original está guardado em `resource-manifest.json`; `build-identity.json` compara
16 RCC recompilados com os bytes do snapshot e identifica as 442 fontes. Cada
resultado nativo regista o caso, QM, binário, recursos, UID e rede Docker desligada.

As calibrações da inicialização do diálogo e do observador de Bonus foram
mantidas no build privado, fora das provas de aceitação. Não foi identificado
um defeito de produção neste lote até ao checkpoint. O build principal, mapa e
CSV não foram alterados.

Windows, escola, som/pronúncia, dispositivos físicos e revisão docente continuam
pendentes. A aceitação global Linux também permanece pendente. [Procedimento de
reprodução](../../../tests/functional_memory_math/README.md).

## Segundo checkpoint

Sete variantes têm gameplay completo aprovado, acrescentando multiplicação com
Tux e sem Tux e divisão sem Tux. São 110 combinações nível/modo, 548 pares do
jogador, 22 do Tux e 195 erros/terceiros cliques bloqueados. O índice atualizado
contém 63 casos completos e lista os sete gameplays restantes como ausentes.
Os 56 casos auxiliares mantêm-se aprovados; nenhuma execução parcial entra
nestes totais.

## Terceiro checkpoint

Onze variantes têm gameplay completo aprovado: 168 combinações
nível/modo, 838 pares do jogador e 37 do Tux. Os 67
casos completos incluem 313 erros/terceiros cliques bloqueados,
5 derrotas deliberadas e 2 naturais. O índice continua
parcial e identifica os três gameplays restantes.
