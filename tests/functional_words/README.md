# Palavras em queda: testes funcionais PT-PT

```bash
python3 tests/functional_words/run.py \
  --binary /caminho/para/gcompris-qt \
  --output /novo/diretorio
```

Requer aplicação compilada com os recursos locais, Qt6 dev/rcc/qmltestrunner,
Node e a imagem Docker offline já disponível para o launcher nativo. A saída
não pode conter uma execução anterior. `--case gameplay`, `configurations`,
`missed` ou `controls` repete apenas o caso indicado.

O script verifica todas as 147 entradas PT, compila o adaptador IME de teste e
faz o seu self-test. Cria uma cópia privada do binário, reconstrói wordsgame.rcc
com os dados atuais e usa o launcher existente para instrumentar também o
componente herdado Gletters. Isto evita usar dados antigos do build principal.
Cada aplicação tem um perfil novo, PT-PT, rede desativada e recursos locais.
Nenhum teste escreve no build principal.

- `gameplay.qml`: três níveis × dois modos, 15 palavras completas por percurso.
  Digita caracteres pelos eventos Qt reais, incluindo pré-edição/commit IME.
  Verifica prefixos sem ponto, erro após prefixo, rejeição de maiúsculas no modo
  estrito, acento/cedilha omitidos, palavra completa e transição Bonus.
- `configurations.qml`: dez velocidades × dois modos; cliques reais no teclado
  virtual completam palavras e o reinício elimina um prefixo incompleto.
  Confirma que aumentar a velocidade reduz o intervalo de lançamentos.
- `missed.qml`: deixa terminar a animação original de uma palavra parcialmente
  escrita, observa a perda sem ponto e completa outra palavra pelo teclado virtual.
- `controls.qml`: botões anterior/próximo, ajuda em português, fecho e menu.

A escolha aleatória continua ativa. Para garantir os caracteres especiais presentes
nos dados, gameplay reordena apenas o deck oficial ainda não utilizado, colocando
peça/dançar/frigorífico/música no início da próxima seleção. Não altera palavras,
respostas, número de exercícios, pontuação ou verificações do jogo. O resultado
lista todas as palavras efetivamente concluídas. Não se afirma escrever as 147
entradas: estas têm verificação estrutural e as 90 palavras jogadas constam do log.

Modos e velocidade são fixtures aplicadas pelo ciclo normal stop/start, sem
alegar cobertura dos gestos do diálogo de opções. O teclado virtual apresenta
teclas minúsculas também no modo de alvos maiúsculos; o jogo converte essa entrada
como previsto. A escrita por teclado usa o TextInput original e o adaptador IME
existente, sem chamar a validação ou alterar a pontuação.

O relatório identifica os quatro casos, dados, RCC, binário, plugin e hashes.
Isto não aprova teclado físico português/teclas mortas, saída sonora, pronúncia,
Windows, revisão docente nem aceitação global Linux. O caso de perda aguarda a
animação normal, pelo que a execução completa demora cerca de um minuto.
