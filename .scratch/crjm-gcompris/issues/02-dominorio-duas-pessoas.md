# 02: Dominório para duas pessoas

Status: ready-for-agent
Type: task
Progress: resolved
Blocked by: None (can start immediately)
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno abre Dominório pelo menu e joga uma partida completa com outra pessoa no mesmo dispositivo, com tabuleiro 8×8, colocação de dominós, turnos, vitória, ajuda PT-PT e reinício.

## Acceptance criteria

- [x] Cada dominó ocupa duas casas vazias adjacentes na orientação do participante. A seleção mostra as duas casas antes da colocação.
- [x] Vence quem deixa o participante seguinte sem jogada válida. O resultado identifica o vencedor e explica o bloqueio.
- [x] O teste nativo cobre uma colocação válida, uma tentativa inválida, alternância e um final de referência CRJM.
- [x] O percurso do menu à partida estabelece o precedente de teste nativo para as entregas seguintes.
- [x] A atividade funciona sem rede e não exige contas, serviços CRJM, GPU ou runtime de browser.
- [x] O aluno consulta ajuda PT-PT sem perder a posição, reinicia com o estado inicial correto e regressa ao menu.
- [x] Rato, toque e teclado permitem executar as ações desta entrega. Participantes e turno são reconhecíveis por sinais além da cor.
- [x] Textos usam o sistema de traduções GCompris. Recursos reutilizados conservam atribuição, origem e licença registadas.
- [x] O teste de aceitação executa a aplicação Qt real, começa no menu e verifica ações e resultado observáveis. Usa posições CRJM para casos especiais, sem substituir a validação ou forçar o vencedor.
- [x] Guardar os comandos e resultados da validação desta entrega. O build e os testes TypeScript originais não substituem o percurso nativo.

## Comments

Divisão e dependências aprovadas pelo utilizador. Aplicam-se as decisões da especificação principal.

## Answer

Atividade nativa Dominório disponível no menu de estratégia, com tabuleiro 8×8,
previsão das duas casas antes de confirmar, orientações fixas por participante,
rejeição de ocupação e de limites, alternância, resultado explicado e reinício.
O tabuleiro e os botões aceitam rato, eventos de toque Qt e teclado, incluindo
regresso ao tabuleiro por Tab. Participantes têm número e símbolo de orientação.
Ajuda PT-PT usa o diálogo e o catálogo do anfitrião; os textos usam qsTr.
Implementação e ícone originais GPL-3.0-or-later, com proveniência das regras
registada sem copiar ou relicenciar código da plataforma CRJM.

Validação nativa por menu: Qt 6.10.2, software offscreen, perfil privado, Docker
sem rede. O caso pesquisa com teclas, abre o cartão da atividade e joga as 32
jogadas de um transcript produzido pelo CRJM b206a7b4. O resultado real é vitória
do participante 2 por bloqueio do participante 1. Cobre ainda previsão, tentativa
ocupada e fora do limite, ajuda sem perder posição, reinício, setas/Espaço/Enter,
Tab/ShiftTab, toque sintético, dimensões 1100×700 e 600×900 e regresso ao menu.
Resultado: 0 falhas, 2 passes de QtTest, zero erros QML. O red anterior falhou
porque a atividade ainda não existia no menu. Evidência em
`../evidence/02-dominorio/{red,green}` com logs, manifestos e capturas.

Comando reproduzível a partir da raiz, usando uma pasta de saída nova:

```sh
python3 tools/run-native-qml-case.py \
  --binary /home/proteu/Projetos/GCompris-qt/build/pt-pt/bin/gcompris-qt \
  --activity menu --from-menu --extra-activity dominorio \
  --qml-file src/activities/menu/Menu.qml \
  --case tests/crjm/dominorio.qml \
  --output /tmp/dominorio-native-acceptance --offline
```

O runner recompila os RCC numa cópia privada; não modifica o build partilhado.
Não houve distribuição, teste de som, teste com crianças nem teste físico de
hardware tátil. IA e aprendizagem guiada pertencem ao ticket 03.
