// SPDX-License-Identifier: GPL-3.0-or-later
import core 1.0
ActivityInfo {
    name: "nex/Nex.qml"
    difficulty: 6
    icon: "nex/nex.svg"
    author: "GCompris fork contributors"
    title: qsTr("Nex")
    description: qsTr("Liga as tuas margens com peças próprias e neutras.")
    goal: qsTr("Planear conexões e transformações num tabuleiro hexagonal.")
    prerequisite: qsTr("Reconhecer adjacências e planear ações compostas.")
    manual: qsTr("Duas pessoas jogam num losango 11×11. Negras ● ligam as margens N e S; Brancas ◇ ligam O e E. As peças neutras têm o símbolo +. Cada participante conserva a sua identidade mesmo quando troca de cor.") + "<br><br>" + qsTr("Colocar: seleciona uma casa vazia para a tua peça e outra para uma neutra. Substituir: seleciona duas neutras para se tornarem tuas e depois uma peça tua para se tornar neutra. Toca novamente numa seleção para a retirar. Limpar cancela a seleção. Só Confirmar executa a ação completa. O participante 2 pode trocar cores e margens após a primeira jogada; a troca consome o seu turno.") + "<br><br>" + qsTr("Vence quem formar uma cadeia contínua entre as suas duas margens. Uma casa tem até seis vizinhas. Quando resta uma vazia sem neutras, o participante seguinte ocupa-a; se resta uma neutra sem vazias, converte-a; se resta uma de cada, ocupa a vazia e a neutra passa ao adversário. Avaliam-se as conexões, primeiro do participante seguinte. A ausência de duas vazias não termina a partida: ainda pode haver substituições.") + "<br><br>" + qsTr("Rato e toque selecionam casas. Usa as setas para percorrer o tabuleiro, Espaço para selecionar e Enter para confirmar. Tab percorre os botões e Espaço ativa-os. Usa Ampliar para alvos maiores e desliza o tabuleiro. A ajuda preserva a posição; Nova partida limpa-a.") + "<br><br>" + qsTr("Contra Tux, tu és o participante 1 e Tux é o participante 2, mesmo após trocar cores. Fácil explora ações legais; Médio encurta a sua rota; Difícil também tenta bloquear a tua. O cálculo é local e não impede sair ou reiniciar. Aprender apresenta três exercícios didáticos de colocação, substituição e conexão. Pista oferece três graus de ajuda e prepara uma seleção que podes corrigir. Após a partida, Rever decisão repõe a tua última decisão real e compara uma alternativa pela rota mais curta; esta experiência não muda o resultado guardado.")
    // Learning exercises are newly authored, separate from standard matches.
    credit: qsTr("Regras de Nex consultadas no CRJM de atilasos. Código e imagens nativos criados independentemente para este fork.")
    section: "strategy"
    createdInVersion: 270000
}
