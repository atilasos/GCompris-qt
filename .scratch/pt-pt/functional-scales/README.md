# Três balanças — tarefa 34

Concluídos os 666 puzzles dos 20 datasets por eventos Qt reais, com perfil novo,
locale pt_PT, recursos privados imutáveis e Docker sem rede. O solver usa os
rótulos dos pesos conhecidos e a inclinação da agulha. Não lê o peso oculto,
a resposta da pergunta ou os alvos do dataset para resolver.

| Atividade | Datasets | Níveis | Puzzles | Arrastos | Erradas rejeitadas |
| --- | ---: | ---: | ---: | ---: | ---: |
| scalesboard | 8 | 52 | 223 | 1365 | 52 |
| scalesboard_weight | 6 | 45 | 222 | 1407 | 45 |
| scalesboard_weight_avoirdupois | 6 | 45 | 221 | 1246 | 45 |
| Total | 20 | 142 | 666 | 4018 | 142 |

Os três casos de controlos passaram ajuda PT, anterior/próximo, reinício por
Gravar após arrasto parcial e regresso ao menu. Três tracers adicionais
completaram os primeiros três níveis de cada atividade com a preferência do
teclado visual desligada: 24 puzzles, 83 arrastos e nove negativas. Essa amostra
não é uma segunda campanha completa dos 666 puzzles. No percurso completo,
a preferência está ligada e alternam-se teclas físicas simuladas e cliques no
teclado visual nas perguntas expostas.

## Pesagens e unidades

O auditor Python com Decimal voltou a calcular as somas assinadas dos rótulos
observados, com 1 kg = 1000 g e 1 lb = 16 oz. Verificou famílias de unidades,
pesos colocados à direita, inclinações das tentativas e a entrada numérica na
unidade portuguesa pedida. Houve 259 presentes ocultos resolvidos pela busca
do equilíbrio e 132 soluções finais com pesos no prato direito. A pontuação,
o Bonus e as transições foram naturais, incluindo o retorno ao primeiro nível.

As capturas de massas mistas mostram, por exemplo, 2 kg + 200 g + 200 g e
entrada de 2400 gramas; e 2 lb + 1 lb + 1 lb com entrada de 64 onças. O caso
imperial enumera os seis pesos efetivamente expostos nos últimos datasets,
sem inventar um sétimo. As capturas e os rótulos observados estão nos recibos.

## Correções comprovadas

- [Título SI](si-help/README.md): «Balança que usam» passa a «Balança que usa».
  Mesmo caso de ajuda Qt falha antes e passa depois.
- [Presente impossível de 5](balance-five/README.md): a quarta massa do nível
  30 passa de 1 para 2, permitindo 1 + 2 + 2. A busca apenas pela inclinação
  reproduziu a impossibilidade anterior; o verde completou os quatro presentes
  por arrastos reais. Uma auditoria separada dos dados, nunca importada pelo
  solver UI, confirmou a alcançabilidade dos 666 alvos. O controlo negativo
  restaura os dados antigos numa cópia temporária e recusa o alvo impossível.

Estas são as únicas alterações de produção da tarefa. As falhas iniciais de
calibração dos arrastos e da suposição de sete pesos pertenciam ao harness;
não motivaram mudanças no jogo.

## Provas e reprodução

[final/summary.json](final/summary.json) relaciona os nove casos positivos,
contagens e hashes. Cada diretório conserva case.qml exato, resultado, log,
capturas e, nos percursos, oracle.json. Os hashes dos casos e capturas foram
conferidos depois da cópia para o arquivo. Os sete testes Python do auditor e
da alcançabilidade passaram, assim como os exemplos Node de unidades e planos.
Os comandos reutilizáveis estão em [tests/functional_scales/README.md](../../../tests/functional_scales/README.md).

O snapshot independente tem 269 ficheiros; o manifesto está em
[final/resource-snapshot.json](final/resource-snapshot.json). O binário tem
SHA-256 3a226ee745c25aa8cf5e77d7cfb438c83dc6956091e6230053598cca659314bb.
A imagem efetiva foi sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b.
Todos os nove resultados verificam UID/GID 1000, propriedade dos ficheiros
privados, saída normal e remoção do deployment. Não se escreveu no build de
origem. Os RCC e catálogos de execução foram reconstruídos privadamente.

## Limites

Não se enumeram todos os subconjuntos possíveis do seletor de datasets. Os
20 datasets completos foram percorridos no perfil novo. A amostra sem teclado
visual tem apenas três níveis por jogo. Não há prova de orientação vertical,
rato/teclado físicos, massas físicas, audição por altifalante, Windows ou
aceitação docente global. Não foram induzidas falhas ou alterados temporizadores,
modelos, respostas, pontuação ou posições para preparar uma solução.
Mapa e CSV global não foram editados nesta tarefa.
