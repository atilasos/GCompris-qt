# Palavras em queda: verificação nativa PT-PT

Aceitação global: **pending**. Quatro casos nativos delimitados passaram em Linux,
com aplicação 26.2/Qt 6.10.2, perfil novo PT-PT e Docker sem rede. Não se trata de
aprovação linguística, Windows, teclado físico ou audição.

## Resultado

- [Jogo completo](final/gameplay/result.json): três níveis de 15 respostas × dois
  modos de caso; **90 palavras completas**, **233 tentativas erradas rejeitadas** e
  812 eventos de caracteres. Prefixos corretos não pontuam; erros a meio
  reiniciam a palavra. As transições Bonus reais concluem e regressam ao nível 1.
- [Configurações](final/configurations/result.json): dez velocidades × dois modos,
  20 palavras completas por cliques reais no teclado virtual; reiniciar elimina
  prefixos parciais. O intervalo de lançamento diminui ao aumentar a velocidade.
- [Palavra perdida](final/missed/result.json): o prefixo de «vila» ficou por
  concluir; a animação original chegou ao fundo, registou a perda sem ponto e
  libertou a escrita. A palavra «amigo» seguinte foi concluída e deu um ponto.
- [Controlos](final/controls/result.json): anterior/próximo, ajuda PT, fecho da
  ajuda e regresso ao menu. Título «Palavras em queda» e manual em português.

Os únicos caracteres especiais presentes no deck PT atual são ç, í e ú. Nos
**dois modos**, os eventos nativos/IME aceitam as grafias corretas e rejeitam
c/i/u nos seus lugares, sem pontuar e reiniciando o prefixo. Foram escritas peça,
dançar, frigorífico e música, e as formas de alvo maiúsculo. Os outros acentos
não existem neste deck; não se afirma que foram exercitados aqui.

## Dados e artefactos reais

O teste Node verifica todas as **147 entradas** dos três níveis (27/39/81), NFC,
grafia permitida, locale pt e 15 respostas por nível. As entradas repetidas são
conservadas como pesos de seleção. Não afirma rever pedagogicamente cada palavra.
A correção «musica» → «música» vem do commit 9b6d0c934 da tarefa19; este trabalho
não alterou produção.

O deck mantém a seleção aleatória. Para garantir as grafias especiais, o caso
reordena só as palavras oficiais ainda não utilizadas, sem acrescentar respostas
ou mudar a pontuação. O resultado lista as 90 palavras efetivamente jogadas;
não se afirma ter escrito todas as 147 entradas.

O [runner](../../../tests/functional_words/run.py) compila um wordsgame.rcc privado
com os dados atuais e o launcher compila também o Gletters herdado com o caso.
A presença de música/MÚSICA no resultado comprova o dado corrigido no artefacto
executado. O build principal é apenas lido. O [resumo](final/summary.json) e o
[índice SHA-256](index.json) identificam dados, RCC, binário, adaptador, casos,
logs e capturas. O self-test IME passou (3 entradas QtTest); o teste Node passou.

Capturas: [teclado virtual](final/configurations/virtual-keyboard.png),
[ajuda](final/controls/help.png), [palavra perdida e recuperação](final/missed/after-missed-recovery.png)
e [nível 3](final/gameplay/mixed-level-3.png).

## Repetir e limites

Seguir [o procedimento dos testes](../../../tests/functional_words/README.md).
Os modos/velocidades são fixtures pelo ciclo normal stop/start; não se afirma
cobrir os gestos de todas as opções no diálogo de configuração. A perda aguarda
a animação real, sem alterar posição, temporizador ou função de jogo.

Os testes não chamam processKeyPress/checkMatch para submeter respostas, nem
atribuem pontuação. Usam TextInput e QInputMethodEvent reais ou cliques nas
teclas virtuais originais. Isto não emula teclado físico português/teclas mortas.
As aplicações arrancam sem som e o ambiente headless não tem dispositivo sonoro.
Pronúncia, audição, revisão docente, legibilidade num computador físico,
instalação offline e execução Windows 10 x64/escola continuam pendentes.
