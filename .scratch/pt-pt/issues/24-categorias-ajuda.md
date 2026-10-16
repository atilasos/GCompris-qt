# Traduzir as categorias no rodapé da ajuda

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02

## Defeito observado

A captura `functional-memory/help-green/number-name-help.png` apresenta
«Secção: math numeration (memory-wordnumber)». `src/core/DialogHelp.qml:70`
concatena os identificadores de `ActivityInfo.section` sem tradução.

## Aceitação

- Apresentar os nomes das categorias em PT-PT na ajuda de todas as 203 atividades.
- Conservar os identificadores usados pelos filtros e a escolha das categorias.
- Reutilizar as traduções existentes quando adequado; as categorias do menu
  estão em `src/activities/menu/Menu.qml:104`.
- Inventariar automaticamente todos os tokens de section e garantir que nenhum
  identificador conhecido fica por traduzir. Verificar o catálogo Qt real.
- Reproduzir e corrigir na ajuda nativa de memória e de outra secção distinta,
  sem alterar o funcionamento das atividades nem ocultar o rodapé.
- Preservar os outros idiomas e registar evidência, hashes e limites.

## Answer

ActivityCategories.js fornece os rótulos de apresentação; DialogHelp formata os
tokens sem alterar metadados ou filtros. Dez traduções existentes do Menu são
reutilizadas e 22 entradas DialogHelp novas cobrem os restantes rótulos PT.
Inventário203/33tokens, formatter, QM real para todos os rótulos e fallback
sem tradutor passaram. Ajuda nativa de memória e labirinto reproduziu o defeito
com o core anterior e passou com o atual, sempre com snapshots selados/privados.

[Procedimento, capturas e hashes](../help-categories/README.md).
Revisão docente e Windows permanecem pendentes. Não houve escrita no build
principal, alteração de IDs nem modificação do mapa/CSV pelo implementador.
