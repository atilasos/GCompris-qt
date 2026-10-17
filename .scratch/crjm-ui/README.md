<!-- SPDX-FileCopyrightText: NONE -->
<!-- SPDX-License-Identifier: CC0-1.0 -->
# Revisão das oito interfaces CRJM no GCompris

O utilizador mostrou quatro capturas em que os controlos ocupavam quase todo o
ecrã e os tabuleiros eram minúsculos ou desapareciam. A validação anterior era
insuficiente: redimensionava a janela num ecrã virtual pequeno, sem reproduzir
a escala do monitor real. Este trabalho revê as oito atividades para dar
prioridade ao tabuleiro e às ações de jogar, no contexto nativo do GCompris.

## Causa reproduzida

O perfil Qt offscreen de 2048×1152 usa `ApplicationInfo.fontRatio=2.4`.
Na build anterior, a janela de 2048×1100 deixava Faísca com largura −52,8 px
e altura −44 px. Os textos e botões cresciam com a escala do monitor e os
Flows de controlos consumiam a altura reservada ao tabuleiro.

A opção nova `--screen-size` configura o ecrã real da plataforma offscreen
antes de iniciar Qt. O caso rápido `tests/crjm/ui-scale.qml` confirma também
`Screen.width` e `Screen.height`, para não confundir uma janela maior com um
ecrã maior. O mesmo caso fica vermelho na build anterior e verde na nova.

## Disposição e interação

A apresentação usa três componentes QML nativos: `BoardGameLayout`,
`BoardGameButton` e `BoardGameText`. São componentes visuais, sem estado de
jogo ou motor de regras comum. Cada atividade conserva as suas regras,
WorkerScript, tabuleiro e controlos. Os módulos `.mjs` não foram alterados.

O tabuleiro tem uma área própria. Em paisagem, as ferramentas ficam ao lado;
em retrato, numa faixa inferior. As opções secundárias podem deslizar sem
encolher o tabuleiro. O foco por Tab traz o controlo para a área visível e o
regresso ao tabuleiro recupera as ações principais. O tamanho dos textos e
botões depende da janela disponível, respeita a escolha de tamanho de texto
com um mínimo legível e não se multiplica pela escala do monitor inteiro.
A barra nativa de ajuda, início e reinício acompanha as dimensões da janela.

| Jogo | Revisão |
| --- | --- |
| Dominório | Tabuleiro 8×8 amplo, previsão legível, confirmação destacada e orientação no cabeçalho. |
| Gatos & Cães | Tabuleiro amplo, abertura central visível e peças com imagens de gato e cão do GCompris, além da identificação textual. |
| Faísca | Distância e direção compactas, destinos possíveis assinalados e escolha direta de origem/destino. A seleção pode ser limpa antes de confirmar. |
| Quelhas | Tabuleiro 10×10 amplo, seleção e confirmação juntas e orientação/turno legíveis. |
| Atari Go | Tabuleiro de madeira 9×9 em escala jogável e modo de inspeção visualmente selecionado. |
| Produto | Tabuleiro completo, paleta de cores selecionada, confirmação junto da paleta e opções da partida separadas. |
| Y | Grafo completo na vista inicial, menos rótulos nos nós vazios, lados assinalados e ampliação para toque com deslocação. |
| Nex | Tabuleiro completo e centrado, modo de ação assinalado, ampliação para precisão e percurso de foco corrigido para os exercícios finais. |

A função de seleção direta de Faísca usa a mesma validação de regras que o
resto do jogo. Uma previsão não consome peças nem muda o turno. A confirmação
continua a executar a jogada completa. A entrada anterior por direção e
distância, assim como o teclado, continua disponível.

As imagens `cat.svg` e `dog.svg` foram copiadas sem alterar o desenho de
`explore_farm_animals/resource/animals/`. Autoria: Timothée Giet, 2020,
CC-BY-SA-4.0. Os metadados originais e as atribuições foram preservados;
REUSE e o crédito da atividade identificam esta reutilização. Não são imagens
CRJM nem se lhes atribui uma licença GPL nova.

## Verificação

Comandos reproduzíveis em [tests/crjm/README.md](../../tests/crjm/README.md).
A auditoria visual percorre o menu real, abre os oito jogos e verifica as
janelas 2048×1100, 1280×800, 800×600 e 600×900. Exercita texto mínimo,
normal e máximo, a vista geral e ampliação de Y/Nex, uma jogada completa,
a ajuda sem perda do turno e os modos contra Tux.

A regressão funcional percorre os 16 casos dos oito jogos, Quatro-em-linha e
teclado de Dominório. Usa os RCC reais do CMake, sem `--extra-activity`, rede
Docker `none`, perfil separado e renderização software. O perfil de desempenho
usa 1 CPU e 512 MiB sem swap. As capturas não representam um tablet físico nem
uma observação com crianças.

