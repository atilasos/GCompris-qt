// SPDX-License-Identifier: GPL-3.0-or-later
import core 1.0
ActivityInfo {
    name: "dominorio/Dominorio.qml"
    difficulty: 3
    icon: "dominorio/dominorio.svg"
    author: "GCompris fork contributors"
    title: qsTr("Dominório (duas pessoas)")
    description: qsTr("Coloca dominós e bloqueia o outro participante.")
    goal: qsTr("Antecipar jogadas e desenvolver o raciocínio espacial.")
    prerequisite: qsTr("Reconhecer as direções vertical e horizontal.")
    manual: qsTr("Duas pessoas jogam à vez num tabuleiro 8 × 8. O participante 1 coloca dominós verticais (↕) e começa. O participante 2 coloca dominós horizontais (↔). Cada dominó ocupa duas casas vazias vizinhas. Seleciona a casa de cima ou da esquerda, observa a previsão e confirma. Vence quem deixa o outro participante sem uma jogada válida.") + "<br><br>" + qsTr("Usa o rato ou toca numa casa para selecionar. No teclado, usa as setas para percorrer o tabuleiro, Espaço para selecionar e Enter para confirmar. Tab permite chegar aos botões. Podes corrigir a seleção antes de confirmar.")
    credit: qsTr("Regras de Dominório da plataforma CRJM, de atilasos. Implementação nativa independente para este fork; sem reutilização de código ou recursos CRJM.")
    section: "strategy"
    createdInVersion: 270000
}
