// SPDX-License-Identifier: GPL-3.0-or-later
import core 1.0
ActivityInfo {
    name: "produto/Produto.qml"
    difficulty: 5
    icon: "produto/produto.svg"
    author: "GCompris fork contributors"
    title: qsTr("Produto")
    description: qsTr("Multiplica os teus dois maiores grupos.")
    goal: qsTr("Planear grupos conectados e comparar produtos.")
    prerequisite: qsTr("Reconhecer grupos e multiplicar números.")
    manual: qsTr("Joga contra Tux ou com outra pessoa num tabuleiro hexagonal de 61 casas. O participante 1 é Negras ● e o participante 2 é Brancas ◇. Negras começa colocando uma única peça de qualquer cor. Nos turnos seguintes cada participante coloca duas peças, cada uma de qualquer cor, em casas vazias.") + "<br><br>" + qsTr("Escolhe a cor e depois a casa para cada peça. A seleção é uma previsão: toca novamente numa casa selecionada para a retirar ou usa Limpar. Só Confirmar coloca as peças e passa o turno. As peças adjacentes da mesma cor formam grupos. A pontuação é o produto dos dois maiores grupos de cada cor. Menos de dois grupos dá zero. Unir dois grupos pode diminuir a pontuação!") + "<br><br>" + qsTr("Quando o tabuleiro fica cheio, vence o maior produto. Em caso de igualdade, vence quem tem menos peças da sua cor no tabuleiro. Todas as peças contam para o dono da cor, independentemente de quem as colocou.") + "<br><br>" + qsTr("Rato ou toque selecionam casas e botões. No teclado, as setas percorrem as casas, Espaço seleciona ou retira, 1 escolhe Negras, 2 escolhe Brancas e Enter confirma. Tab percorre os botões, Espaço ativa-os. A ajuda preserva a posição. Nova partida limpa o tabuleiro.") + "<br><br>" + qsTr("Contra Tux: Fácil explora jogadas legais; Médio procura criar os seus grupos; Difícil compara os produtos das duas cores, incluindo peças da tua cor. A pesquisa é curta e local, sem garantir a melhor jogada. Aprender apresenta uma introdução e um exercício didático, separado da partida. Pede até três pistas: a última propõe uma seleção que podes corrigir. Depois da partida, Rever decisão permite comparar outra jogada com a tua última decisão real e mantém o resultado original.")
    // Original local policies and teaching examples, independent of CRJM code.
    credit: qsTr("Regras de Produto publicadas pelo CRJM e Associação Ludus. Implementação nativa independente, sem copiar código ou recursos da plataforma CRJM de atilasos.")
    section: "strategy"
    createdInVersion: 270000
}
