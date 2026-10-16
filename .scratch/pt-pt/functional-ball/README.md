# Coordenação com bola — lote 81 para revisão

Foram concluídas **27 rotas de nível, correspondentes a 18 níveis únicos**:
apanha-bola por setas (nove), apanha-bola pelas mãos clicáveis (os mesmos nove)
e grande penalidade (nove). Cada rota tem uma tentativa errada, recuperação e
sucesso com Bonus natural. Nenhum relógio, velocidade, estado ou progresso do
jogo foi alterado para obter estes resultados.

**Há uma ocorrência histórica de encerramento Qt139 ainda sem causa
reproduzida.** `penalty-complete` conserva nove níveis e asserções 0, mas
processo139, supervisor1 e ferramenta1. Não é uma campanha verde nem foi
reescrita. A campanha primária de penálti é `penalty-replay`: o mesmo caso,
executado de novo em deployment novo, terminou processo0/supervisor0/ferramenta0.
Duas repetições completas sob gdb também encerraram normalmente; são diagnóstico,
não recibos de aceitação nativa. A estabilidade desse encerramento será tratada
separadamente pelo coordenador antes de qualquer aceitação global.

## Verificação física

```sh
python3 tests/functional_ball/audit.py
python3 -O tests/functional_ball/audit.py
python3 -m unittest discover -s tests/functional_ball -p 'test_*.py'
```

O auditor lê apenas o arquivo físico, valida a âncora literal de `index.json`,
as cinco cápsulas históricas, todos os recursos efetivos, casos, screenshots,
catálogos e três camadas de resultados. Funciona sobre cópia isolada onde o
caminho original não existe, sem consultar Git ou executar Qt. Alterações de
caso, recibo, RCC, fonte, manifesto e índice são rejeitadas, incluindo uma
falsificação que volta a selar PO, cápsula, recibos e retornos. Cobertura vazia
é rejeitada mesmo sem depender da âncora. As verificações mantêm-se sob `-O`.

Os 15 recibos selecionados incluem três campanhas primárias, dois controlos,
cinco vermelhos e os seus verdes (o verde de navegação é também o controlo de
penálti), e o diagnóstico139. Os retornos externos em `tool-status.json` são
transcrições de respostas `write_stdin` efetivamente observadas, com sessão,
chunk e hashes do recibo e do supervisor. Quatro transcrições em falta no
handoff foram fornecidas explicitamente pelo coordenador; a proveniência é
identificada. Não se inferiu ferramenta0 a partir de Qt0. O supervisor comum
regista o retorno do launcher depois de esperar pelo processo. O novo
`capture.py` automatiza essa camada para campanhas futuras; as transcrições
históricas não foram substituídas por campos inventados.

## Âmbito observado

A decisão usa a bola, mãos/Tux, alvo, instruções, cores e larguras das barras e
feedback desenhados. O auditor geométrico confirma a trajetória retilínea do
sucesso no apanha-bola e o desvio lateral da falha. Os timestamps documentam
inputs reais; não foram lidos limiares ou estados internos para escolher o
momento. No penálti, o segundo clique ocorre enquanto a barra desenhada está
verde; uma tentativa com só um clique esgota-a até vermelho. Verificam-se a
trajetória até à região escolhida, o Bonus e o clique real na bola para a repor.

Os três alvos e os três botões de rato são distribuídos pelos nove níveis do
penálti. Isto cobre as nove combinações alvo/botão, uma por nível, e não as 81
combinações de nível/alvo/botão. As alternativas de setas/mãos do apanha-bola
foram ambas concluídas nos nove níveis; toque físico simultâneo continua por
testar. Não há datasets, edição ou configuração nestas atividades.

Os dois casos de controlos verificam ajuda portuguesa, Escape, foco por inputs
reais depois da ajuda, navegação e extremos, reinício de uma tentativa parcial,
Ctrl+W e menu. Não há botão de recarregar: o reinício apresentado é a mudança
de nível. As teclas não suportadas no penálti deixam bola e instrução intactas.

## Cinco correções com pares idênticos

- `contract-red`/`contract-green`: número público de níveis do apanha-bola,
  de 0 para 9, alinhado com os nove níveis realmente apresentados.
- `help-red`/`help-green`: objetivo PT de sincronização e instrução para tocar
  nas duas mãos desenhadas, em vez de exigir literalmente duas mãos físicas.
- `penalty-contract-red`/`penalty-contract-green`: total público do penálti,
  de 0 para 9.
- `penalty-help-red`/`penalty-help-green`: o clique deve ser numa região da
  baliza; a ajuda explica o atraso e o clique na bola para recuperar.
- `penalty-controls-red`/`penalty-controls-green`: depois do primeiro clique,
  mudar de nível deixava correr a barra anterior, que ficava vermelha no nível
  seguinte. `resetProgressBars` pára agora as três animações antes de limpar as
  barras. O verde verifica barras invisíveis com largura 0 e conclui os controlos.

As quatro primeiras correções são autoria do coordenador; a última foi
reproduzida e implementada por data_04. Não é atribuída à ocorrência139.

## Recursos e limitações

O snapshot é físico, com 269 ficheiros selados. Cada execução usa perfil,
deployment e RCC próprios; fontes congeladas são publicadas atomicamente antes
das campanhas. O auditor compara os recursos efetivos com os bytes históricos,
incluindo a instrumentação exata do caso, sem abrir caminhos absolutos antigos.
Não houve reescrita do snapshot enquanto os processos o usavam.

As cinco fases (`baseline`, `published`, `catch-help`, `penalty-help`, `reset`)
conservam QML/JS, core, PO e ferramentas em cápsulas físicas. `effective/`
guarda os RCC reais e os seus ficheiros extraídos. `catalogue/` guarda os QM
usados. Os sons importados do core e do apanha-bola foram extraídos e seis WAV
descodificados por GStreamer com retorno observado; isto não prova audição.

`diagnostics/` conserva os dois ensaios gdb, ferramenta usada, journal do
kernel, log apport, símbolo e disassembly locais. O SIGSEGV no intervalo do
encerramento aponta para `QV4::MemoryManager::collectFromJSStack`, mas não existe
core nem stack completa e a associação ao caso é temporal. Não se presume
causa igual a episódios anteriores de RCC reescrito enquanto mapeado.
Os pilotos e o primeiro controlo incompleto ficam como diagnóstico histórico,
fora da composição das 27 rotas. Os seus bytes brutos foram preservados.

Windows 10, dispositivos físicos, toque real, audição, revisão docente,
estabilidade do encerramento histórico e aceitação global continuam pendentes.
Este lote é entregue para revisão independente, não declara os 203 jogos aceites.
