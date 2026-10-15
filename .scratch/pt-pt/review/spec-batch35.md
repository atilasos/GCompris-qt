# Revisão Spec das tarefas 30, 31 e 35

Comparação: `git diff 877eed623b0e44d093ec37e95a51ba38063d7768...5dfd78a0d5db70b2f552f8ef4bdff26aa0750a40`.

**Sem achados de Spec nos âmbitos delimitados.** A tarefa 29 está excluída.

As tarefas 30 e 31, linhas 10–18, pedem puzzles completos por eventos Qt,
referência independente, negativos, transições e controlos. Os casos arrastam,
clicam e escrevem nas interfaces reais. Não atribuem fases, respostas finais,
pontos ou Bonus. Os dados observados são confrontados com referências separadas,
conforme a spec, linhas 30–35. Reexecutei os auditores sobre os artefactos: 316
puzzles das 16 campanhas decimais e 90 puzzles/253 linhas dos quatro jogos de
complemento passaram. Os oito hashes/resultados finais de complemento também
conferem, incluindo 88 negativos e quatro casos de controlos.

As amostras aleatórias e os subconjuntos de datasets não exaustivos estão
explicitamente limitados. As orientações, estados de teclado e ajuda visual
exercitados estão discriminados. Os diagnósticos de layout/timers da fixture
não são apresentados como defeitos de produção. Estes dois lotes não alteram
`src` nem usam as fases preparadas da tarefa 28 para alegar resolução.

A mensagem do professor, "Ouvi as 32 e aprovo", autoriza a revisão final dessas
32 gravações, prevista na spec, linhas 36–42. A tarefa 35, linhas 10–16, liga
aprovação a texto e SHA256 por ficheiro. Confirmei independentemente o ZIP ouvido,
checksum `cc48b858…e119e`, os 32 textos/hashes nele contidos e os bytes atuais.
O ZIP original permanece preservado. A igualdade exata de texto/hash mantém
aprovações individuais; texto ou áudio alterado deixa apenas esse recurso
pendente. Os testes por CLI cobrem essa distinção e o log completo regista 44
passagens. O RCC real confere com `4887e4a8…528ee`, preservando os 1578 originais.
Não houve regeneração de áudio ou alteração de recursos/licenças.

Não encontrei requisito delimitado ausente, implementação contrária ou scope
creep. Aprovar estas gravações não aprova todas as atividades ou os restantes
textos: reprodução contextual, Windows/escola, dispositivos físicos e aceitação
global continuam separados, conforme a spec, linhas 43–55. Não executei novamente
as campanhas Qt nem os 44 testes nesta revisão; revalidei auditores, hashes e ZIP.
