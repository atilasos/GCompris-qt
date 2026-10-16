# Ler e usar retas graduadas: prova PT-PT

A matriz final completou574 perguntas,287 por atividade, nos58 níveis dos20
datasets publicados. Dez campanhas nativas terminaram com Qt0 e lançador0,
com58 Bonus e transição natural até29→1. Cada nível inclui um erro deliberado,
feedback, bloqueio de entradas durante o erro e reparação:58 erros rejeitados.
Não se escrevem respostas/progresso internos nem se alteram temporizadores.

A prova é Linux/software. Não certifica Windows, dispositivos físicos, audição,
pronúncia, aprovação docente ou todos os arranjos aleatórios possíveis. Os dados
publicados têm inteiros não negativos até um milhão e décimas entre0 e4;
não se criaram níveis negativos para aumentar artificialmente a cobertura.
O oráculo puro suporta sinais, mas não se transfere esse teste para uma prova
nativa de sinais que o currículo não expõe.

## Valores visíveis e amostra

O caso lê os dois rótulos GCText, conta as marcas realmente desenhadas e mede
as suas posições. Reconhece o cursor pela opacidade pintada e pela posição,
sem ler `solutionGrad`, `answer`, `value_`, `expected` ou os validadores JS.
As marcas têm de ter posições distintas e igualmente espaçadas. Após o Score,
espera-se o desenho real da nova Row; não se força o layout ou os relógios.

O oráculo próprio usa frações inteiras em QML e Fraction/Decimal em Python:
a posição é interpolada entre os rótulos e a graduação pedida é calculada pela
razão inversa. A auditoria volta a verificar as respostas independentemente
do produto. Os rótulos variáveis e a vírgula decimal são lidos da interface.

A leitura alterna teclado e botões do teclado numérico, com vírgula e ponto
físicos convertidos na vírgula apresentada, Delete, Backspace e confirmação.
O uso alterna setas físicas e botões de seta. Cada evento de seta tem de mover
uma marca. Os extremos são rótulos/limites: o currículo só pede marcas
interiores e os botões/teclas não deixam sair da primeira/última marca interior.
Não se afirma que clicar diretamente numa marca seja um controlo exposto.

As574 perguntas não sortearam quatro dos96 pares nível/passo configurados.
`step-gaps-before-tracers.json` identifica-os. Quatro casos adicionais em
`step-tracers/` usaram somente os botões anterior/seguinte para obter uma reta
com o passo pretendido, observado pelos rótulos e espaçamento, e resolveram
uma pergunta real. Houve31,5,24 e22 observações de retas, respetivamente;
não se alterou a lista de exercícios ou o estado aleatório. Estes quatro
exemplos não aumentam a contagem principal574 nem equivalem a níveis completos.
Juntamente com a matriz principal, observam todos os96 pares nível/passo.

## Português corrigido

Os mesmos casos, com o mesmo hash de entrada, foram executados antes/depois
na leitura e no uso. Os dois vermelhos tiveram Qt0/lançador1 por asserção;
os dois verdes tiveram Qt0/lançador0. Foram corrigidas quatro traduções:

- A instrução do número dizia «Descobrir a borboleta cor de ferrugem»;
  passou a «Encontra o número indicado.».
- A ajuda de Delete dizia «Algarismos: escreve a tua resposta»;
  passou a «Delete: limpar a resposta».
- A ajuda das setas dizia «mover a nave»; passou a «mover o cursor».
- O dataset0–20 tinha «0e20» na frase; foi reposto o espaço em «0 e20».

As observações guardam os textos efetivamente mostrados na ajuda, instrução
e seleção, além de screenshots. A única alteração de produção foi no PO.
Não se mudou a política pedagógica nem o motor de geometria/entrada.
Dois casos anteriores de uma tecla/uma seta passaram; a suspeita estática de
duplicação não justificou uma correção de produção.

## Controlos

