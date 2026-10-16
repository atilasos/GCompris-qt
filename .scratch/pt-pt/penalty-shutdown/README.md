# Investigação aberta do encerramento — tarefa 83

**Causa não demonstrada. A tarefa continua aberta.** Foram executados seis
ensaios curtos, finitos e isolados; todos encerraram com 0 e nenhum reproduziu
SIGSEGV. Não houve correção de produção nem mudança dos relógios dos jogos.
Os resultados funcionais da tarefa 81 continuam separados desta pendência de
estabilidade, que não aprova Windows nem aceitação global.

## O que é provado e o que é temporal

`history/` é uma seleção física de 64 ficheiros do commit imutável da prova81
`a1226d4de3b620f47253cacd226c756a30cf2b3a`: recibo original, três repetições,
casos, logs, retornos, recursos efetivos, cápsulas e índices. Os bytes não foram
reescritos. A seleção não é apresentada como cópia integral dos 15 recibos da 81.

| Instante UTC | Observação |
| --- | --- |
| 03:48:24.924904 | Metadados do launcher criados antes de executar o processo original. |
| 03:48:35.665 | Primeiro input correto registado pelo caso original. |
| 03:49:17 | Kernel regista falta de memória global e mata qemu-system-x86 PID 2125346, não o GCompris. |
| 03:49:54.096 | Último segundo clique registado no nível 9. |
| 03:49:57 | Journal regista SIGSEGV de gcompris-qt PID 4137796, em QtQml 6.10.2. |
| após encerramento | Recibo original: nove níveis, asserções 0, processo 139, supervisor 1, ferramenta 1. |

Os recibos originais não guardaram o PID. A associação do evento do journal ao
caso é **temporal**, não um vínculo PID/binário demonstrado. A resolução local
do endereço aponta para `QV4::MemoryManager::collectFromJSStack+0x6d`; isso não
prova causa no Qt, no motor ou no áudio. Não existe core. Apport recusou-o com a
mensagem de mtime do executável; essa mensagem, sem trace de escritas ou inode
histórico, não demonstra reescrita do binário. O contexto de OOM também não prova
causalidade: o processo morto foi outro, cerca de40 segundos antes.

As três repetições completas anteriores foram preservadas e não repetidas nesta
tarefa: uma normal e duas sob gdb, todas com retorno 0. A namespace PID dessas
duas sessões gdb antigas não estava alinhada com `/proc`; nenhuma stack antiga
é usada como prova. O código 139 original continua falhado no auditor.

## Recursos e comparação com a tarefa 23

A tarefa 23 induziu uma reescrita de RCC mapeado e capturou uma stack em
QResource/qsTr. A seleção `prior23/` conserva o log e o trace O_TRUNC; esse
mecanismo não foi repetido nem presumido aqui.

Os registos da 81 indicam quatro deployments UUID distintos, um caso e um
binário iguais. O helper preservado copiava o executável, compilava RCC/QM
privados e verificava o snapshot antes/depois. As cápsulas e RCC arquivados
concordam com os hashes dos recibos. São evidência de isolamento e endpoints
iguais, não um trace que exclua toda a possível escrita transitória do host.

Quando a 83 tentou observar inodes, a antiga árvore 81 já tinha sido removida.
`chronology-final.json` marca todos os ficheiros de runtime históricos como
indisponíveis, e `verified_no_shared_main_inode` é null. Ausência de ficheiros
não foi convertida numa prova de independência. A primeira observação também é
preservada, com as disponibilidades explícitas, em `chronology.json`.

O snapshot novo é uma cópia física selada de 269 ficheiros; foi preparado antes
de qualquer Qt e não depende do build principal. O binário mantém SHA 3a226ee7…,
mas 26 ficheiros diferem do manifesto antigo, listados integralmente em
`snapshot-comparison.json`. O ensaio não é uma reconstrução integral do ambiente
antigo. Cada variante sobrepõe apenas o RCC de penálti e o catálogo PT da fase
congelada. Não houve sobreposição de escritas: fontes preparadas antes das
execuções sequenciais, deployment/perfil/RCC únicos, snapshot montado read-only
e manifestos verificados antes/depois. Nenhum RCC mapeado foi reescrito.

