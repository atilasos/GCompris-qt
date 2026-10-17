# 18: Validar os oito jogos numa build do fork

Status: ready-for-agent
Type: task
Progress: resolved
Blocked by: 05, 07, 09, 11, 13, 15, 17
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno usa uma build do nosso fork com os oito jogos acessíveis e funcionais sem rede, nos modos de duas pessoas e contra Tux, em computador e tablet.

## Acceptance criteria

- [x] A build contém os oito jogos e todos os recursos necessários. Gatos & Cães e Nex continuam disponíveis apesar de integrarem o arquivo jogável CRJM.
- [x] Numa execução sem rede e com perfil separado, cada jogo abre pelo menu, aceita jogadas, apresenta ajuda, conclui uma partida e regressa ao menu nos dois modos.
- [x] Rato, teclado e toque permitem executar as ações, incluindo turnos compostos. A apresentação permanece utilizável em dimensões de computador e tablet, com retrato quando suportado.
- [x] O conjunto preserva a resposta durante o cálculo de Tux e não recebe ações tardias após saída, reinício ou mudança de atividade.
- [x] Textos PT-PT, identificação além da cor, contraste e atribuições são verificados na build. Os componentes reutilizados têm origem e permissões registadas e compatíveis antes de distribuir.
- [x] Os percursos do conjunto são reproduzíveis e guardam comandos, versão da build, resultados, tempos e capturas aplicáveis. As referências CRJM justificam os casos especiais.
- [x] As atividades de estratégia existentes continuam acessíveis e funcionais numa verificação de regressão proporcional às alterações partilhadas.
- [x] A validação não publica a build, não contacta mantenedores upstream e não declara realizada uma observação pedagógica com crianças.

## Comments

Divisão e dependências aprovadas pelo utilizador. Aplicam-se as decisões da especificação principal.

## Answer

Build CMake Linux 26.2 concluída e materializada fora da worktree em
`/home/proteu/Projetos/GCompris-qt/build/crjm-complete`. O launcher local é
`build/crjm-complete/run-crjm.sh` na raiz do checkout principal. O artefacto
contém os oito jogos, workers ES, ícones, catálogo, menu, traduções e os dados
offline/Box2D preservados da baseline verificada. Não altera `build/pt-pt`.

A matriz final passou 18 percursos reais desde o menu: os oito jogos em duas
pessoas e contra Tux, teclado de Dominório e uma partida completa de
Quatro-em-linha existente, com ajuda e regresso ao menu. Rede Docker `none`,
perfis separados, renderer software e cota virtual de 1 CPU / 512 MiB, sem swap,
confirmada pelos cgroups. Zero falhas, zero erros QML e zero eventos OOM; os
casos mantêm os orçamentos do piloto e incluem rato, teclado, toque sintético,
retrato, exercícios, regras especiais, revisão e cancelamento. A matriz usa
apenas os RCC reais do CMake para os jogos: não usa `--extra-activity`.

A aceitação expôs e corrigiu crescimento de memória em Gatos & Cães Difícil.
O mesmo percurso nativo falhava por OOM em 512 MiB e 1 GiB; um predicado de
vizinhança sem arrays/closures temporários preserva as regras e passou depois
com pico de cerca de 193 MiB. Red/green, marcadores de fase e memory.events
estão preservados. A build também passou smoke não instrumentado depois de
incluir explicitamente o alvo `rcc_menu`. Metadados REUSE dos ficheiros novos
foram corrigidos sem inventar autoria humana ou relicenciar materiais CRJM.

Comandos, versão, hashes, métricas, capturas e auditoria estão em
[18-build/README.md](../evidence/18-build/README.md),
[acceptance-summary.json](../evidence/18-build/acceptance-summary.json) e
[provenance-audit.md](../evidence/18-build/provenance-audit.md). A receita
reproduzível está em `tests/crjm/README.md` e `tools/run-crjm-acceptance.py`.

Os critérios de dispositivo referem-se à aplicação real em dimensões de
computador/tablet e eventos sintéticos. Não se afirma validação de tablet físico,
hardware escolar modesto, Windows/Android, som físico ou observação com crianças;
essa validação de campo continua pendente. A auditoria regista proveniência e
termos e não aprova uma distribuição externa. Não houve publicação, contacto
upstream ou alteração à aplicação CRJM.