Dois casos adicionais cobrem ajuda traduzida, Escape, foco após fechar a ajuda,
Delete/Backspace, ignorar separador em níveis inteiros, limites do cursor,
reinício de entrada parcial, nível anterior depois de progresso e seleção
real29→28→29 níveis. Desmarcar e gravar o primeiro dos dez datasets retira
um nível; reabrir o diálogo conserva essa seleção, que é depois restaurada.
Esta prova de persistência é no mesmo processo/perfil, sem afirmar um novo
arranque completo da aplicação. Cada caso resolve ainda uma pergunta extra,
separada das574, e regressa ao menu por Ctrl+W.

Para observar o menu, só se limpa o identificador de arranque direto da CLI
`ActivityInfoTree.startingActivity`. Não se escreve progresso, respostas ou
configuração por atalhos internos. As escolhas e o reinício são ações reais.

## Recursos, identidade e conclusão

Foram exportados pelo Qt33 recursos:28 dos RCC das duas atividades e cinco
externos (fundo SVG e quatro WAV). Os bytes são comparados com as revisões Git
exatas e conservados em `resources/`. O snapshot independente tem269 entradas
físicas, com manifesto conferido antes/depois de cada execução. O Qt reportou
falta de dispositivo de áudio: não se afirma que os sons tenham sido ouvidos.

`phases/baseline` aponta para052399f75; `phases/final` aponta parad1e639c9f,
a correção das quatro traduções. Os manifestos de fonte têm listas exatas e
hashes de QML, JS, dados, catálogo, lançador, supervisor e recursos. O lançador
compila privadamente o catálogo da fase; os outros recursos vêm do snapshot.

Todos os22 casos arquivados passam pelo supervisor atual, que escreve
`launcher-status.json` somente depois de esperar pelo lançador. O estado
externo liga o retorno real ao SHA do recibo, caso e lançador. Há20 retornos0
e dois1 esperados. Os casos finais são18 verdes: dez campanhas, dois controlos,
dois semânticos PT e quatro amostras de passo. Os dois verdes de teclado da
baseline não contam como validação final de perguntas.

O índice de evidência fica fixado numa revisão Git imutável pelo auditor;
fontes e ferramentas também são comparadas com blobs Git das fases. Recalcular
hashes do próprio arquivo não cria uma nova verdade histórica. Caminhos
absolutos dos recibos são metadados, nunca caminhos a reabrir. O teste portátil
copia as provas e os módulos do auditor para um contentor sem rede, monta só
os objetos Git de confiança e confirma que a worktree original está inacessível.

Calibrações descartadas do conjunto aceite identificaram dois problemas do
fixture, sem defeito de produto: amostrar Row antes do polish e usar um contador
sem ID numa Connections com contexto Bound. Os casos finais esperam o desenho
e usam ID explícito. Não se usam essas calibrações como vermelhos de produção.

## Repetição

```bash
python3 -m unittest discover -s tests/functional_graduated -p 'test_*.py' -v
python3 tests/functional_graduated/audit.py --evidence .scratch/pt-pt/functional-graduated --repository .
python3 tools/native_qml_resources.py --binary PREFIXO/bin/gcompris-qt --output SNAPSHOT_NOVO
python3 tests/functional_graduated/campaigns.py --revision d1e639c9f44e3124f37c614a58835bb14c90cc26 --snapshot SNAPSHOT_NOVO --output RESULTADOS_NOVOS --jobs 6
python3 tests/functional_graduated/trace_steps.py --revision d1e639c9f44e3124f37c614a58835bb14c90cc26 --snapshot SNAPSHOT_NOVO --output AMOSTRA_NOVA --activity graduated_line_use --level 20 --step 200
```

As saídas têm de ser novas. Seleções vazias/fora dos limites e saídas existentes
são recusadas. O runner aceita `--kind controls --start-level14` para os casos
de controlo. Todos os runs utilizam `tools/run-native-qml-supervised.py`.
Para conferir provas antigas é preciso o repositório com as revisões Git
referidas; não é preciso conservar nenhuma worktree ou build antigo.
