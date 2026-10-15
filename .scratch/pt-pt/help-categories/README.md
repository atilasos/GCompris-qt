# Categorias da ajuda em PT-PT

A ajuda mostrava identificadores internos em inglês: «math numeration» e «fun
maze». Agora apresenta **«Matemática, Numeração»** e **«Diversão, Labirintos»**.
O rodapé e o identificador da atividade mantêm-se; os campos ActivityInfo.section
usados pelos filtros não foram alterados.

## Verificação

- Inventário automático das **203 atividades**: **33 tokens**, todos mapeados.
  [Inventário com IDs, rótulos e hashes das fontes](native-green/inventory.json).
- Dois testes Node: formatter real do conteúdo e cobertura completa dos tokens.
- O probe C++ executou o módulo JavaScript no Qt com o **QM PT real**: todos os
  33 rótulos coincidem com as formas esperadas. [Resultado PT](native-green/pt_PT.json).
- Sem tradutor instalado, o mesmo módulo devolve os rótulos fonte em inglês,
  demonstrando que o código não impõe português a outros idiomas
  ([resultado](native-green/en.json)). Reutiliza dez traduções do Menu; 22 novas
  entradas DialogHelp cobrem os restantes tokens (color/colors partilham Cores).
- msgfmt --check --check-format passou; o lconvert usou target-language pt_PT e
  o lrelease gerou um QM privado, como na aplicação.

## Red e green na aplicação real

A reprodução [native-red](native-red/summary.json) recompila apenas o DialogHelp
anterior de b19e37e07 num core.rcc privado. O mesmo caso abre a ajuda e falha em
memória e labirinto, registando os identificadores ingleses nos conteúdos.
Ambos saem normalmente, sem erro QML; são falhas esperadas da asserção.

Com o DialogHelp atual, os dois casos [native-green](native-green/summary.json)
passaram. Usaram o botão real de ajuda, verificaram os rótulos, confirmaram IDs
inalterados e deslocaram a página com eventos de rato até ao rodapé.
Capturas: [memória](native-green/memory-wordnumber/translated-footer.png) e
[labirinto](native-green/maze/translated-footer.png).

Cada caso executou com perfil novo PT-PT, Docker sem rede e o snapshot completo
selado da tarefa25. Resultados incluem hashes de todos os recursos e do manifesto.
O core.rcc, o QM e os overlays das atividades são privados; o build principal
não foi escrito. O [índice](index.json) identifica logs, capturas e resultados.

## Reprodução e limites

Seguir [o procedimento](../../../tests/help_categories/README.md). Num build
incremental, executar a configuração CMake antes de compilar: o novo
ActivityCategories.js é recolhido pelo glob *.js do core. O instalador Windows
usa uma configuração nova.

Esta verificação aprova o comportamento delimitado do rodapé, não a aceitação
global dos jogos. A revisão linguística/pedagógica e a execução Windows/escola
continuam pendentes. Os restantes idiomas usam o mecanismo Qt e o fallback da
língua fonte; só PT-PT e o fallback inglês foram verificados nesta tarefa.
