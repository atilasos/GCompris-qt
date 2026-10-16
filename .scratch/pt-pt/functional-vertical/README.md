# Operações verticais: prova nativa PT-PT

A campanha final concluiu360 exercícios,120 em cada atividade:
`vertical_addition`, `vertical_subtraction` e
`vertical_subtraction_compensation`. São12 datasets por atividade, cada um
com10 exercícios, sem saltar o último subnível. O lançador executou12 casos
isolados de três níveis cada. Todos tiveram Qt0, lançador0, sem timeout ou
erros QML, sem rede e com cópias privadas limpas. O supervisor terminou0. O índice seleciona23 casos finais verdes:12 campanhas,
três controlos, três entradas livres, dois negativos de diferença e três
regressões; todos usam a fase `complete` após as quatro correções.

Esta é uma prova Linux. Não certifica Windows, teclado/rato físicos, audição,
pronúncia, aprovação docente ou a matriz global203. As operações aleatórias
observadas não esgotam todos os números possíveis. No modo livre foram
introduzidas dez operações concretas por variante; os casos extras exercitam
linhas vazias e entradas inválidas.

## Oráculo e ações

O caso lê os algarismos GCText da grelha e os operandos do pedido visível.
Não lê `expected`, `computedValue`, `board.result`, modelos de soluções,
listas JS ou validadores. Todas as alterações de algarismos e anotações usam
cliques Qt nos controlos e nos menus numéricos realmente expostos. A confirmação
alterna entre Enter e o botão OK. Não se acelera Score, ErrorRectangle ou Bonus,
nem se escreve progresso. O caso espera as animações e a passagem natural para
o nível seguinte, incluindo a passagem12→1.

O oráculo inteiro próprio soma/subtrai operandos e trabalha por colunas.
Calcula transportes, empréstimos na primeira linha ou compensação na última,
conforme a variante. Os menus são acionados nas posições das anotações e a
etiqueta escolhida tem de ficar visível. A auditoria Python volta a calcular
resultados e anotações independentemente dos validadores do produto.

A campanha final reparou36 respostas erradas e introduziu1034 anotações de
transporte/empréstimo/compensação. Os dez exercícios livres incluem transporte
múltiplo, empréstimo através de zeros, operandos zero e resultados zero.
Há uma imagem por exercício imediatamente antes da confirmação. Três casos
extras recusam operação vazia, uma única linha e um algarismo ausente no meio
do número, recuperando depois com duas linhas preenchidas e duas vazias.
As duas subtrações recusam também a diferença negativa e recuperam por cliques.

## Defeitos reproduzidos e corrigidos

| Fronteira | Vermelho preservado | Correção |
| --- | --- | --- |
| Resolver um exercício e voltar ao nível anterior | `previous-red`: nível1 começava com contador1 | `previousLevel` repõe subnível0 |
| Resolver um exercício e gravar nova seleção | `config-progress-red`: seleção nova começava com contador1 | `start` repõe subnível0 |
| Copiar um zero como5 | `copied-zero-red`: operação errada aceite e corrigida silenciosamente | `MathNumber.checkDroppedValues` compara também `expected==0` |
| Criar1−2 e deixar duas linhas vazias | `negative-own-red`: entrada negativa aceite sem aviso | verificação de sinal ignora linhas realmente vazias |

Os três primeiros casos têm verdes intermédios e verdes finais `*-complete`.
O quarto tem verdes finais nas duas subtrações. O conteúdo do caso é idêntico
em cada par vermelho/verde; só as fontes/recursos mudaram. Os recibos originais
não são reescritos. As observações e screenshots distinguem a fase de escrita,
o aviso de número negativo e a fase de resposta.

`MathNumber.qml` alterado só é instanciado por `VerticalSubtraction.qml`;
`checkDroppedValues` só é chamado por `subtraction.js`. As duas outras
atividades herdam esse motor. Os homónimos em `src/server/activities/` são
componentes separados, sem importação do ficheiro alterado e sem esse método.
`expected` e `value` são inteiros com sentinela−1 para posição vazia;
`>=0` passa a verificar o zero sem exigir algarismos nas posições−1.
As linhas livres vazias conservam `numberValue=-1`, mas deixam de entrar na
verificação do sinal. Não há consumidor adicional afetado fora das três variantes.

