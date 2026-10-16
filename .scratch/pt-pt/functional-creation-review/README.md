# Suplemento de revisão 89, imagens e ferramentas futuras

Corrige os dois P2 Spec e o P3 Standards da revisão da tarefa 89. Não houve
execução Qt, compilação RCC, extração Qt nova nem campanha adicional. Fontes,
43 recibos, retornos observados e cápsula histórica permanecem byte a byte
intactos. Os casos Polígonos90 entregues separadamente não entram nesta prova.

## P2, PNG físico e reabertura

`python3 tests/functional_creation/review_audit.py` verifica diretamente os
bytes da cápsula, com os mesmos dois valores literais externos:

- capture: `9b8e6aab0aac15a3c9f8bcd73dcaac8b62a0eb7040181f6c874dd51e27ebeb61`;
- ZIP concatenado: `2fe09088b42e0cf41917e430ebf4ac97e19a48f3c5ddf50e04648ef6d6ef9395`.

Os módulos puros PNG/SVG também têm de coincidir com os bytes históricos.
O suplemento descodifica dez PNG dos fluxos usados na prova, confere dimensões
e compara todo o RGB com a área correspondente da cena completa. Todos coincidem
exatamente. São RODAS1/2, CONTROLO/CONTROLO2/FUNDO nas rodas, CRIAÇÃO, artes,
CORES e FOTO/FUNDO no Sketch. Não se contam PNG de diagnósticos como cobertura.

RODAS1/2 têm 623×623 píxeis. Os PNG físicos seguem os dois traços SVG respetivos:
coordenadas e dimensões são iguais, tinta preta com opacidade 0,8 resulta em
RGB dominante 51/51/51 sobre branco. O envelope de três píxeis corresponde a
metade do traço de quatro píxeis mais um píxel de amostragem. A verificação é
bidirecional, incluindo vetores sem tinta ou tinta fora do percurso.

A imagem reaberta é comparada pela área da cena completa, não pelo objeto
`route.reopened` nem pelo recorte QtTest do widget. Os recortes individuais não
são substitutos da cena. A reabertura tem diferenças RGB nas arestas, com máximo
de canal 204 e 87; por isso não se declara igualdade exata após abrir SVG.
A verificação exige correspondência bidirecional de tinta com tolerância espacial
de um píxel na norma L∞, diferença de área inferior a 1% e diferença de cor
dominante até dois valores de canal. Os resultados observados são zero tinta
sem correspondência, áreas 26949→26870 e 43121→42998, cor dominante 51→52.
Estas são tolerâncias de imagem declaradas, sem alinhar, deslocar, ajustar curvas
ou aceitar uma imagem apenas pelo hash. O oráculo geométrico original continua
a verificar as curvas SVG por equação independente.

## P2, desfazer/refazer e cancelamentos

Desfazer remove o último traço, não toda a criação: cada ficheiro contém dois
traços devido à paragem/retoma real. A tinta escura passa de 26835 para 6844
píxeis no primeiro nível e de 42871 para 3457 no segundo. A imagem fica mais
clara e não introduz tinta alheia. Refazer restaura a cena concluída com diferença
máxima de canal 1 e 2. Uma operação sem efeito ou que recupere só o desenho
parcial é rejeitada.

O RGB é exatamente igual antes/depois de três cancelamentos com trabalho
presente: saída nas rodas, saída no Sketch e nova imagem no Sketch.
A comparação usa as cenas `before-partial-exit`/`partial-exit-preserved`,
`pattern-drawing`/`partial-home-preserved` e
`partial-home-preserved`/`new-cancel-preserved`, nos recibos já existentes.
Não se inventa uma tentativa de nova imagem cancelada nas rodas.

`images.json` identifica os recibos e ficheiros exatos e conserva as métricas.
As negativas exercitam PNG branco mesmo com cena guardada coerentemente branca,
reabertura vazia/errada, desfazer/refazer sem efeito e cancelamento com perda de
trabalho. A cópia isolada do suplemento funciona sem Git, Qt ou checkout;
Python `-O` é recusado explicitamente. As negativas coerentes e físicas da
cápsula original continuam nos testes existentes.

## P3, exportador RCC partilhado

`rcc_export.py` concentra a compilação do inspetor e a execução/JSON do exportador,
com fonte C++, executável, RCC e destino explícitos. `run.py`,
`capture_resources.py` e `seal.py` passam a usá-lo em execuções futuras.
Os três testes da fronteira subprocesso usam mocks; não compilam nem executam Qt.
Falhas externas continuam a propagar-se. O helper não gere nem limpa destinos
alheios. Os capturadores e ferramentas históricos dentro da cápsula não mudam.

## Guarda futura da saída

As três ferramentas recusam `args.output.is_symlink()` e destino existente
antes de resolver o caminho ou ler os inputs. Também se recusa ficheiro existente.
A função `seal()` conserva a mesma guarda para chamadas diretas. Os testes
passam caminhos pendentes e inputs inexistentes, exigem erro CLI 2 e provam
que o link, alvo ausente e bytes de saída existentes ficam intactos. Não se
altera nenhum capturador ou saída histórica para adicionar esta guarda.

## Limites e execução

`PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests/functional_creation`
verifica agora 31 testes. Foram observados 28 testes do conjunto completo antes
da última guarda, seguidos dos cinco testes CLI na versão final, dos quais
três são novos. São 31 testes distintos cobertos, sem chamar à execução de
28 uma execução de 31. `index.json` identifica o resultado observado após
espera e os hashes do auditor e relatório suplementares. Os logs red são falhas
da construção do auditor, não novos defeitos do produto.

Para copiar o auditor, bastam `review_audit.py`, `pixels.py`, `curves.py` e a
cápsula original. Passar o caminho copiado com `--capsule`; o auditor não escreve
ficheiros e não consulta as árvores ou deployments históricos. A validação não
cria novas conclusões, níveis ou recibos nativos. Permanecem os limites originais,
incluindo capturador 1 das rodas, diagnósticos 137/250, Windows, dispositivos,
audição, docente, estabilidade 83 e aceitação global pendentes.
