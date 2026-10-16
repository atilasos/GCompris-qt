# Auditor semântico dos controlos90

```python
from pattern_controls_audit import validate_controls
summary = validate_controls(native_receipt['case_result'])
```

A interface recebe o `case_result` completo e devolve um resumo ou lança
`ValueError`. Não executa Qt, lê ficheiros, altera provas ou comunica com o jogo.
Usa apenas a biblioteca padrão e `pattern_grid_solver`, que recalcula as grelhas
pela geometria e assinaturas observadas. As guardas continuam ativas com `-O`.

O contrato exige:

- Dois ensaios de teclado separados pela ajuda e Escape. Em Redraw, sete etiquetas
  numéricas associadas geometricamente às sete cores calibradas,14 efeitos de
  dígitos, Espaço/Return/Enter, Delete/Backspace e continuidade das cores com as
  ações intermédias realmente guardadas. Em Mosaico, Tab entre as áreas,
  seleção/pintura com Espaço/Return/Enter, fontes/assinaturas e imagens prontas.
- Oito movimentos reais de cursor pelas quatro direções e vizinhos visíveis.
  Só os realces admitem desvio de até1px por eixo, devido ao arredondamento
  observado entre GridView e Image. A geometria das células, cliques e planos
  mantém tolerância estrita de uma milionésima da dimensão da célula.
- Arrasto Redraw com mudança efetiva de duas células e um terceiro alvo errado,
  fora dos dois extremos, conferido contra a pergunta visível e a reflexão
  explícita do modo simétrico.
- Ajuda PT-PT, fechamento de um diálogo por Escape e novos efeitos de teclado
  depois do fechamento. Reinício de uma edição efetivamente alterada por
  seguinte/anterior, com estado final vazio observado e níveis coerentes.
- Três ou quatro conjuntos com rótulos distintos, exatamente um checkbox
  selecionado em cada configuração, cliques de gravação, perguntas/grelhas
  efetivas e intervalos públicos que compõem o total38/21/22. Configuração não
  implica conclusão dos conjuntos e não é tratada como reinício: os estados
  efetivamente registados depois de "Gravar" podem conservar uma célula pintada.
- Uma edição efetivamente diferente antes do menu, alvo ainda errado e regresso
  observado ao menu. `wins` tem de ser zero e o contador de pinturas deve coincidir
  com as ações guardadas. Prefixos falhados, vazios e entradas malformadas falham.

O resumo distingue `configured_datasets` de
`dataset_gameplay_completions_claimed`, sempre zero. Estes são contratos de
controlos, sem crédito adicional de jogos ou níveis concluídos.

A paleta Mosaico pode permutar os IDs entre slots depois de reiniciar. No ensaio
posterior à ajuda, o auditor confere ID/assinatura e pertença a um slot geométrico
observado, sem fixar a posição anterior do ID. O JSON não conserva a paleta
completa posterior ao reinício. Também conserva estados finais dos checkboxes
e o clique de gravação, mas não os cliques individuais de cada checkbox. O
caso congelado e os callbacks físicos do auditor principal fornecem essa
proveniência; este módulo não inventa eventos ausentes.

Os hashes/cores aqui recebidos têm de ser vinculados aos recursos físicos pelo
auditor principal. Este módulo não substitui a âncora externa, os RCC/QM e suas
extrações, PNGs da cena, fontes/casos congelados e retornos separados. Um JSON
isolado não prova que o evento aconteceu. A cópia sem Qt testa o auditor puro,
não constitui replay nativo nem valida Windows ou dispositivos.

```sh
PYTHONPATH=tests python3 -m unittest discover -s tests/pattern_controls_audit -p 'test_*.py' -v
PYTHONPATH=tests python3 -O -m unittest discover -s tests/pattern_controls_audit -p 'test_*.py' -v
PYTHONPATH=tests python3 -m pattern_controls_audit.verify_records --root-evidence CAMINHO_DAS_PROVAS
```

Dezanove testes usam exemplos literais Redraw, simétrico e Mosaico, além de
negativas coerentes de alteração/arrasto sem efeito, repetição do mesmo conjunto,
estados intermédios sem ação, imagens erradas/não prontas, ausência de Tab,
cursores imóveis, fechamento inexistente e entrada vazia. `fixtures.py` não
chama o plano ou o auditor para construir resultados esperados.

`verify_records.py` só lê os oito recibos finitos indicados e emite novo relatório
para stdout. Os três finais são controls2-redraw, controls3-redraw_symmetrical e
controls3-mosaic; preserva como negativos os três prefixos originais,
controls2-mosaic e controls2-redraw_symmetrical. Este último tinha Qt/retorno0,
mas a alegada edição parcial não mudava nenhuma célula, pelo que falha o contrato.
O novo caso simétrico guarda uma mudança real. Nenhum recibo foi reescrito.

`proof/` conserva os ciclos TDD e os relatórios semânticos separados. O primeiro
ensaio da quarta implementação falhou por testar uma mensagem de erro posterior
a outra validação. A ordem foi corrigida; a exigência não prevista de estado
vazio após configuração foi retirada, conservando o reinício separado estrito.
Não se normalizaram dados históricos para fazer passar o auditor.
