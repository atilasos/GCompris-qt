# Plano de grelhas observadas

```python
from pattern_grid_solver import plan, wrong_alternatives
result = plan(question_cells, answer_frames, palette_samples, mirror=False)
```

As duas interfaces recebem apenas observações públicas. Uma célula da pergunta é
`{'frame': {'x': ..., 'y': ..., 'width': ..., 'height': ...}, 'signature': ...}`.
Um alvo tem apenas o mesmo `frame` aninhado. As coordenadas são centros visíveis,
na mesma unidade dentro de cada grelha. A pergunta e a resposta podem usar
origens, escalas e margens diferentes. Não existe uma segunda forma com campos
geométricos diretamente no objeto.

Uma amostra de paleta é `{'id': ..., 'signature': ...}`. O chamador calibra a
assinatura através da pintura efetiva oferecida pela interface. O módulo recebe
JSON finito e compara a representação exata, sem interpretar cores, alfa,
ficheiros ou nomes. Preserva, por exemplo, a assinatura ARGB `'#33ffffff'`.
Booleanos e números são distintos. IDs também são dados opacos, nunca posições.

`plan` devolve `rows`, `columns`, `placements` e `diagnostics`. Cada colocação
contém `question_frame`, `target_frame`, `signature` e `palette_id`, copiados sem
alterar as entradas. A ordem das colocações segue a geometria da pergunta,
de cima para baixo e da esquerda para a direita. A ordem das três listas de
entrada não determina o resultado correto. `mirror=True` inverte apenas as
colunas e exige uma escolha booleana explícita do modo público.

A geometria tem de formar dois retângulos regulares completos com o mesmo
número de linhas e colunas. Larguras e alturas são constantes em cada grelha,
com tolerância fixa de uma milionésima da dimensão da célula. Os passos podem
incluir margens regulares e não podem fazer células sobreporem-se. A verificação
recusa posições duplicadas, lacunas internas, passos irregulares, dimensões
inconsistentes ou não finitas, assinaturas sem paleta e IDs/assinaturas de paleta
duplicados. Replicações da mesma assinatura em células diferentes são válidas.
Não aumenta tolerâncias para obter uma resposta.

O retângulo inferido limita-se aos dados visíveis recebidos. Sem moldura externa,
uma fila inteira ausente nas duas listas é indistinguível de uma grelha menor.
O módulo não inventa dimensões ocultas, não lê autoria nem valida conclusões.

`wrong_alternatives(placement, palette_samples)` devolve todos os IDs calibrados
com assinatura diferente da colocação. A ordem dessa lista não tem significado;
o chamador pode escolher uma alternativa pública visível para um ensaio errado.
Recusa paleta ambígua, assinatura sem correspondência e ausência de alternativa.

```sh
PYTHONPATH=tests python3 -m unittest discover -s tests/pattern_grid_solver -p 'test_*.py' -v
PYTHONPATH=tests python3 -O -m unittest discover -s tests/pattern_grid_solver -p 'test_*.py' -v
```

Sete testes atravessam as interfaces públicas com exemplos literais, sem mocks,
Qt, imagens de autoria ou valores esperados calculados pelo próprio módulo.
`proof/` conserva os seis ciclos de falha/sucesso e a execução com otimização.
Estes resultados provam contratos do módulo puro; os percursos nativos e a
cobertura dos jogos pertencem à campanha da tarefa90.
