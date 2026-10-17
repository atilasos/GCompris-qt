// SPDX-License-Identifier: GPL-3.0-or-later
import core 1.0
ActivityInfo {
    name: "y/Y.qml"
    difficulty: 5
    icon: "y/y.svg"
    author: "GCompris fork contributors"
    title: qsTr("Y")
    description: qsTr("Liga os três lados com um único grupo de peças.")
    goal: qsTr("Desenvolver raciocínio espacial e estratégias de conexão.")
    prerequisite: qsTr("Seguir ligações entre intersecções.")
    manual: qsTr("Duas pessoas jogam alternadamente nas intersecções vazias. O participante 1 começa com Azul ● e o participante 2 com Vermelho ◆. Ganha quem formar um único grupo da sua cor ligado aos três lados. Os lados estão marcados por S, E e D. Os cantos pertencem a dois lados. Três grupos separados não bastam. Só as linhas desenhadas definem as ligações; a proximidade entre intersecções não cria uma ligação.") + "<br><br>" + qsTr("Depois da primeira peça, o participante 2 pode trocar as cores em vez de colocar uma peça. A peça fica no mesmo lugar. O participante 1 passa a Vermelho e joga a seguir; o participante 2 passa a Azul. A troca consome o turno. Se o participante 2 colocar uma peça, a opção termina.") + "<br><br>" + qsTr("Clica ou toca numa intersecção para colocar uma peça. Usa as setas para percorrer todas as intersecções e Espaço ou Enter para jogar. Tab permite chegar aos botões. Desliza o tabuleiro quando as margens não estão visíveis; Ampliar aumenta a separação. A ajuda conserva a posição. Nova partida repõe as cores e o tabuleiro vazio. As linhas realçadas mostram o grupo da última peça e, no fim, o grupo vencedor.")
    credit: qsTr("Regras e referência factual do tabuleiro Y verificadas na plataforma CRJM, de atilasos, e no desenho Tabuleiro_Y_regras-2. Implementação nativa original. Proveniência e limites de licença registados com a atividade.")
    section: "strategy"
    createdInVersion: 270000
}
