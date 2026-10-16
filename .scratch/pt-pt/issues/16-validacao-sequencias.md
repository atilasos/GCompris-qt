# Jogar as sequências e a escolha múltipla em todos os níveis

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02

## Aceitação

- Exercitar os scripts reais dos três níveis de ordenação cronológica e dos
  três níveis/cinco exercícios de escolha múltipla.
- Submeter respostas certas e erradas, completar níveis, reiniciar, baralhar e
  navegar entre níveis nos dois modos de escolha múltipla.
- Produzir evidência na aplicação QML nativa, além da verificação dos dados.
- Registar os limites, mantendo Windows e aprovação pedagógica separados.

## Relação com a revisão

A revisão da especificação identificou que o teste anterior de cronologia só
inspecionava listas de imagens, sem submeter uma ordem ou concluir um nível.
Esta tarefa cobre essa lacuna concreta; não certifica as restantes atividades.


## Answer

Os casos QtTest jogaram os conjuntos distribuídos na aplicação nativa real,
num perfil novo e com a rede desativada. Escolha múltipla: cinco respostas erradas
e cinco certas, ambos os modos e três níveis concluídos. Cronologia: três
respostas erradas e três certas, três níveis concluídos e 37 arrastos, incluindo
reordenação e regresso à origem. Ambos verificaram reinício, passagem circular e
os botões de navegação. Os testes terminaram sem falhas QtTest ou erros QML.

Foi corrigida a instrução cronológica que pedia «letras», agora «imagens», com
regressão no QTranslator real reproduzida antes e depois. O caso JS adicional
verifica as permutações e a preservação da solução em reinícios com RNG
controlado, usando os scripts reais de Core/ordenação.

Evidência em `../validation/ordering_chronology.md` e
`../validation/multiple_choice_questions.md`; resultados/capturas em
`../functional-sequences/*-final/`. Repetição em
`tests/functional_sequences/README.md`.

Esta resolução é funcional e limitada aos conjuntos distribuídos destes dois
jogos em Linux. Não resolve a tarefa 06 global, áudio, aprovação pedagógica,
Windows ou a validação na escola. A matriz global não foi alterada.
