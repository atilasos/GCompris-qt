# Memória PT-PT: verificação nativa com recursos isolados

Os **12 casos nativos delimitados passaram**, sem debugger: 34 percursos completos,
180 pares corretos, 42 pares errados e 34 tentativas de terceira carta bloqueadas.
Aceitação global Linux, Windows e docente: **pending**.

| Atividade | Percursos nível/modo | Pares corretos | Pares errados |
| --- | --- | --- | --- |
| memory-wordnumber | 10 | 50 | 12 |
| memory-case-association | 8 | 36 | 10 |
| memory-enumerate | 16 | 94 | 20 |

## Comportamento demonstrado

Todos os cinco níveis de números por extenso, quatro de associação de casos e
oito de enumeração foram concluídos nos modos de um e dois jogadores. As respostas
usam cliques reais e setas/Espaço. Os pares são escolhidos pela semântica visível
(palavra/algarismo, letra ou quantidade), sem ler o matchCode do motor.

Cada nível verifica um par errado, exposição durante o atraso, rejeição de um
terceiro clique e ausência de pontos. Pares corretos só pontuam após o tempo de
resolução; cartas encontradas ficam desativadas. Nos dois jogadores, erros
alternam o turno e ambos os jogadores pontuam/vencem em níveis diferentes.
Score, bloqueio de conclusão, Bonus e avanço/regresso ao nível 1 são originais.

Os outros nove casos verificam botões anterior/próximo, ajuda PT e menu, Escape,
quatro setas e reinício com uma carta aberta nos dois modos. Após reiniciar,
aguardam mais de 1500 ms e confirmam ausência de seleção/fila/pontos antigos.
Não há atribuição de pontos, marcação de cartas encontradas ou encurtamento
de temporizadores no teste.

## Dados e português europeu

Três testes Node verificam todos os 21 significados numéricos, 26 pares de glifos
maiúsculos/minúsculos e 49 pares numerais/borboletas dos oito datasets. Validam
também todas as suas ocorrências nas grelhas (55 de números e 36 de letras),
sincronização com os sons, capacidade e inexistência de duplicados semânticos.
A borboleta de tamanho zero não conta como item visível.

O jogo nativo verifica as 21 traduções reais no QM, em todos os dados carregados:
zero, um, dois, três, quatro, cinco, seis, sete, oito, nove, dez, onze, doze,
treze, catorze, quinze, **dezasseis, dezassete, dezoito, dezanove**, vinte.
Não se trata apenas de uma lista esperada construída a partir do jogo.

## Defeitos corrigidos e diagnóstico

- [Teclas duplicadas](key-fix.md): MemoryCommon não aceitava as teclas tratadas.
  Uma seta movia duas posições. A prova red/green confirma uma posição por evento,
  Espaço, conclusão de um nível e Escape preservado.
- [Ajuda de numerais](help-fix.md): descrevia imagens em vez de algarismos e
  números por extenso. Duas entradas PT corrigidas e verificadas no QM e GUI.
- O lote inicial `final/` terminou com 139 durante gameplay e uma saída de
  enumerate. **Esses resultados continuam guardados como falhas históricas**.
  A tarefa23 reproduziu SIGSEGV em QResource ao reescrever in-place um RCC ainda
  mapeado, mesmo inativo. A tarefa25 passou a copiar e selar todos os recursos.
  As passagens `debug-single/` e `gdb-parallel/` são comparação diagnóstica,
  não a aprovação final. Não foi feita outra correção de produção para esconder
  estes encerramentos do ambiente de teste.

## Evidência final e reprodução

[Resumo dos 12 casos](sealed-final/summary.json) e [índice de hashes](index.json).
Cada caso identifica o manifesto comum e os 269 ficheiros do snapshot, binário,
catálogo PT/QM e overlay. O runner recompila os três RCC de dados e o core atual
num base privado, cria um snapshot completo/selado e só depois arranca os casos.
O componente MemoryCommon é instrumentado privadamente com o código real.

Todos os processos usam perfil novo PT-PT e Docker sem rede, sem escrever no
build principal nem mapear os seus ficheiros mutáveis. O core inclui a tradução
de categorias da tarefa24. Capturas por atividade estão nas subpastas gameplay
(tabuleiro) e controls (ajuda/menu). [Procedimento](../../../tests/functional_memory/README.md).

A continuação curta da tarefa20 também passou com o mesmo snapshot:
[wordsgame-contract](sealed-wordsgame-contract/result.json) confirma três níveis
em activity.numberOfLevel e no contador do jogo. Não entra nos 12 casos/34 percursos.

## Limites

playerCount é uma fixture pelo ciclo normal stop/start; não se afirma testar
os gestos do diálogo de opções. Os testes não substituem teclado/rato físicos,
audição, pronúncia ou revisão pedagógica. O ambiente headless arranca sem som.
Windows 10 x64/escola, legibilidade física e aceitação global Linux continuam
pendentes. A resolução desta tarefa refere-se ao lote automatizado descrito.
