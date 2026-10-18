# Aceitação da build completa CRJM

O artefacto local final é
`/home/proteu/Projetos/GCompris-qt/build/crjm-complete`, versão 26.2,
compilada com Qt 6.10.2 e GCC 15.2. O lançamento normal nesta máquina é:

```sh
/home/proteu/Projetos/GCompris-qt/build/crjm-complete/run-crjm.sh
```

É uma build Linux que usa as bibliotecas Qt instaladas. Não é um instalador
portátil nem uma build Android/Windows. Sobrevive à remoção da worktree 18.
`build-metadata.json` identifica compilação, fontes, host e limites;
`artifact-manifest.json` identifica o binário, todos os RCC, dados, traduções,
plugin Box2D e launcher por SHA-256. O manifesto da baseline identifica a origem
dos dados offline anteriores. `provenance-audit.md` regista os termos e limites
sem relicenciar a plataforma ou os desenhos CRJM.

## Percurso reproduzível

A compilação usa os comandos em `tests/crjm/README.md`; os logs completos estão
em `configure.log`, `build.log`, `menu-build.log` e `gatos-rebuild.log`.
O alvo `all_activities` não inclui o menu: é necessário `rcc_menu`. O primeiro
smoke não instrumentado demonstrou essa falta (`standalone-red.log`); depois de
compilar o alvo, a aplicação permaneceu sete segundos a executar o menu sem
instrumentação e sem erro QML (`standalone-green.log`). O código 124 dessa
verificação é a interrupção deliberada por `timeout`, não um resultado de jogo.

A matriz canónica é executada em série pelo comando:

```sh
python3 tools/run-crjm-acceptance.py \
  --resource-snapshot /home/proteu/Projetos/GCompris-qt/build/crjm-complete \
  --output /tmp/crjm18-acceptance \
  --offline-cpus 1 --offline-memory-mib 512
```

Cada atividade abre pela pesquisa do menu real, sem `--launch` e sem
`--extra-activity`. Só o menu recebe QtTest e só o catálogo PT é recompilado pelo
runner. Todos os recursos dos jogos e o catálogo de atividades são os RCC da
compilação CMake. Os casos usam os controlos reais e as posições CRJM registadas
nas entregas 02–17; não atribuem vencedores nem substituem as regras ou Tux.
`matrix/summary.json` regista os comandos e tempos; cada subpasta conserva
`result.json`, `native.log` e as capturas. Os dois passes QtTest de cada caso
incluem a inicialização/limpeza; o número relevante é o de percursos nativos.

Docker usa rede `none`, perfil separado, host só de leitura e renderização
software. A cota final é 1 CPU / 512 MiB, sem swap. Cada log lê diretamente
`cpu.max=100000 100000` e `memory.max=536870912`; o resultado também regista
`memory.peak` e `memory.events`. O host é um i5-12600K com cerca de 46 GiB,
portanto a cota é um ensaio virtual, sem representar equipamento escolar real.
Mantêm-se os orçamentos do piloto: resposta de Tux inferior a 2 s, intervalo
máximo de heartbeat inferior a 250 ms e ajuda inferior a 1,5 s.

## Falha encontrada e correção

O ensaio de memória expôs uma falha que o host sem limites não revelava:
Gatos & Cães terminava com sinal 9 durante os primeiros turnos de uma partida
completa na dificuldade Difícil. O ensaio isolado de 512 MiB confirmou
`oom_kill=1`, pico de 536870912 bytes e código 137. O perfil 1 GiB também falhou
com `oom_kill=1`; não se resolveu aumentando indefinidamente o limite.

Os marcadores da própria aceitação UI localizaram a falha depois das três
respostas de dificuldade e da aprendizagem, no terceiro turno da partida
Difícil. A função de legalidade construía um array de vizinhos e uma closure
por candidato. O WorkerScript repete esse predicado na busca limitada, causando
crescimento de memória temporária antes da recolha de lixo. A correção usa os
mesmos quatro testes ortogonais diretamente, sem essas alocações. Não altera
aberturas, vizinhança, escolha de políticas ou limite da busca.

O mesmo caso real, no mesmo perfil de 512 MiB, passou depois: partida completa
de 13 turnos, pico 202133504 bytes, `max=0`, `oom=0` e `oom_kill=0`. A resposta
máxima registada foi 600 ms, incluindo a consulta de ajuda; heartbeat 31 ms e
ajuda 3 ms. A evidência red/green está em `gatos-memory-red/` e
`gatos-memory-green/`. Os diagnósticos anteriores e o manifesto anterior à
correção permanecem identificados separadamente; não contam como aceitação
final. Uma tentativa também foi rejeitada pelo verificador antes de arrancar
porque o launcher novo ainda não figurava no manifesto; o launcher tem agora
hash registado.

A primeira fixture de regressão Quatro-em-linha tentou sete teclas de colocação
com o rato parado fora das colunas. O callback existente após a queda reposiciona
a seleção pelo rato, pelo que a sequência não ocupou as colunas esperadas. O
percurso canónico usa cliques reais nas duas colunas até quatro peças alinhadas,
seguido de ajuda e regresso ao menu. Não se alterou Quatro-em-linha. A aceitação
de teclado dos oito jogos novos permanece nos respetivos casos.

## Limites

As dimensões de computador e retrato/tablet são janelas reais da aplicação e o
toque é sintetizado por QtTest. Não se verificou ecrã tátil físico, hardware
escolar modesto, Windows/Android, som físico ou observação com crianças. A
validação por turma e por dispositivos reais continua pendente. Não houve
publicação, distribuição, contacto upstream ou alteração à aplicação CRJM.

A revisão visual das capturas finais verifica PT-PT, orientação e identidade de
participantes, marcas/números além da cor, tabuleiros e controlos em retrato e
computador. Y e Nex permitem deslocar o tabuleiro em retrato e mantêm a ajuda e
os controlos fora dessa área. As capturas e ações nativas demonstram essa
apresentação; não são uma auditoria estatística de contraste nem certificação
de tecnologia de apoio.

## Resultado canónico

Os 18 percursos passaram: 16 percursos dos oito jogos nos dois modos,
Quatro-em-linha e teclado de Dominório. Zero falhas, zero erros QML e zero
eventos OOM em todos os contentores. `acceptance-summary.json` resume tempos,
picos e métricas de cada jogo; os resultados integrais estão em `matrix/`.
