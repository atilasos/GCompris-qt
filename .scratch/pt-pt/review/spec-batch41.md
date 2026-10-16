# Spec — tarefa 41

Base: `eed41afb5`. Tip: `abf289dd6c3041e6de10ee46708bef81be6b57e5`.
Âmbito: baby_wordprocessor, duas traduções PO, testes, provas e ticket 41.
Exclui a tarefa 34, da minha autoria. Não alterei código nem executei campanhas.

Sem achados acionáveis no âmbito especificado.

Conferi os SHA-256 dos quatro resultados positivos do índice e dos casos
atuais correspondentes. Todos passam com código zero, sem timeout ou erros
QML. Confirmei também que typing, typing-diagnostic, creation, space-red e
labels-red conservam resultados negativos e não pertencem ao índice positivo.

O caso mínimo regista o mesmo sinal original de Espaço antes/depois: texto
«a»/comprimento 1 no vermelho, «a »/comprimento 2 no verde. A alteração escapa
&, < e > antes de inserir o conteúdo num span pre-wrap. Mantém U+0020 e os
caminhos existentes de retrocesso/quebra de linha, sem substituir o documento.
Os casos finais verificam espaços consecutivos, dez dígitos, 52 letras visuais
com Shift, entrada física/IME portuguesa com ambas as preferências e os três
formatos preservando o texto. As duas traduções tornam botão e ajuda coerentes
com «Subtítulo», com vermelho/verde próprio.

Guardar/carregar usa os botões e o armazenamento originais: nome acentuado,
confirmação, reinício real, seleção do ficheiro e igualdade exata de texto/HTML
após carregar. Verifica ainda entrada após fechar o diálogo sem atribuir foco.
A primeira tentativa que clicava durante a animação está corretamente limitada
a diagnóstico; o caso final aguarda a animação sem alterar o produto.

O caso de controlos grava áudio desligado/ligado/desligado pela interface,
confere persistência e ajuda/foco/menu. Quando ligado, a rota PT de ç e o
MediaPlayer original apresentam PlayingState, posição positiva, duração e
hasAudio, seguidos de done. A observação de ç não é apresentada como audição
das 26 letras. Windows, altifalantes, dispositivos físicos, orientação vertical
e aceitação docente global permanecem explicitamente pendentes.

O ticket resolved corresponde à exploração livre delimitada, sem inventar
níveis ou pontuação e sem aprovar a totalidade da aplicação.
