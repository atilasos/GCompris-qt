# Puzzles deslizantes de quinze e dezasseis peças

Os 14 níveis de cada atividade foram concluídos naturalmente em Qt Linux offline, com `pt_PT`. O quinze teve 383 movimentos de resolução sem dicas; o dezasseis teve 115 rotações de resolução com dicas realmente apresentadas na interface. Houve mais dois movimentos não resolventes e inversos em cada nível, 56 movimentos adicionais. Cada nível terminou com ordem final conferida e Bonus positivo, seguido do nível seguinte ou volta ao primeiro. Os dois tracers iniciais são provas adicionais e não aumentam a contagem de 28 níveis.

São sete níveis com números e sete apenas com imagem por atividade. Os níveis 1–4 usam o barco e 5–14 a paisagem costeira. Não há datasets selecionáveis nem configuração própria. Uma mistura aleatória normal foi concluída por nível; isto não esgota todas as permutações possíveis. As teclas, cliques e arrastos foram alternados no quinze. A campanha dezasseis usa cliques nas setas, com teclado verificado separadamente nos controlos.

## Tabuleiro observado e algoritmo

O observador usa a geometria das peças efetivamente desenhadas, o `clip` e a translação aplicada ao `Image` SVG de cada recorte. O recorte de coluna/linha identifica a peça, inclusive nos níveis sem números. Nos níveis numerados confere também o texto efetivamente desenhado. Espera pela imagem pronta e pelo fim normal das animações de 250 ms, sem alterar relógios ou velocidades. Não usa `val`, `value`, modelos, listas de mistura, solução ou histórico privado.

O quinze resolve o tabuleiro visível por etapas: fixa as primeiras duas peças de cada linha, insere o par final, depois fixa pares das duas linhas inferiores e termina o quadrado 2×2. Cada etapa faz BFS abstrata da posição do espaço vazio e das peças dessa etapa, conservando as casas já fixadas. A busca segue no máximo quatro posições distintas num tabuleiro de 16 casas, em vez de explorar todas as permutações do quinze. Não procura uma solução ótima; os percursos observados variaram de 2 a 99 movimentos. O auditor Python verifica cada troca pela adjacência ortogonal ao espaço vazio e a continuidade entre os tabuleiros.

O dezasseis ativa o botão de dica por clique e observa qual seta está realmente realçada pela cor desenhada. Não consulta `hint`, `displayedHint`, `currentHint`, `hintList` ou `initialOrder`. O auditor aplica uma rotação independente da linha/coluna no sentido da seta e confere o tabuleiro seguinte. As 14 conclusões do dezasseis são explicitamente assistidas por dicas; não demonstram resolução sem dicas.

Dois movimentos extra por nível demonstram uma alteração legal que não vence e a sua reparação inversa. Não há botão de validação nem Bonus negativo nestes jogos; uma alteração incompleta mantém o jogo em curso. O quinze também rejeita um clique não adjacente.

## Controlos e correção de texto

Os controlos verdes verificam navegação anterior/seguinte e volta circular, números ocultos no nível par, ajuda PT/Escape, foco e input após a ajuda, e regresso ao menu. No dezasseis, conferem quatro teclas de navegação pela borda realmente desenhada do botão selecionado, ativação por Espaço e Return, dica ligada/desligada sem mover o tabuleiro, e reposição exata da mistura inicial por Recarregar. Um caso adicional do quinze deixa uma alteração parcial com mais de duas peças deslocadas, muda de nível e regressa ao primeiro; o tabuleiro foi reiniciado, com duas peças deslocadas.

A ajuda do quinze apresentava "Carrega ou arrasta todas as peças ... movrt para o espaço vazio." O mesmo caso nativo passou de vermelho para verde depois de corrigir apenas esse `msgstr` para "Clica ou arrasta uma peça junto ao espaço vazio para a mover para esse espaço." SHA-256 do caso idêntico nas duas fases. A correção não recebeu aprovação docente por associação a gravações anteriores.

As campanhas completas usam a fase `baseline`, Git ad2db3035. A ajuda verde e os controlos usam `final`, Git 6f50272ee. A única diferença entre as fontes dessas fases é esse `msgstr`; as provas funcionais anteriores continuam válidas e a frase corrigida tem prova dirigida. A mecânica, os dados de mistura e o áudio não foram alterados.

Seis tentativas de controlos ficam como diagnóstico, sem aprovar percursos: as duas primeiras versões por jogo tentavam usar um singleton que não estava importado no contexto lexical do harness. A terceira versão chegou ao menu e teve zero falhas QtTest, mas imprimiu o erro esperado capturado como texto dentro do marcador; o scanner conservador do launcher identificou esse texto e devolveu 1. O caso final omite essa sondagem e importa o singleton apenas num objeto de bootstrap para retirar o modo `--launch`, antes do clique real em Home. Essa alteração só afeta metadados do lançamento isolado, não altera peças, progresso ou validação. Todas as versões e retornos originais foram preservados.