## Controlos e configuração

Os três casos em `controls/` cobrem ajuda traduzida, Escape, confirmação por
Enter após fechar a ajuda, erro/reparação de foco, setas, reinício, seleção
real12→11→12 datasets e persistência observada ao reabrir o diálogo. Gravar
atualiza o número de níveis; restaurar a seleção devolve12. O regresso ao menu
é feito pelo botão real. O caso limpa apenas `ActivityInfoTree.startingActivity`,
que identifica o arranque direto da CLI, para permitir observar o menu sem
novo arranque automático. Não altera respostas, datasets, progresso ou relógios.
A persistência provada é a reabertura real do diálogo no mesmo processo/perfil;
não se afirma aqui um segundo arranque completo da aplicação.

## Arquivo, fases e identidades

`full/` preserva os360 exercícios anteriores às correções; `intermediate/`
preserva os360 após as primeiras três fronteiras, antes da correção das linhas
vazias. Nenhum desses720 exercícios conta como conclusão final. Só `final/`
fornece os360 exercícios da matriz aceite pelo auditor. Os controlos
intermédios e os pilotos de calibração não são somados ao resultado final.

`receipt-inputs.json` liga cada um dos57 recibos à fase histórica exata:
`frozen-source/baseline`, `green` ou `complete`, e ao respetivo manifesto de
snapshot. O manifesto da fonte tem o seu próprio SHA256 por ligação e cobre
os QML, JS, dados, imagens, CMake e catálogo PO exatos. O auditor verifica fonte,
PO, caso, lançador histórico, binário, snapshot, recursos efetivos e screenshots.
O RCC privado com QtTest e o QM compilado substituem apenas as entradas
correspondentes do snapshot; os restantes hashes têm de coincidir exatamente.

As três fases foram conferidas por exportação Qt dos RCC reais:48 ficheiros
na baseline,49 na fase intermédia e48 na final. O ficheiro extra intermédio é
apenas `vertical_subtraction/CMakeLists.txt`, incluído pelo primeiro preparador
privado; o preparador final reproduz a exclusão de CMakeLists dos RCC normais.
Todos os bytes exportados correspondem às fontes congeladas. O snapshot contém
269 entradas físicas verificadas; nenhum ensaio modifica o build principal.

O índice sela todos os artefactos arquivados. As ligações são relativas à
pasta de evidência; caminhos absolutos históricos nos recibos ficam apenas
como metadados. O teste portátil monta só uma cópia da evidência e dois módulos
Python num contentor sem rede, em modo de leitura, e confirma que a worktree
original não existe nesse ambiente. Não usa fontes ou lançador atuais.

Oito testes Python/CLI passam. Os negativos adulteram seis identidades em
três fases e também caso, JS, PO, lançador, snapshot, inventário Qt e manifesto.
Os testes atualizam o índice externo temporário para que a rejeição tenha de
vir dos contratos de identidade internos, sem depender só do checksum externo.
A CLI recusa seleções vazias/inválidas antes de preparar dados e preserva todos
os bytes de uma saída existente. Um fixture subprocess normal comprova que
JSON verde com lançador1 e JSON falhado com lançador0 são ambos rejeitados.

## Repetição

```bash
python3 -m unittest discover -s tests/functional_vertical -p 'test_*.py' -v
python3 tests/functional_vertical/audit.py .scratch/pt-pt/functional-vertical
python3 tools/native_qml_resources.py --binary PREFIXO/bin/gcompris-qt --output SNAPSHOT_BASE_NOVO
python3 tests/functional_vertical/prepare.py --origin-snapshot SNAPSHOT_BASE_NOVO --source-root .scratch/pt-pt/functional-vertical/frozen-source/complete --output SNAPSHOT_FINAL_NOVO
python3 tests/functional_vertical/campaigns.py --snapshot SNAPSHOT_FINAL_NOVO --source-root .scratch/pt-pt/functional-vertical/frozen-source/complete --output RESULTADOS_NOVOS --jobs 6
```

As saídas têm de ser novas. A CLI inclui opções para campanhas curtas e
`--kind controls`. Os testes portáteis requerem a imagem Docker
`python:3.12-slim` já instalada; não fazem downloads. O Qt reportou ausência de
dispositivo de áudio, portanto não se afirma que os efeitos foram ouvidos.
