# Traduzir as categorias no rodapé da ajuda

Status: ready-for-agent
Progress: open
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
