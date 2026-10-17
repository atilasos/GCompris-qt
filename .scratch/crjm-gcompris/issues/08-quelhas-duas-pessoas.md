# 08: Quelhas para duas pessoas

Status: ready-for-agent
Type: task
Progress: resolved
Blocked by: 03
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno abre Quelhas pelo menu e joga uma partida completa com outra pessoa no mesmo dispositivo, com seleção e confirmação de segmentos, troca inicial e resultado misère explicado.

O ticket 03 conclui o piloto nativo e estabelece o precedente de integração e validação reutilizado nesta entrega. Não depende da implementação dos outros jogos.

## Acceptance criteria

- [x] O tabuleiro tem 10×10 casas. Cada segmento tem comprimento mínimo dois e respeita a orientação do participante.
- [x] A seleção mostra o segmento completo, permite correção antes de confirmar e rejeita sobreposições sem alterar o turno.
- [x] O segundo participante pode trocar de papel na primeira oportunidade. A troca consome esse turno e atualiza as orientações.
- [x] O participante sem jogadas no seu turno ganha. O resultado explica que perde quem faz a última jogada.
- [x] O teste nativo cobre segmento inválido, comprimentos diferentes, troca e final misère de referência CRJM.
- [x] A atividade funciona sem rede e não exige contas, serviços CRJM, GPU ou runtime de browser.
- [x] O aluno consulta ajuda PT-PT sem perder a posição, reinicia com o estado inicial correto e regressa ao menu.
- [x] Rato, toque e teclado permitem executar as ações desta entrega. Participantes e turno são reconhecíveis por sinais além da cor.
- [x] Textos usam o sistema de traduções GCompris. Recursos reutilizados conservam atribuição, origem e licença registadas.
- [x] O teste de aceitação executa a aplicação Qt real, começa no menu e verifica ações e resultado observáveis. Usa posições CRJM para casos especiais, sem substituir a validação ou forçar o vencedor.
- [x] Guardar os comandos e resultados da validação desta entrega. O build e os testes TypeScript originais não substituem o percurso nativo.

## Comments

Divisão e dependências aprovadas pelo utilizador. Aplicam-se as decisões da especificação principal.

## Answer

Implementada a atividade nativa Quelhas para duas pessoas, com tabuleiro 10×10,
segmentos corrigíveis de comprimento mínimo dois, troca inicial que consome o
turno, orientações por identidade e final misère. Ajuda PT-PT, reinício, menu,
rato, toque sintético e teclado completos. Implementação e ícone independentes,
sem copiar componentes CRJM.

Validação pelo menu da aplicação Qt real, offline e renderização por software:
2 passes, zero falhas e zero erros QML. O percurso verifica a sequência CRJM
de nove segmentos, em que o participante 2 ganha apesar de restarem jogadas
verticais, e a troca preservando pedras e identidades. Red antes da descoberta
e red específico de navegação Tab, seguido de green após corrigir os botões.
Capturas desktop 1100×700 e retrato 600×900 inspecionadas.

Comandos, hashes, logs, capturas, fontes e limites em
[08-quelhas](../evidence/08-quelhas/README.md). Toque físico e revisão com
crianças não realizados. Tux e aprendizagem guiada pertencem ao ticket 09.
