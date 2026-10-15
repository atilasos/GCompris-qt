# Revisão Spec da tarefa 32

Comparação: `git diff f5f858e8a...19c8c0826a120383648362fead8dec732bdbc3a9`.

**Sem achados de Spec no âmbito delimitado.**

A tarefa 32, linhas 10–14, exige os 17 níveis dos cinco datasets, pesquisa pelas
pistas visíveis, ambos os teclados, Backspace, Enter/OK, transições e controlos,
sem ler/atribuir o segredo nem emitir Bonus. O caso usa apenas entrada real,
texto do intervalo e pistas apresentadas para manter limites de uma pesquisa
binária independente. Não consulta `numberToGuess` nem chama `setUserAnswer`.

O resultado final regista 34 percursos completos, 180 pistas de demasiado alto
e 174 de demasiado baixo, com zero falhas e sem erros QML. Cada nível valida o
intervalo PT esperado e avança pelo Bonus original. O caso de controlos confirma
reinício com resposta pendente, anterior/próximo, ajuda PT, fecho e menu. Isto
sustenta a conclusão exigida pela spec, linhas 30–35, para o lote descrito.

A única alteração de produção corrige `</li></li` para `</li><li>` na ajuda. O
caso reforçado falha antes e passa depois, exigindo a instrução Enter num item
HTML completo. A correção corresponde à ajuda funcional/portuguesa pedida pela
spec, linhas 27–29 e 39–40. Não acrescenta funcionalidades.

O inventário inicial de cinco níveis foi corrigido para os 17 níveis reais dos
cinco datasets, ampliando a verificação à atividade existente, conforme a spec,
linhas 10–13, e sem ocultar níveis. A evidência distingue os ensaios e os limites
da seleção de datasets.

Windows, escola, dispositivos físicos, audição e revisão docente são
expressamente pendentes. A conclusão local não substitui os critérios globais
da spec, linhas 41–45 e 54–55. Não encontrei requisito delimitado ausente,
implementação contrária ou scope creep. Revisão por leitura do diff/fontes e dos
artefactos existentes; não executei novo ensaio Qt nesta revisão.
