# Percursos, tarefa56 em curso

Os quatro percursos principais concluíram sete níveis cada, com entradas
reais e28 erros rejeitados. Os controlos finais das quatro variantes também
passaram. A consolidação de recursos/índice continua pendente; esta parcial
não resolve a tarefa nem aprova Windows, hardware ou revisão docente.

O título relativo era idêntico ao absoluto. title-exact-red e
controls-fixed-path_encoding_relative usam exatamente o mesmo caso e provam
«Codificação de caminhos» → «Codificação de caminhos relativos». O vermelho
usa o fonte Git be9df9911 numa worktree separada; o verde muda só a tradução.
Controlos verificam movimento parcial,4 datasets,7→5→7 níveis por UI,
persistência, reinício, ajuda/Escape, nova entrada e menu.

O primeiro controlo esperava49 células após excluir o dataset6×6; o dataset
seguinte é8×8 e tem64. Foi corrigido o fixture, sem mudança de produção.
Os controlos antigos com essa asserção ficam como diagnóstico, fora da prova
positiva. A auditoria estática dos28 dados confere dimensões, símbolos,
origem/bandeira, ausência de bifurcações e ligação de todas as células.

Fontes dos casos em tests/path_visible.qml, path_controls.fragment,
path_prepare.py e path_data.py. Três testes de grafos passaram. Os casos
usam snapshot independente, perfis novos PT-PT e Docker sem rede; não
alteram modelos, progresso ou temporizadores do jogo.
