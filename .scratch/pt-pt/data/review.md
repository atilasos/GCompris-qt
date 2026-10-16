# Dados PT-PT: alterações e evidência

## Correções

- `click_on_letter` e `click_on_letter_up`: novo `levels-pt.json`, mantendo
  os 11 níveis. Os três primeiros usam as cinco vogais `a/e/i/o/u`, sem ensinar
  `y` como sexta vogal. O alfabeto completo mantém 26 letras, incluindo k/w/y.
  As classes de símbolos não são ampliadas com letras acentuadas nesta atividade.
- `gletters` e `keyboard_training`: novo `default-pt.json`, com os dez níveis
  de progressão existentes (vogais, consoantes, alfabeto, números, maiúsculas e
  mistura de casos), adaptados às cinco vogais. Acrescentados três níveis de
  caracteres portugueses: `àáâãéêíóôõúç`, maiúsculas e mistura dos dois casos.
  A progressão e os novos exercícios aguardam revisão do professor na tarefa 08.
- Em `gletters`, o modo maiúsculas usa o mesmo `default-pt.json`, transformando
  o texto em `createWord` e `processKeyPress`; não seleciona `upper-en.json`.
  A pesquisa das referências aos nomes `upper-` confirmou que os ficheiros
  `upper-*.json` não são selecionados pelo código atual. Não se criou um ficheiro
  `upper-pt.json` sem consumidor.
- `readingh` e `readingv`: a primeira entrada com locale explícito `pt_PT` ou
  `pt_PT.UTF-8` carregava logo o inglês porque `Wordlist.useDefault` começa em
  `true`. O `maxLevel` ficava preenchido e não se tentava o locale curto `pt`.
  Normaliza-se agora com `ApplicationInfo.getVoicesLocale`, como nas restantes
  atividades. Ambas leem os dados partilhados de `wordsgame`.
- `wordsgame`, e por partilha `readingh/readingv`: substituído `geladeira` por
  `frigorífico`. A lista portuguesa já existia; não era necessário recriá-la.
- Vocabulário partilhado por `lang`, `hangman`, `letter-in-word` e `missing-letter`:
  grafias `pára-quedas` → `paraquedas` e `pêra` → `pera`. As chaves de imagens/áudio
  permanecem as mesmas. As grafias não alteram a pronúncia das gravações existentes.
- `smallnumbers` e `smallnumbers2`: os defaults são numéricos, sem vocabulário
  inglês. Não foram criadas traduções artificiais desses números.

Os novos JSON adaptam os recursos do próprio projeto, sob GPL-3.0-or-later.
Não foram acrescentados recursos externos nem alterados dados `pt_BR`.

## Verificação reproduzível

```bash
node --test tests/letters_pt_pt.test.mjs tests/grammar_pt_pt.test.mjs
```

Passaram 15 testes: sete novos e oito de gramática existentes. Os testes novos
executam o JavaScript original das atividades num VM Node, com adaptadores só
nas fronteiras Qt. O carregamento real de `Wordlist.qml` é exercido pelas suas
funções originais, extraídas sem reimplementar a lógica. A normalização C++ de
locale tem cobertura separada em `tests/core/ApplicationInfoTest.cpp`.

Casos verificados:

- Todos os 11 níveis de letras, minúsculas/maiúsculas, todas as respostas certas
  e erradas, e cobertura das 26 letras.
- Todos os 13 níveis da lista nova, sem duplicação de caracteres no nível e com
  teclas virtuais alcançáveis para os caracteres apresentados.
- Seleção PT antes de qualquer fallback em `gletters`, `keyboard_training`,
  `wordsgame` e nas duas atividades de leitura.
- Respostas acentuadas e com cedilha no teclado: forma correta aceite, forma sem
  diacrítico rejeitada, nos dois modos de caixa de `keyboard_training`.
- Dados partilhados de `lang`: os 116 elementos da amostra (6 lições) e os
  1090 elementos completos (23 lições) têm tradução PT, sem lições vazias e sem
  seleção de `content-en` ou `content-pt_BR`. Este teste não certifica a redação.

`source-json-check.json` regista a leitura de todos os JSON das atividades.
É apenas validação sintática: dados QML e comportamentos de todos os jogos não
ficam aprovados por este resultado.

## Execução Linux com recursos compilados

Foi criada uma cópia privada do executável já compilado e dos recursos em
`build/data-probe/`, sem modificar a compilação original partilhada.
Os RCC de `click_on_letter`, `gletters` e `readingh` foram recompilados com o `rcc`
de Qt6 usando as fontes desta branch. As restantes dependências foram ligadas
por symlink apenas para leitura. Com perfis novos, passaram os testes de arranque:

```bash
python3 tools/smoke-activity.py --binary build/data-probe/bin/gcompris-qt \
  --output build/data-probe/startup --seconds 4 \
  click_on_letter click_on_letter_up gletters keyboard_training readingh readingv wordsgame
```

Os registos confirmaram a seleção de `gletters/resource/default-pt.json` (13 níveis)
por `gletters/keyboard_training` e `wordsgame/resource/default-pt.json` (3 níveis)
por `readingh/readingv/wordsgame`. Zero erros QML detetados nestes sete arranques.
A correção das três palavras de vocabulário foi posterior a estes arranques;
a compilação final integrada tem de voltar a empacotar `lang.rcc/wordsgame.rcc`.
Os logs locais estão em `build/data-probe/startup/` e são ignorados pelo Git.

## Aceitação ainda pendente

- O pacote de vozes PT existente só possui `a-z` e números no diretório alphabet;
  não há gravações dos 12 caracteres acentuados. Os exercícios novos podem ser
  jogados com teclado, mas o seu reforço sonoro exige gravações PT-PT aprovadas.
  Não se substituem esses sons pelo áudio de outra letra. Coordenado com tarefa 05.
- A revisão linguística/pedagógica do professor é tarefa 08; as listas acima são
  concretamente o que precisa da sua revisão, incluindo a divisão de vogais e os
  três níveis de caracteres acentuados.
- A execução interativa de cada atividade/modo e todos os comportamentos distintos
  pertence à matriz da tarefa 07. O arranque e os testes de dados não aprovam as
  203 atividades nem certificam a conclusão de cada nível.
- A versão Windows 10 x64 e o instalador offline continuam a precisar da sua
  verificação própria, incluindo execução no computador do professor/escola.
