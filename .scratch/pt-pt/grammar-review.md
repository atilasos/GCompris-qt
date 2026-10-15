# Revisão dos conteúdos de gramática PT-PT

Estado: revisão do professor pendente.

Os novos ficheiros estão em:

- `src/activities/grammar_classes/resource/grammar_classes-pt.json`.
- `src/activities/grammar_analysis/resource/grammar_analysis-pt.json`.

O ficheiro de classes contém oito níveis, com 12 exercícios em cada nível,
exceto interjeições, com oito. O ficheiro de análise contém sete níveis, com
12 exercícios em cada nível, exceto interjeições, com oito. A progressão e as
quantidades foram mantidas face aos ficheiros ingleses.

## Terminologia

As classes apresentadas são Nome, Determinante, Adjetivo, Pronome, Verbo, Advérbio,
Conjunção, Preposição e Interjeição. Os códigos internos mantêm o formato do jogo.

As frases foram redigidas para português europeu. Não foi feita uma substituição
palavra a palavra das frases inglesas. Foram evitados casos em que uma classificação
inglesa daria uma resposta errada em português. Por exemplo, o Dicionário Terminológico
da DGE classifica `onde` como advérbio interrogativo, e não como pronome:
https://dt.dge.mec.pt/index.php?id=n623

## Pontos para revisão

- Confirmar a adequação das frases e dos tempos verbais às crianças destinatárias.
- Rever a classificação de cada palavra, em particular os nomes e adjetivos em
  posição predicativa e os artigos e determinantes possessivos consecutivos.
- Confirmar o tratamento das contrações. Em `A chuva cai no jardim.`, o jogo
  apresenta duas caixas para `no`, correspondentes à preposição e ao determinante.
  No nível dos nomes, ambas ficam vazias. No nível de determinantes e nomes, a
  segunda caixa recebe Determinante.
- Rever a apresentação de `pôr do sol` como expressão nominal agrupada. Os
  parênteses do ficheiro servem para agrupamento e não aparecem na frase apresentada.
- Rever as interjeições e as frases subordinadas dos níveis mais avançados.

Os testes verificam todas as respostas com o código do jogo, mas não aprovam
automaticamente a qualidade linguística ou a adequação pedagógica.
