// SPDX-License-Identifier: GPL-3.0-or-later
import core 1.0

ActivityInfo {
    name: "faisca/Faisca.qml"
    difficulty: 4
    icon: "faisca/faisca.svg"
    author: "GCompris fork contributors"
    title: qsTr("Faísca")
    description: qsTr("Escolhe setas e bloqueia o outro participante.")
    goal: qsTr("Planear percursos, contar distâncias e gerir reservas.")
    prerequisite: qsTr("Contar até três e reconhecer quatro direções.")
    manual: qsTr("Duas pessoas jogam à vez num tabuleiro de 5 linhas e 6 colunas. Cada participante tem cinco setas de cada distância: 1, 2 e 3. O participante 1 começa e escolhe uma casa vazia. Depois, cada seta é colocada na casa obrigatória indicada pela seta anterior.") + "<br><br>" + qsTr("Escolhe a distância e uma direção ortogonal. O destino tem de estar vazio e dentro do tabuleiro, à distância exata. Podes saltar casas intermédias ocupadas. A seta fica na casa de partida; o destino torna-se a casa obrigatória do adversário. Observa a previsão e confirma. Podes corrigir a seleção antes de confirmar. Vence quem deixa o outro participante sem jogada válida, incluindo quando esgota as distâncias necessárias.") + "<br><br>" + qsTr("Usa rato ou toque para selecionar casas e botões. No teclado, as setas percorrem o tabuleiro, Espaço seleciona a casa, 1, 2 e 3 escolhem a distância e W, D, S, A escolhem cima, direita, baixo e esquerda. Enter confirma. Tab percorre os botões. A ajuda preserva a partida; Nova partida repõe todas as reservas.")
    credit: qsTr("Regras de Faísca da plataforma CRJM, de atilasos. Implementação nativa independente para este fork, sem reutilização de código ou recursos CRJM.")
    section: "strategy"
    createdInVersion: 270000
}
