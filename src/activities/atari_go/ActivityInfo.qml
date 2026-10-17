// SPDX-License-Identifier: GPL-3.0-or-later
import core 1.0
ActivityInfo {
    name: "atari_go/AtariGo.qml"
    difficulty: 4
    icon: "atari_go/atari_go.svg"
    author: "GCompris fork contributors"
    title: qsTr("Atari Go")
    description: qsTr("Faz a primeira captura num tabuleiro de Go.")
    goal: qsTr("Reconhecer grupos e liberdades e antecipar capturas.")
    prerequisite: qsTr("Reconhecer a vizinhança horizontal e vertical.")
    manual: qsTr("Duas pessoas jogam nas 9 × 9 interseções. Também podes jogar contra Tux, sem rede. As Pretas ● começam; as Brancas ○ jogam a seguir. Coloca uma pedra numa interseção vazia. As pedras da mesma cor ligadas na horizontal ou vertical formam um grupo. As interseções vazias junto desse grupo são as suas liberdades. Uma liberdade partilhada conta só uma vez; as diagonais não ligam pedras.") + "<br><br>" + qsTr("Quando um grupo adversário perde a última liberdade, todas as suas pedras são capturadas. Vence quem faz a primeira captura. Não se contam territórios. Não podes colocar uma pedra que deixe o teu grupo sem liberdades (suicídio), exceto se a jogada capturar pedras adversárias e abrir uma liberdade.") + "<br><br>" + qsTr("Prime Grupo e liberdades e toca numa pedra: o grupo fica assinalado e as suas liberdades recebem um +. Esta ajuda não coloca pedras nem muda o turno. Prime Voltar a jogar para continuar.") + "<br><br>" + qsTr("Usa o rato ou toca numa interseção. No teclado, percorre o tabuleiro com as setas e prime Espaço ou Enter. Usa Tab para chegar aos botões. A ajuda mantém a posição. Nova partida limpa o tabuleiro e as Pretas recomeçam.") + "<br><br>" + qsTr("Contra Tux: Fácil escolhe ao acaso; Médio procura capturas e liberdades; Difícil também verifica capturas na resposta seguinte, num conjunto limitado de candidatos. Não garante a melhor jogada. Aprender apresenta um exercício didático preparado de captura no canto. Pista dá orientação, uma linha e uma interseção. Após uma partida, Rever decisão permite comparar uma alternativa com uma jogada tua, pelas liberdades e capturas.")
    // The prepared lesson is explicitly didactic, distinct from a full match.
    // Difficulty policies and lesson positions are original to this fork.
    credit: qsTr("Regras de Atari Go da plataforma CRJM, de atilasos. Implementação e textos nativos independentes; sem reutilização de código ou recursos CRJM.")
    section: "strategy"
    createdInVersion: 270000
}