A inspeção das capturas encontrou texto inglês na arte comum `Coastal_Path.svg`, "Coast Path" e "Miles", nos níveis 5–14 dos dois jogos. Uma terceira fase, `localized`, Git 9bae42ea5, adiciona `Coastal_Path-pt.svg` e seleciona a variante quando `ApplicationInfo.getVoicesLocale(ApplicationSettings.locale) === "pt"`, seguindo o padrão existente de `memory-wordnumber`. O original continua byte a byte igual para as outras línguas.

A variante altera apenas os três textos SVG para "Rota", "Costeira" e "milhas". Todos os atributos, caminhos, geometria, licença e o número 125 são iguais. O teste XML confere essa diferença exata e a ausência dos três termos ingleses. A renderização QtSvg e as capturas nativas confirmam que as letras cabem nas placas. A grelha reparte naturalmente a placa entre peças contíguas; nenhum texto ocupa o recorte vazio da peça 16. A imagem reconstituída está em `localized-art.png`, com limites de texto em `art-labels.json`.

O mesmo caso dirigido, por cliques reais até ao nível 5, passou de vermelho a verde em ambos os consumidores. Confere a fonte SVG efetivamente desenhada e uma alteração legal seguida da inversa. Um caso `en_US` confirma o recurso original como fallback. Estes percursos dirigidos não se apresentam como novas conclusões completas de 28 níveis em PT final. A composição da prova conserva as 28 conclusões mecânicas anteriores, o vermelho/verde da ajuda e as provas dirigidas da arte na fase localizada.

Um caminho errado introduzido na preparação chegou a gerar um snapshot de RCC vazios. Nunca foi executado em Qt nem incluído nas identidades selecionadas. O helper passou a verificar o manifesto e todos os ficheiros da fonte antes da preparação, com teste vermelho/verde. O snapshot localizado usado pelos casos tem fontes corretas verificadas, mapas completos e um nome de saída distinto.

## Arquivo e retornos

O snapshot privado foi copiado e selado antes da reconstrução do main build: 269 ficheiros físicos, sem symlinks para o build principal. Os RCC de core, quinze e dezasseis foram reconstruídos numa árvore privada a partir das fontes congeladas antes de executar as campanhas.

`source-tree.zip` contém 673 ficheiros físicos: 224 em `baseline`, 224 em `final` e 225 em `localized`. O auditor não usa Git, paths absolutos históricos ou o catálogo atual. Verifica os fontes, catálogo, launcher e supervisor arquivados, mapas dos três RCC e manifestos transitivos. A raiz de captura e o ZIP têm SHA-256 fixos no auditor. Casos, capturas, logs e recibos são preservados exatamente. Os testes copiam a prova e o auditor para uma pasta independente, adulteram fontes/recursos/casos/rotas/estados com selos recalculados e verificam recusa. As ferramentas recusam explicitamente Python `-O`.

Cada caso tem três observações externas distintas: `launcher-status.json` emitido após esperar pelo launcher e limpeza, `supervisor-exit.json` emitido pelo runner após esperar pelo supervisor, e `tool-exit.json` transcrito da resposta final efetiva de `write_stdin`, com sessão e chunk. Cada camada liga o hash do recibo e do caso. O estado nativo não é usado para inferir o estado externo.

```sh
python3 tests/functional_sliding/audit.py
python3 -m unittest discover -s tests/functional_sliding -p 'test_*.py'
```

Para auditar sem repositório, copiar `audit.py` e `oracle.py` para a mesma pasta e passar a cópia física das provas com `--evidence CAMINHO`. Não há chamadas Qt, Git ou rede nesse auditor. As linhas de progresso não contam como recibos finais.

Para novo ensaio, usar outra saída, fontes congeladas e outro snapshot. Não substituir os originais.

```sh
python3 tests/functional_sliding/phase.py --revision COMMIT
python3 tests/functional_sliding/prepare.py --origin-snapshot SNAPSHOT_IMUTAVEL --source-root FONTE_CONGELADA --output NOVO_SNAPSHOT
python3 tests/functional_sliding/run.py --source-root FONTE_CONGELADA --snapshot NOVO_SNAPSHOT --activity fifteen --output NOVA_SAIDA
python3 tests/functional_sliding/run.py --source-root FONTE_CONGELADA --snapshot NOVO_SNAPSHOT --activity sixteen --controls --output OUTRA_SAIDA
```

## Limites

Os WAV `flip` e `bonus` foram descodificados por software em GStreamer para `fakesink`, com hashes originais. O Qt corre muted/offscreen. Isso não prova audição ou reprodução física. Não se geraram vozes nem se alteraram aprovações ou WAV.

Windows 10/11, toque e teclado físicos, acessibilidade, perceção visual e revisão linguística/pedagógica docente continuam pendentes. A arte original inglesa permanece para as línguas que não usam a variante PT. Nenhum critério global foi aprovado por este lote.
