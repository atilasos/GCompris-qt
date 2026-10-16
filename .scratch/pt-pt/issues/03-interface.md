# Completar e rever a interface PT-PT

Status: ready-for-agent
Progress: claimed
Type: task
Blocked by: 01

## Aceitação

- Resolver mensagens em falta, fuzzy e diferenças indevidas nos marcadores Qt em
  `poqm/pt/gcompris_qt.po`.
- Rever ortografia atual, português europeu e instruções de teclado.
- Validar sintaxe PO, plurais, marcadores, HTML e a compilação da tradução.
- Listar alterações para revisão pelo professor; não confundir remover `fuzzy`
  com revisão linguística concluída.
- Confirmar textos em execução, incluindo ajuda e mensagens de erro.

## Comments

Primeira ronda de 155 mensagens corrigida. O catálogo não tem entradas vazias,
fuzzy ou diferenças nos marcadores Qt. Originais, traduções anteriores, traduções
novas e referências estão em `../interface-review.json`, com revisão humana pendente.
A execução da tradução compilada depende da tarefa 02. A revisão de todo o restante
catálogo, incluindo ortografia anterior ao acordo, ainda está pendente.

### Segunda ronda automatizada e revista em código

Foram corrigidos mais 637 campos de tradução, com originais, traduções anteriores,
novas traduções e referências em `../interface-orthography-review.json`.
O ficheiro é uma lista para revisão, sem aprovação do professor. O codemod
`tools/revise-pt-interface.py` permite repetir as correções; `--check` verifica
se ainda existem os problemas que cobre.

A ronda inclui ortografia atual em palavras explicitamente enumeradas, instruções
que confundiam colar texto cortado com colado e Return com Retroceder, seis
perguntas de calendário com datas, durações ou direções erradas, uma indicação de
2 linhas traduzida como 3 e o manual de subtração por reagrupamento copiado do
método de compensação. Foram corrigidos os plurais das instruções dos números
vizinhos. Variantes dependentes da pronúncia não foram convertidas em massa.

A conversão Qt também inferia `pt_BR` para o catálogo `pt`. O CMake passa agora
`pt_PT`, declara o ficheiro QM real como resultado e depende do PO de origem.
Testes com o CMake e o QTranslator reais demonstram regras europeias para 0/1/2,
preservação das regras de `pt_BR`, recompilação após alterar o PO e ausência de
recompilação quando nada muda. O catálogo real compilado devolve as novas
instruções e plurais.

Verificação desta ronda e limites em `../interface-validation.md`. Continua
pendente a revisão humana de todo o catálogo e a confirmação visual de ajuda e
mensagens de erro em execução, incluindo Windows. A tarefa permanece aberta.
