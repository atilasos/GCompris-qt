// SPDX-License-Identifier: GPL-3.0-or-later
import core 1.0
ActivityInfo {
    name: "gatos_caes/GatosCaes.qml"
    difficulty: 3
    icon: "gatos_caes/gatos_caes.svg"
    author: "GCompris fork contributors"
    title: qsTr("Gatos & Cães")
    description: qsTr("Coloca animais e bloqueia o outro participante.")
    goal: qsTr("Antecipar jogadas e reconhecer relações de vizinhança.")
    prerequisite: qsTr("Reconhecer casas vizinhas na horizontal e na vertical.")
    manual: qsTr("Duas pessoas jogam à vez num tabuleiro 8 × 8. O participante 1 joga com Gatos e começa numa das quatro casas centrais. O primeiro Cão deve jogar fora dessas quatro casas. Nunca podes colocar um animal numa casa ocupada nem ao lado de um animal da outra espécie, na horizontal ou na vertical. Na diagonal, podem ser vizinhos. Animais da mesma espécie podem ficar juntos. Vence quem deixa o outro participante sem uma colocação válida.") + "<br><br>" + qsTr("Clica ou toca numa casa para colocar um animal. No teclado, usa as setas para percorrer o tabuleiro e Espaço ou Enter para colocar. Tab permite chegar aos botões. Mostrar casas permitidas assinala as casas em que podes jogar. A ajuda preserva a partida e Nova partida limpa o tabuleiro. Contra Tux, jogas com Gatos e Tux com Cães. Fácil escolhe ao acaso; Médio compara as casas disponíveis; Difícil examina até doze respostas do jogador para cada hipótese, sem garantir uma jogada perfeita. Aprender apresenta uma introdução e um exercício didático de vizinhança. Pista dá três níveis de apoio. Após a partida, Rever decisão permite comparar outra abertura com a tua primeira colocação.")
    credit: qsTr("Regras de Gatos & Cães da plataforma CRJM, de atilasos. Implementação nativa independente para este fork; sem reutilização de código ou recursos CRJM.")
    section: "strategy"
    createdInVersion: 270000
}
