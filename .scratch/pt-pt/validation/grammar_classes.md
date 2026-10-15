# Classes gramaticais: conteúdo PT e verificação parcial em Linux

Resultado global: pending.

Ambiente: Ubuntu 26.04, Qt 6.10.2, aplicação 26.2, branch `work/pt-pt` com alterações
locais. Idioma `pt_PT.UTF-8`. Perfil de teste isolado. Som desativado.

## Dados e testes

O ficheiro `grammar_classes-pt.json` tem oito níveis e 92 exercícios. O teste
`node --test tests/grammar_pt_pt.test.mjs` verifica o carregamento dos dados PT e
executa o analisador e a verificação de respostas do jogo em todos os exercícios.
Todos os níveis e quantidades de exercícios foram mantidos.

## Janela real

- O objetivo mostrou `Identifica os nomes.` e a classe mostrou `Nome`.
- Na frase `A chuva cai no jardim.`, confirmar sem preencher as caixas deu erro
  e manteve o contador em 0/12.
- Marcar `chuva` e `jardim` como Nome e deixar as restantes caixas vazias foi aceite.
  O contador passou a 1/12 e apareceu `A flor é bonita.`.

## Evidências

- `build/pt-pt/grammar-before.log`: seleção inglesa antes da correção.
- `build/pt-pt/grammar-tests.log`: oito testes automáticos aprovados.
- `build/pt-pt/grammar_classes-pt-pt.png`: exercício em português.
- `build/pt-pt/grammar-classes-wrong.png`: resposta errada rejeitada.
- `build/pt-pt/grammar-classes-correct.png`: avanço para 1/12.
- `build/pt-pt/grammar-classes-interactive.log`: execução gráfica.

## Pendente

Revisão linguística e pedagógica pelo professor. Execução interativa dos restantes
níveis, avaliação de áudio e instalação offline em Windows 10, incluindo na escola.

## Conclusão de todos os níveis na interface Qt

Verificação nativa de todos os exercícios e modos em Linux, com respostas
certas/erradas e eventos reais, em [grammar-native](../grammar-native/README.md).
Inclui a correção da entrega dupla das teclas e navegação completa.
Windows10, audição e revisão pedagógica permanecem pendentes.
