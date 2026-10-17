# 16: Nex para duas pessoas

Status: ready-for-agent
Type: task
Progress: resolved
Blocked by: 03
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno abre Nex pelo menu e joga uma partida completa com outra pessoa no mesmo dispositivo, com peças neutras, ações de colocação e substituição, troca inicial e vitória por conexão.

O ticket 03 conclui o piloto nativo e estabelece o precedente de integração e validação reutilizado nesta entrega. Não depende da implementação dos outros jogos.

## Acceptance criteria

- [x] O tabuleiro hexagonal 11×11 distingue peças próprias, adversárias e neutras por sinais além da cor.
- [x] A colocação usa uma peça própria e uma neutra. A substituição converte duas neutras em próprias e uma própria em neutra.
- [x] Cada ação composta permite corrigir a seleção antes da confirmação e só passa o turno quando está completa e válida.
- [x] A troca inicial atualiza cores, margens e turno sem confundir a identidade dos participantes. As condições de conexão e finais raros seguem a referência CRJM.
- [x] O teste nativo cobre colocação, substituição, tentativa incompleta ou inválida, troca, conexão e as convenções de final relevantes.
- [x] A atividade funciona sem rede e não exige contas, serviços CRJM, GPU ou runtime de browser.
- [x] O aluno consulta ajuda PT-PT sem perder a posição, reinicia com o estado inicial correto e regressa ao menu.
- [x] Rato, toque e teclado permitem executar as ações desta entrega. Participantes e turno são reconhecíveis por sinais além da cor.
- [x] Textos usam o sistema de traduções GCompris. Recursos reutilizados conservam atribuição, origem e licença registadas.
- [x] O teste de aceitação executa a aplicação Qt real, começa no menu e verifica ações e resultado observáveis. Usa posições CRJM para casos especiais, sem substituir a validação ou forçar o vencedor.
- [x] Guardar os comandos e resultados da validação desta entrega. O build e os testes TypeScript originais não substituem o percurso nativo.

## Comments

Divisão e dependências aprovadas pelo utilizador. Aplicam-se as decisões da especificação principal.

## Answer

Implementada a atividade nativa Nex para duas pessoas, com ações compostas atómicas e corrigíveis, validação de cor/índices/duplicatas, troca de cores e margens preservando identidade, conexões nas duas orientações e três exercícios reais de convenções raras. Ajuda PT-PT, rato, toque, teclado, ampliação/deslocação e reinício/regresso ao menu. Sem recursos copiados CRJM.

Validação Qt real offline desde menu: 0 falhas, 2 passes, nenhum erro QML. Percursos completos legais de 21 e 22 turnos verificados contra CRJM, vitória negra e branca respetivamente. Evidência em `.scratch/crjm-gcompris/evidence/16-nex/`, incluindo comandos, limitações e screenshots desktop/retrato inspecionadas. Ticket17 acrescenta IA e aprendizagem geral.
