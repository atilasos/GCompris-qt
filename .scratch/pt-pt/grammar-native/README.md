# Gramática na interface Qt real

Verificação Linux de 15 de outubro de 2026. A aplicação Qt6.10.2 real foi
executada com perfis novos e Docker sem rede. O RCC privado acrescenta apenas
o TestCase; os controlos, os modelos, as animações e a lógica são os do jogo.
O teste lê as classes esperadas para escolher entradas, mas aplica eventos
reais de rato/teclado e verifica as propostas, rejeições e transições observadas.
Os oito testes Node verificam separadamente os dados de todos os exercícios.

| Atividade | Níveis concluídos | Exercícios certos | Errados rejeitados | Exercícios por teclado | Apagar e corrigir | Palavras com várias caixas |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Classes gramaticais | 8 | 92 | 8 | 8 | 8 | 24 |
| Análise gramatical | 7 | 80 | 7 | 7 | 7 | 18 |

Cada resposta certa avançou a pontuação, cada nível terminou pela animação
normal de Score/Bonus e o último regressou ao nível1. Os testes de navegação
separados cobriram direita, esquerda, tabulação, cima, baixo, espaço,
Retroceder e Enter. Confirmaram que cada tecla provoca uma única ação.
As frases e os nomes das classes vêm dos JSON PT, sem fallback inglês.

## Falha reproduzida e corrigida

`keyboard-before.json`/`.log` registam uma seta direita que mudou a seleção
de0 para2, quando devia ir para1. Com duas classes visíveis, a seleção
voltava a0 e era impossível alcançar a outra pelo teclado. O evento tratado
não era aceite e o ActivityBase reenviava-o ao filho. `handleKeys` aceita
agora apenas as teclas que trata; as restantes continuam para o pai.

`classes-complete`, `analysis-complete` e os dois `*-navigation` incluem
resultados e logs reais, com hashes do caso, do binário e do RCC privado.
As imagens de navegação foram abertas e inspecionadas. O áudio foi silenciado;
este teste não aprova pronúncia nem substitui Windows10 ou revisão pedagógica.
A matriz geral permanece pendente conforme os critérios das tarefas03/05/06.

## Repetir

Depois de integrar o launcher da tarefa16, na raiz:

```bash
python3 tools/run-native-qml-case.py --binary build/pt-pt/bin/gcompris-qt \
  --activity grammar_classes \
  --qml-file src/activities/grammar_analysis/GrammarAnalysis.qml \
  --case tests/native/grammar.qml --result-marker NATIVE_GRAMMAR_RESULT \
  --output build/grammar-classes-native --timeout 700 --offline
```

Repetir com `--activity grammar_analysis`. Para a navegação, usar
`--case tests/native/grammar-navigation.qml`,
`--result-marker NATIVE_GRAMMAR_NAVIGATION` e uma pasta de saída diferente.
