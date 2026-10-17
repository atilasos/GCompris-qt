// SPDX-License-Identifier: GPL-3.0-or-later
import core 1.0
ActivityInfo {
    name: "quelhas/Quelhas.qml"
    difficulty: 4
    icon: "quelhas/quelhas.svg"
    author: "GCompris fork contributors"
    title: qsTr("Quelhas")
    description: qsTr("Coloca segmentos: perde quem faz a última jogada.")
    goal: qsTr("Antecipar jogadas e desenvolver o raciocínio espacial.")
    prerequisite: qsTr("Reconhecer as direções vertical e horizontal.")
    manual: qsTr("Duas pessoas jogam à vez num tabuleiro 10 × 10. O participante 1 começa na vertical ↕ e o participante 2 joga na horizontal ↔. Cada jogada ocupa um segmento de duas ou mais casas vazias consecutivas na direção do participante. Seleciona os dois extremos, observa o segmento completo e confirma. Podes mudar o segundo extremo ou limpar a seleção antes de confirmar. Não podes sobrepor segmentos.") + "<br><br>" + qsTr("Depois da primeira jogada, o participante 2 pode trocar as orientações em vez de colocar um segmento. As pedras ficam no mesmo lugar. A troca consome o turno: joga a seguir o participante 1, agora na horizontal. Se o participante 2 colocar um segmento, deixa de poder trocar.") + "<br><br>" + qsTr("Perde quem faz a última jogada. Quando chega a vez de um participante que já não pode colocar um segmento na sua orientação, esse participante ganha, mesmo que ainda existam jogadas na outra orientação.") + "<br><br>" + qsTr("Usa o rato ou toca nas casas para selecionar os extremos. No teclado, usa as setas para percorrer o tabuleiro, Espaço para selecionar, Enter para confirmar e Escape para limpar a seleção. Tab permite chegar aos botões. A ajuda mantém a partida; Nova partida repõe o tabuleiro e as orientações iniciais.")
    credit: qsTr("Regras de Quelhas da plataforma CRJM, de atilasos. Implementação nativa independente para este fork; sem reutilização de código ou recursos CRJM.")
    section: "strategy"
    createdInVersion: 270000
}
