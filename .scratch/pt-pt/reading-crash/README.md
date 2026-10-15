# Encerramentos durante a validação nativa

A investigação encontrou uma condição insegura na infraestrutura de testes:
o launcher copiava o executável e o RCC ativo, mas ligava os restantes RCC ao
build principal. A aplicação regista também os RCC das atividades inativas.
Uma recompilação podia reescrever um desses ficheiros enquanto estava mapeado.

## Evidência e cronologia

- A primeira leitura começou às 20:52:14 UTC; o build principal reescreveu
  click_on_letter.rcc às 20:52:34.808.
- Os três percursos de memória começaram às 21:09:05–19 UTC e terminaram com
  código139 às 21:09:30–31. O build principal reescreveu memory.rcc,
  readingh.rcc e wordsgame.rcc às 21:09:29–30.
- Em cópia privada, `rcc-real-red/` usa o compilador rcc real sobre o RCC
  inativo de click_on_letter durante a leitura. O trace mostra O_TRUNC e o
  depurador captura SIGSEGV em QResource::fileName, chamado pela resolução
  do contexto de tradução qsTr. O build principal não foi alterado nessa prova.
- `rcc-race-green/` completa três acertos/um erro sem sinal com recursos
  copiados. O resultado do caso passou, mas o comando terminou com código1
  por PermissionError na limpeza do perfil criado como root pelo contentor.
  Não se apresenta esse comando como aprovado; a tarefa25 corrige a propriedade
  dos ficheiros e repete a verificação normal.
- Vinte ensaios curtos de leitura, em fontes iniciais/atuais e com os dois modos,
  passaram sem escrita concorrente. Isto não demonstra ausência de qualquer
  defeito intermitente no produto.

O diagnóstico do depurador também exigiu alinhar os namespaces PID e /proc;
sem isso a stack podia corresponder a outro PID. As stacks da reprodução final
foram capturadas com o alinhamento verificado.

## Correção em curso e limites

A tarefa25 fornece snapshots transitivos dos recursos e plugins locais, com
manifesto SHA-256, sem symlinks para o build mutável. A tarefa21 repetirá os
percursos completos sem depurador sobre essa base. Até essas verificações
terminarem, a tarefa23 permanece claimed. Nenhuma guarda foi acrescentada ao
código dos jogos para disfarçar o encerramento.

Os registos originais permanecem intactos. As primeiras falhas não tinham stack;
a reprodução controlada demonstra o mecanismo e a cronologia é compatível com
a sua ocorrência nesses testes. Não se afirma que todos os possíveis
encerramentos do GCompris têm esta causa.
