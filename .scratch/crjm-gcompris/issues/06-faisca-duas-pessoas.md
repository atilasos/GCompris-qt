# 06: Faísca para duas pessoas

Status: ready-for-agent
Type: task
Progress: resolved
Blocked by: 03
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno abre Faísca pelo menu e joga uma partida completa com outra pessoa no mesmo dispositivo, com seleção de distância e direção, previsão do destino, reservas e casa obrigatória.

O ticket 03 conclui o piloto nativo e estabelece o precedente de integração e validação reutilizado nesta entrega. Não depende da implementação dos outros jogos.

## Acceptance criteria

- [x] O tabuleiro tem 5×6 casas. Cada participante começa com cinco peças de cada distância 1, 2 e 3.
- [x] A abertura permite escolher a casa. As jogadas seguintes colocam a peça na casa obrigatória indicada pela seta anterior.
- [x] A direção é ortogonal, a distância é exata e o destino está vazio e dentro do tabuleiro. Casas intermédias ocupadas podem ser saltadas.
- [x] A seleção permite corrigir distância e direção antes de confirmar. Só uma jogada válida consome a reserva e passa o turno.
- [x] Vence quem deixa o adversário sem jogada válida. O teste nativo cobre reservas, salto permitido, destino inválido e final.
- [x] A atividade funciona sem rede e não exige contas, serviços CRJM, GPU ou runtime de browser.
- [x] O aluno consulta ajuda PT-PT sem perder a posição, reinicia com o estado inicial correto e regressa ao menu.
- [x] Rato, toque e teclado permitem executar as ações desta entrega. Participantes e turno são reconhecíveis por sinais além da cor.
- [x] Textos usam o sistema de traduções GCompris. Recursos reutilizados conservam atribuição, origem e licença registadas.
- [x] O teste de aceitação executa a aplicação Qt real, começa no menu e verifica ações e resultado observáveis. Usa posições CRJM para casos especiais, sem substituir a validação ou forçar o vencedor.
- [x] Guardar os comandos e resultados da validação desta entrega. O build e os testes TypeScript originais não substituem o percurso nativo.

## Comments

Divisão e dependências aprovadas pelo utilizador. Aplicam-se as decisões da especificação principal.

## Answer

Atividade Faísca nativa para duas pessoas concluída: menu, tabuleiro 5×6, reservas, seleção corrigível, previsão, confirmação, casa obrigatória, salto e final; ajuda PT-PT, reinício, rato/toque/teclado e sinais além da cor. Código, ícone e textos independentes, origem registada sem relicenciar CRJM.

Aceitação pela aplicação Qt real, offline e a partir do menu: 2 passes, 0 falhas e 0 erros QML. Percurso completo de onze jogadas de referência inclui salto final e reservas esgotadas; rejeita destino fora/ocupado e casa inicial errada. Capturas desktop e retrato inspecionadas. Comandos, hashes, logs e capturas em `../evidence/06-faisca/README.md`. Tux e aprendizagem guiada pertencem ao ticket 07.
