# Corrigir os exercícios de gramática que recorriam ao inglês

Status: ready-for-agent
Progress: resolved
Type: task

## Reprodução

O professor reportou capturas com instruções, classes e frases inglesas nas
atividades `grammar_classes` e `grammar_analysis`, embora a interface estivesse
em português. Não existiam os ficheiros de dados `grammar_classes-pt.json` e
`grammar_analysis-pt.json`. O carregador partilhado procura o locale `pt` e, se não
o encontra, escolhe `en`.

O teste `node --test tests/grammar_pt_pt.test.mjs` reproduziu a escolha dos ficheiros
ingleses antes da correção: quatro testes falharam. O erro observado incluía
`grammar_classes-en.json` em vez de `grammar_classes-pt.json`.

## Correção

- Acrescentados os dois ficheiros PT, seguindo o formato já usado pelo projeto.
- Mantidos os oito níveis e 92 exercícios de classes gramaticais e os sete níveis
  e 80 exercícios de análise gramatical.
- Objetivos, nomes das nove classes e todas as frases em português europeu.
- Respostas revistas para as frases portuguesas, incluindo contrações com duas
  classes, como `no` e `ao`, e expressões nominais agrupadas, como `pôr do sol`.
- O carregador e os conteúdos ingleses permanecem disponíveis para os outros
  idiomas; o locale português deixa de precisar desse fallback.

## Verificação automática

```bash
node --test tests/grammar_pt_pt.test.mjs
```

Os oito testes passaram. Executam o JavaScript original do jogo, retirando apenas
as diretivas de importação QML. Os serviços Qt de ficheiros e locale são substituídos
na fronteira de leitura. São verificadas a seleção do ficheiro PT, as classes,
os objetivos, todas as correspondências entre palavras e códigos e a manutenção
de todos os níveis e quantidades de exercícios. Para cada exercício, a solução é
aceite pelo código real de verificação e uma resposta errada é rejeitada.

O teste que abrange as 172 soluções verifica o funcionamento do jogo com as
respostas fornecidas; não constitui revisão linguística independente dessas respostas.
A revisão pelo professor está pendente e descrita em `../grammar-review.md`.

## Compilação e execução

A configuração CMake foi repetida para incluir os novos JSON nos RCC. A compilação
terminou com código 0. Os testes de arranque passaram para as duas atividades.
Verificações interativas e capturas em `../validation/grammar_classes.md` e
`../validation/grammar_analysis.md`.

## Answer

O carregamento PT foi confirmado nas duas atividades compiladas. Nas janelas reais,
uma resposta correta avançou de 0/12 para 1/12 em cada atividade e uma resposta
errada foi rejeitada. Na análise, a solução incluiu as caixas de determinante das
contrações `Ao` e `da`, mantendo vazias as caixas de preposição nesse nível.
A revisão do professor e a execução em Windows continuam pendentes.
