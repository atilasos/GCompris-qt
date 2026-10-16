# Verificação da segunda ronda da interface

Estas verificações cobrem recursos e a sua compilação. Não certificam as 203
atividades, a revisão do professor nem os computadores Windows da escola.

## Alterações para revisão

`interface-review.json` conserva a primeira ronda de 155 mensagens.
`interface-orthography-review.json` contém esta ronda de 637 campos, com contexto,
fonte, antes, depois e referências. Todos mantêm revisão do professor pendente.
`tools/revise-pt-interface.py` aplica a lista explícita de correções. Não muda
fontes, contextos, comentários ou metadados do catálogo.

Correções pedagógicas relevantes:

- Seis perguntas de calendário trocavam antes/depois, omitiam dois dias ou
  mudavam novembro para março.
- O manual da subtração por reagrupamento indicava aumentar o número inferior
  em vez de retirar uma unidade ao minuendo na coluna seguinte.
- Um conjunto de adição indicava 3 linhas quando o original e o nível têm 2.
- A ajuda de colar confundia texto cortado com colado; Return era traduzido
  como Retroceder. A ajuda do helicóptero e da contagem não correspondia aos
  comandos ou à posição indicada no original.

## Evidência reproduzível

Executar na raiz do repositório:

```bash
python3 tools/revise-pt-interface.py --check
python3 -m unittest discover -s tests -p 'test_*pt*.py'
python3 -m unittest discover -s tests -p test_translation_build.py
msgfmt --check --check-format -o /tmp/gcompris-pt.mo poqm/pt/gcompris_qt.po
```

Os sete testes de recursos/auditoria e os cinco testes de compilação passaram
em Linux. O verificador do catálogo encontrou 4316 entradas ativas, sem vazias,
fuzzy ou diferenças nos marcadores Qt. A comparação de elementos e atributos
HTML entre fonte e traduções, normalizando variantes de `<br>`, não encontrou
diferenças. `msgfmt` confirmou sintaxe e formatos.

Os testes de compilação usam um projeto CMake temporário que importa a função
real de tradução. Um executável Qt6 carrega o QM pelo QTranslator e verifica as
traduções observáveis. A fixture independente comprova que 0 maçãs, 1 maçã e
2 maçãs usam regras PT-PT. A fixture brasileira mantém 0 maçã. A versão real do
catálogo devolve as instruções revistas e os plurais corretos. Foram reproduzidos
os problemas antes das correções. Os testes de reconstrução também comprovam
que editar o PO muda o QM e que reconstruir sem alterações mantém o resultado.

A compilação real com `lconvert -target-language pt_PT` e `lrelease
-removeidentical -nounfinished` gerou 3851 traduções terminadas. As restantes
entradas iguais ao original são omitidas pela opção de compilação do projeto.
O build partilhado não foi alterado por este trabalho.

## Pendente

- Revisão linguística e pedagógica pelo professor.
- Verificação visual de ajuda e mensagens de erro na aplicação reconstruída.
- Confirmação do instalador e dos textos em Windows 10 x64.
- Atividades cujos exercícios vêm de JSON, QML ou áudio têm tarefas próprias.

## Revalidação na aplicação Linux integrada

Em 15 de outubro de 2026, a compilação `build/pt-pt` foi reconstruída com
as alterações até `4e1e47475`. As oito suites C++ passaram com `LC_ALL=C`.
O arranque nativo em perfis isolados passou, sem erros QML, para
`grammar_classes`, `grammar_analysis`, `keyboard_training`, `readingh`,
`readingv`, `gletters`, `click_on_letter` e `click_on_letter_up`. Logs em
`build/pt-pt/post-integration-smoke/`. Isto verifica arranque, não conclusão.

Na janela real de `grammar_classes`, foram confirmados o título, a descrição,
as instruções iniciais, a frase do exercício e o painel de ajuda em português.
Capturas locais em `build/pt-pt/interface-grammar-game.png`,
`interface-grammar-help.png` e `interface-grammar-help-page2.png`. O painel
de ajuda mostrou também uma lacuna: a palavra inglesa `WORD` está desenhada
no ícone SVG, fora do catálogo PO. É necessário corrigir este texto gráfico
e verificar os restantes ícones com texto antes de concluir a tarefa03.
A verificação de mensagens de erro e a revisão humana continuam pendentes.

A lacuna gráfica WORD identificada nessa inspeção foi corrigida posteriormente
na tarefa14, juntamente com os outros sete ícones com texto estrangeiro. As
renderizações Qt e a revisão das 203 miniaturas estão em `icons/`. A revisão
humana da interface continua pendente.
