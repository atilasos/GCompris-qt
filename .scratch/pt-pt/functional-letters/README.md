# Letras PT-PT: verificação nativa em Linux

Resultado global de aceitação: **pending**. Os quinze casos nativos delimitados
neste relatório passaram; isto não aprova os restantes jogos, Windows ou a revisão
linguística e pedagógica.

## Cobertura da execução inicial

| Atividade | Níveis/modos concluídos | Respostas certas | Respostas erradas rejeitadas |
| --- | --- | --- | --- |
| gletters | 13 mistos + 13 apenas maiúsculas | 425 | 228 |
| keyboard_training | 13 maiúsculas + 13 minúsculas | 424 | 32 |
| click_on_letter | 11 | 94 | 11 |
| click_on_letter_up | 11 | 94 | 11 |

Total: **74 percursos de nível/modo, 1 037 respostas certas e 282 erradas**.
A contagem de gletters inclui uma resposta adicional na velocidade mínima.
Os outros casos de controlo, velocidade e áudio não entram nesta contagem.
Todos usam a aplicação Qt original, os objetos de jogo reais e eventos de rato,
teclado ou composição IME. As transições e animações do jogo são aguardadas.
Nenhum teste substitui a função que valida a resposta, atribui pontos ou chama
checkAnswer com um índice conhecido.

Os quatro jogos têm também casos de anterior/próximo, ajuda em português,
regresso ao jogo e ao menu; ambas as variantes click têm regressão de navegação;
gletters tem respostas certas/erradas nas dez velocidades; os quatro têm
verificação do percurso de vozes. Os modos são aplicados como fixtures de
configuração pelo ciclo normal de reinício: não se afirma cobrir os gestos de
cada opção no diálogo de configuração.

## Atualização após revisão de cobertura

A afirmação inicial de erros de acentos em gletters era excessiva: o caso inicial
não submetia a forma sem acento. A [revisão nativa](review-accent.md) acrescenta
24 tentativas, doze por modo. O novo caso passou com 425 respostas certas e
252 erradas; o composto por atividade é agora 1 037 certas/306 erradas e 74
percursos. Os restantes catorze casos mantêm a evidência histórica. O índice
inicial e as suas contagens permanecem intactos; o novo índice é
[review-accent-index.json](review-accent-index.json).

## Evidência e reprodução

O [índice JSON](index.json) identifica os quinze resultados aprovados e os hashes
SHA-256/tamanhos dos logs, capturas e resultados. Cada result.json identifica
QML, caso, catálogo PT, QM, RCC e binário. A aplicação executou com perfil novo,
idioma pt_PT e Docker com rede desativada; só as cópias privadas dos recursos
foram alteradas. O build principal serviu apenas para leitura.

- [gletters](run3/gletters/result.json) e [nível com acentos](run3/gletters/falling-false-level-13.png).
- [keyboard_training](run3/keyboard_training/result.json) e [minúsculas com acentos](run3/keyboard_training/keyboard-lowercase-level-13.png).
- [click_on_letter](run4/click_on_letter/result.json).
- [click_on_letter_up](run4/click_on_letter_up/result.json) e [último nível](run4/click_on_letter_up/click-uppercase-level-11.png).
- [Controlos dos quatro jogos](automation-controls/summary.json).
- [Regressão das duas variantes](automation-navigation/summary.json).
- [Dez velocidades](automation-speed/summary.json).
- Percurso de vozes: [gletters](audio1/gletters/result.json),
  [keyboard_training](audio1/keyboard_training/result.json),
  [click_on_letter](audio1/click_on_letter/result.json) e
  [click_on_letter_up](audio1/click_on_letter_up/result.json).

Para repetir, seguir [o README dos testes](../../../tests/functional_letters/README.md).
O adaptador de composição foi compilado isoladamente e passou o self-test com
os 24 caracteres portugueses. Os casos completos também verificam pré-edição
sem pontuação e confirmação pelo TextInput original.

## Erro reproduzido e corrigido

No nível 3 de click_on_letter, onze respostas permitem selecionar a posição 10
com setas. O botão Próximo abre o nível 4, com oito respostas, mas conservava
currentIndex=10. Espaço tentava validar um objeto inexistente, lançava
`Cannot read property 'letter' of undefined` e bloqueava a entrada.

A [execução anterior à correção](navigation-shrink-before/native.log) reproduz o
erro pelo teclado e pelo botão reais. A correção reinicia a seleção e o estado
de navegação quando o modelo de respostas é reconstruído. Os dois casos de
regressão confirmam seleção -1 ao entrar no nível e a primeira tecla Espaço
seleciona a posição zero sem lançar erro nem bloquear a entrada. A conclusão
integral dos níveis de ambas as variantes foi repetida após a correção.

## Limites e aceitação restante

A composição usa eventos QInputMethodEvent reais, pois QtTest keyClick aceita
apenas ASCII e aborta ao receber ã. O teste não emula o mapa físico português,
as teclas mortas do sistema nem um teclado físico. Estes requerem verificação
no computador de destino.

As execuções headless avisam que não existe dispositivo físico de áudio. O sinal
real done comprova o percurso da fila de vozes, não a saída sonora ou pronúncia.
A descodificação dos recursos de voz está documentada separadamente no ticket05.
Audição, legibilidade numa janela normal, interação física, revisão docente,
instalação offline e execução Windows 10 x64/escola continuam pendentes.
