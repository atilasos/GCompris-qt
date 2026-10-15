# Evidência da tarefa 19 — leitura

Plataforma: Ubuntu 26.04 LTS, Linux 7.0.0-38-generic, Qt 6.10.2,
GCompris 26.2.0 (260200), português de Portugal, 15 de outubro de 2026.
Executável Linux da instalação local, copiado para deployments privados; hashes
em cada `result.json`. Rede Docker `none`, perfis novos sem cache anterior.

## Dados e correções reproduzidas

- `data-red.log`: o JavaScript real produzia 14 palavras na sexta pergunta do
  primeiro nível com RNG zero. A condição `i == 0` impedia procurar substituição.
- `level-count-red.log` e `level-count-red-native/`: a leitura carregava três
  níveis mas `ActivityBase.numberOfLevel` ficava em zero. O sistema de sequências
  compara esse valor na conclusão; a atividade passa agora a publicar os três.
- `duplicate-target-red.log`: RNG 0.2 expôs «chuva» repetida numa ronda que devia
  omitir o alvo. Remover uma única ocorrência deixava a outra. Agora todas as
  ocorrências do alvo são removidas e a lista reposta até 15 palavras, mantendo
  as 147 entradas originais (não se deduplicou o vocabulário).
- `music-red.log`: «musica», entre «computador» e «som», foi corrigida para
  «música». O ficheiro partilhado também serve `wordsgame`; não foram alterados
  nomes de ficheiros de voz.
- `data-green.log`: testes com Wordlist.qml, core.js e readingh.js reais,
  nove valores RNG, todos os 147 dados e ambos os resultados, sem substituir
  regras do jogo. A fronteira Qt de ficheiros, temporizadores e objetos é simulada.

## Limite de diagnóstico dos encerramentos iniciais

As primeiras sessões `readingh-full/` e `readingv-full/` terminaram com código 139
após a primeira resposta certa, sem exceção QML e sem marcador final. Não contam
como aprovadas. O caso original está conservado em `original-case.qml`, SHA256
`3e6c8ad57d3a25b78b5725e7cbf7aeb715c874baecaea352ab55067d91cc9008`, igual ao caso
referido nos dois resultados iniciais.

A instrumentação gdb e o caso mínimo com dois acertos não reproduziram o sinal.
Foram repetidos também os casos completos originais, não apenas a versão com
mensagens de diagnóstico. A relação causal com as correções não está demonstrada;
não se atribui o sinal ao produto ou ao teste sem prova, nem se declara uma
correção de SIGSEGV. Os resultados dessas repetições ficam conservados.

Os ensaios intermédios que chegaram às dez velocidades detetaram uma asserção
incorreta do teste: Timer.interval é inteiro, pelo que velocidade 3 expõe 1666 ms,
não 1666.666 ms. A expectativa final usa a parte inteira; não houve alteração de
produção para arredondar o temporizador. As tentativas intermédias não contam
como sessões integralmente aprovadas.

## Resultado final

Ver `verified/` para os quatro casos finais e fingerprints das dependências.
As capturas mostram as duas direções e ajuda/menu em português. O ficheiro
`tests/functional_reading/README.md` descreve a reprodução e as fronteiras.
Windows 10, execução na escola e revisão final do professor permanecem pendentes.

Os quatro casos `verified/*/result.json` passaram, zero falhas/exceções QML:

| Atividade | Acertos | Erros rejeitados | Níveis concluídos | Velocidades | Ajuda/menu |
| --- | ---: | ---: | --- | --- | --- |
| readingh | 30 | 3 | 1,2,3 e volta ao 1 | 1–10 | passou |
| readingv | 30 | 3 | 1,2,3 e volta ao 1 | 1–10 | passou |

Alvos presentes/ausentes por nível: horizontal 5/5, 6/4, 1/9; vertical 3/7, 5/5, 2/8.
As velocidades produziram intervalos 5000, 2500, 1666, 1250, 1000, 833, 714, 625, 555, 500 ms.
Os controlos interromperam uma apresentação em curso com a seta seguinte,
confirmaram timer parado/novo botão Preparado e verificaram a volta entre níveis 1 e 3.
As capturas dos dois modos foram inspecionadas: instrução e alvo em português,
posição das palavras horizontal/vertical e ajuda/menu portugueses.

`original-exact-after-h/` executou o mesmo SHA de caso das primeiras falhas;
`original-after-fixes-v/` executou o mesmo corpo sem o comentário SPDX inicial.
Ambos completaram 30 acertos / 3 erros / 3 níveis sem código 139, depois falharam apenas
a expectativa antiga de Timer.interval na velocidade 3. Não são quatro casos
finais aprovados adicionais, nem prova da causa do sinal inicial.

`initial-source-replay/` repetiu o caso byte-exato com `initial-source.js`
(a versão inicial e apenas a primeira correção i>=0), conjunto PT antigo e perfil
novo. Chegou à nona ronda correta sem código 139 antes do limite deliberado 90 s;
resultado `timeout=true`, sem aprovação de conclusão. `diagnostic-index.json`
conserva os resultados de todas as tentativas, incluindo falhas de fixture,
gdb, caso mínimo e replay; nenhuma falha anterior foi apagada.

A tarefa produz evidência funcional Linux positiva nas sessões finais, mantendo
aberta a incerteza dos dois encerramentos iniciais. Não certifica a ausência de
falhas intermitentes, Windows, escola, som físico ou revisão do professor.