Os resultados finais, comandos, capturas e manifesto acompanham esta pasta.
A build é local, usa o Qt instalado nesta máquina e não foi publicada.

## Medições de resposta

Uma ronda com 1 CPU falhou a medição global de Quelhas com 252 ms, face ao
limite de 250 ms. O temporizador anterior abrangia também o carregamento do
menu, as capturas PNG e o resto do código de teste. Uma execução instrumentada
por fases registou o maior intervalo no menu, com 200 ms, não na partida.
Os dois registos são conservados como diagnóstico.

O caso final mede separadamente a partida contra Tux, desde antes do primeiro
despacho até ao resultado, incluindo o último intervalo mesmo que uma pausa
síncrona termine antes do callback do temporizador. A métrica global e a sua
fase continuam a ser registadas. O limite de 250 ms da partida e o limite de
2 s da resposta não foram aumentados. Esta medição corresponde ao requisito
de manter a interface a responder enquanto Tux calcula; não usa a gravação
de capturas pelo próprio teste como uma medição de IA.

## Capturas da build revista

As capturas seguintes usam o texto máximo. As imagens dos modos Tux,
ampliação e primeiras jogadas também estão em `evidence/ui/`.

| Jogo | Ecrã grande | Retrato |
| --- | --- | --- |
| Dominório | [2048×1100](evidence/ui/DOMIN-2048-font7.png) | [600×900](evidence/ui/DOMIN-600-font7.png) |
| Gatos & Cães | [2048×1100](evidence/ui/GATOS-2048-font7.png) | [600×900](evidence/ui/GATOS-600-font7.png) |
| Faísca | [2048×1100](evidence/ui/FAISC-2048-font7.png) | [600×900](evidence/ui/FAISC-600-font7.png) |
| Quelhas | [2048×1100](evidence/ui/QUELHAS-2048-font7.png) | [600×900](evidence/ui/QUELHAS-600-font7.png) |
| Atari Go | [2048×1100](evidence/ui/ATARI-2048-font7.png) | [600×900](evidence/ui/ATARI-600-font7.png) |
| Produto | [2048×1100](evidence/ui/PRODUTO-2048-font7.png) | [600×900](evidence/ui/PRODUTO-600-font7.png) |
| Y | [2048×1100](evidence/ui/Y-2048-font7.png) | [600×900](evidence/ui/Y-600-font7.png) |
| Nex | [2048×1100](evidence/ui/NEX-2048-font7.png) | [600×900](evidence/ui/NEX-600-font7.png) |


## Resultado e arranque

A auditoria passou 96 perfis de interface dos oito jogos, com texto mínimo,
normal e máximo. As vistas Tux e a ampliação para toque também passaram.
Os 18 percursos funcionais finais passaram: zero falhas, zero erros QML e zero
OOM, com 1 CPU e 512 MiB. O pico máximo observado foi 287129600 bytes, cerca
de 274 MiB. Os resultados em `evidence/matrix/` incluem os comandos, hashes,
limites efetivos e tempos. `evidence/summary.json` resume o conjunto.

Na ronda final, Quelhas registou 46 ms de heartbeat durante a partida contra
Tux, resposta máxima de 1230 ms incluindo a primeira consulta da ajuda, e
197 ms de intervalo global na fase do menu. Y e Nex também concluíram as
partidas reais e a verificação de cancelamento. A correção do foco de Nex e a
adaptação do toque em Y conservaram os respetivos recibos anteriores em
`evidence/nex-focus-red/` e `evidence/y-touch-old-fixture/`.

Todos os resultados finais usam exatamente os nove RCC novos: core e os oito
jogos. Não se recompilaram os jogos dentro do teste. Os restantes 271 ficheiros
do artefacto são idênticos à build anterior. O manifesto final está em
`evidence/artifact-manifest.json`, e os hashes de fontes em
`evidence/source-hashes.json`. O caso rápido de escala fica vermelho na build
anterior e verde na nova com o mesmo SHA-256 de teste.

A build atualizada mantém o comando:

```sh
./build/crjm-complete/run-crjm.sh
```

Fecha uma instância antiga antes de a reabrir. A build anterior foi preservada
em `build/crjm-before-ui`. Não houve publicação, alteração do CRJM original ou
validação em tablet físico. As capturas são da aplicação Qt real, com toque
sintético nos testes que o exercitam.


A verificação REUSE identificou também um aviso anterior no runner, que não
tinha titular de direitos registado. O cabeçalho usa `NOASSERTION` para manter
essa ausência de atribuição, preservando a licença GPL existente. Não foi
inventado um autor. Esta alteração de metadados foi feita depois dos testes;
o corpo executável do runner não mudou.
