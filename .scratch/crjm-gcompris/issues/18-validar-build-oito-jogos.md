# 18: Validar os oito jogos numa build do fork

Status: ready-for-agent
Type: task
Progress: claimed
Blocked by: 05, 07, 09, 11, 13, 15, 17
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno usa uma build do nosso fork com os oito jogos acessíveis e funcionais sem rede, nos modos de duas pessoas e contra Tux, em computador e tablet.

## Acceptance criteria

- [ ] A build contém os oito jogos e todos os recursos necessários. Gatos & Cães e Nex continuam disponíveis apesar de integrarem o arquivo jogável CRJM.
- [ ] Numa execução sem rede e com perfil separado, cada jogo abre pelo menu, aceita jogadas, apresenta ajuda, conclui uma partida e regressa ao menu nos dois modos.
- [ ] Rato, teclado e toque permitem executar as ações, incluindo turnos compostos. A apresentação permanece utilizável em dimensões de computador e tablet, com retrato quando suportado.
- [ ] O conjunto preserva a resposta durante o cálculo de Tux e não recebe ações tardias após saída, reinício ou mudança de atividade.
- [ ] Textos PT-PT, identificação além da cor, contraste e atribuições são verificados na build. Os componentes reutilizados têm origem e permissões registadas e compatíveis antes de distribuir.
- [ ] Os percursos do conjunto são reproduzíveis e guardam comandos, versão da build, resultados, tempos e capturas aplicáveis. As referências CRJM justificam os casos especiais.
- [ ] As atividades de estratégia existentes continuam acessíveis e funcionais numa verificação de regressão proporcional às alterações partilhadas.
- [ ] A validação não publica a build, não contacta mantenedores upstream e não declara realizada uma observação pedagógica com crianças.

## Comments

Divisão e dependências aprovadas pelo utilizador. Aplicam-se as decisões da especificação principal.
