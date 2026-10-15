# Análise gramatical: conteúdo PT e verificação parcial em Linux

Resultado global: pending.

Ambiente: Ubuntu 26.04, Qt 6.10.2, aplicação 26.2, branch `work/pt-pt` com alterações
locais. Idioma `pt_PT.UTF-8`. Perfil de teste isolado. Som desativado.

## Dados e testes

O ficheiro `grammar_analysis-pt.json` tem sete níveis e 80 exercícios. O teste
`node --test tests/grammar_pt_pt.test.mjs` verifica o carregamento dos dados PT e
executa o analisador e a verificação de respostas do jogo em todos os exercícios.
Todos os níveis e quantidades de exercícios foram mantidos.

## Janela real

- O objetivo mostrou `Identifica os determinantes e os nomes.` e as classes mostraram
  `Nome` e `Determinante`.
- Foi resolvida a frase `Ao fim da tarde eu brinco com os meus amigos.`.
- Foram marcados como Nome `fim`, `tarde` e `amigos`. Foram marcados como Determinante
  a segunda caixa de `Ao`, a segunda caixa de `da`, `os` e `meus`. As restantes caixas
  ficaram vazias, incluindo as caixas de preposição das contrações.
- A resposta foi aceite e o contador passou de 0/12 para 1/12.
- No exercício seguinte, confirmar sem preencher as caixas deu erro e manteve 1/12.

## Evidências

- `build/pt-pt/grammar-tests.log`: oito testes automáticos aprovados.
- `build/pt-pt/grammar_analysis-pt-pt.png`: objetivo, classes e frase em português.
- `build/pt-pt/grammar-analysis-solution.png`: solução com contrações preenchida.
- `build/pt-pt/grammar-analysis-correct.png`: avanço para 1/12.
- `build/pt-pt/grammar-analysis-wrong.png`: resposta errada rejeitada.
- `build/pt-pt/grammar-analysis-interactive.log`: execução gráfica.

## Pendente

Revisão linguística e pedagógica pelo professor. Execução interativa dos restantes
níveis, avaliação de áudio e instalação offline em Windows 10, incluindo na escola.