## Hipóteses e ensaio finito autorizado

1. Se a retenção/serialização de muitos objetos no encerramento expõe a falha,
   variantes com o payload histórico poderão falhar onde a simples não falha.
2. O ciclo de vida após animações/jogo poderá ser necessário; os ensaios ociosos
   não o reproduzem e não o excluem.
3. Pressão de memória externa poderá ter contribuído; não se induziu OOM nem se
   recriou esse ambiente.
4. Reescrita de recursos como na 23 precisaria de prova própria; não se inferiu
   a sua ocorrência nem se tentou provocá-la.

O coordenador autorizou exatamente seis ensaios e indicou parar se todos fossem
0. A matriz usa fontes baseline 597c05f0b e final 1729d456c, com três modos:

- `bare`: primeiro ecrã real, sem fazer parse do payload nem o emitir no log.
- `retained`: o mesmo ecrã, mantendo nove registos históricos em objetos JS;
  o marcador final permanece pequeno.
- `logged`: igual a retained, emitindo também o JSON histórico no encerramento.

A string histórica está presente nos três casos. Os registos são dados de
fixture antigos; `primary_levels` é sempre 0. Não são nove partidas novas.
Nenhum estado/resposta/temporizador do jogo é escrito. O mesmo caso de cada modo
é usado nas duas fases. São seis arranques ociosos, sem a sequência de cerca de
90 segundos de alocações/animações do original. Todos terem 0 não elimina nenhuma
das hipóteses acima nem estabelece taxa de reprodução ou ausência da falha.

## PID, retornos e ferramenta reproduzível

```sh
python3 tests/penalty_shutdown/run.py \
  --snapshot build/penalty-shutdown/snapshot \
  --output CAMINHO_NOVO
python3 tests/penalty_shutdown/audit.py
python3 -O tests/penalty_shutdown/audit.py
python3 -m unittest discover -s tests/penalty_shutdown -p 'test_*.py'
```

O primeiro comando executa apenas os seis casos, sequenciais, e pára perante
SIGSEGV ou falha de preparação/identidade. Exige saída nova. Prepara fontes
atomicamente antes de Qt. Usa uma variante **privada** do launcher, com delta
explícito para antepor gdb e `--pid=host`; o framework partilhado não foi editado.
O gdb observa em `main` o PID, cmdline real em `/proc`, hash do binário,
PPID e namespace; todos os seis vínculos concordam. O evento `exited` regista
separadamente o retorno do inferior. Em SIGSEGV, o script tenta guardar stacks,
registos e mappings antes de parar a matriz; esse ramo não foi exercido aqui.
Os avisos de ASLR e `/proc/*/mem` read-only estão nos logs; não se afirma possuir
uma stack nova ou um core.

`result.json` guarda o retorno do wrapper gdb e as asserções. O auditor exige
**também** `inferior-status.json`, supervisor pós-wait, retorno pós-wait do
executor e observação externa real da matriz. Wrapper 0 não basta para inferior 0.
As ferramentas, casos, observer, fontes, RCC/QM efetivos e retornos estão
preservados fisicamente. O auditor verifica o arquivo numa cópia isolada, sem
consultar Git, processos antigos ou Qt, e mantém as verificações sob `-O`.

## Conclusão e próximo passo

O arquivo é válido; a causa continua desconhecida e a 83 permanece aberta. Não
foram ampliados os seis ensaios, induzida pressão de memória ou acrescentadas
guardas que ocultem o crash. Se reaparecer naturalmente, o próximo passo é uma
stack com PID/cmdline/namespace comprovados e teste de uma variável orientado
por essa stack. Não é justificada uma alteração de produção só pelo símbolo ou
pelos seis encerramentos 0. Outras validações funcionais podem continuar, sem
converter esta investigação em aceitação global de estabilidade.
