# Calendários, tarefa 62 em curso

O intérprete gregoriano independente verificou as 70 perguntas dos 12 níveis.
Cinco testes puros verificam datas, semanas, meses, ano bissexto e ordinais.
O título do mês/ano estava oculto com a navegação bloqueada. O caso nativo
idêntico ficou verde ao manter o título visível, sem desbloquear os botões.

Foram corrigidas maiúsculas de meses e dias a meio de 47 instruções PT.
O caso orthography.qml falhou com o catálogo anterior e concluiu as cinco
perguntas do nível 5 com o catálogo corrigido, sem alterar o caso.

month-navigation-red demonstra 31 de janeiro → março ao clicar uma vez para
avançar. A correção deste salto de mês e as campanhas completas ainda estão
pendentes neste checkpoint. As primeiras campanhas pararam no segundo nível:
o fixture esperava «segunda-feira», mas a etiqueta exposta é «Segunda». O
fixture passou a aceitar a forma abreviada correta. Estes ensaios ficam em
fixture-weekdays-* e não contam como campanhas completas positivas.

Nenhuma aprovação global Linux, Windows, hardware, audição ou docente.

## Campanhas e controlos finais

Depois da correção do salto de mês, as duas campanhas completas concluíram
44 perguntas em sete níveis de calendar e 26 perguntas em cinco níveis de
find_the_day. São 70 perguntas, 12 escolhas erradas rejeitadas e 12 Bonus.
As campanhas de fixture anteriores não contam como conclusões finais.

Os controlos das duas atividades passaram: setas, Home/End, PageUp/PageDown,
limites, navegação anterior/seguinte com reinício, respostas de dias da semana
por Return, Espaço e Enter, ajuda PT/Escape, nova tecla após ajuda e menu.
Não existe seletor de datasets nestas duas atividades.

Dois inventários copiaram bytes QRC originais e carregaram SVG com Image.Ready.
As quatro cópias WAV descodificaram em software para fakesink; sem reprodução
física. Os fontes finais são 02c4675f67bf273448cffb643d80008fae308a77.

Três regressões têm casos idênticos antes/depois: título oculto, maiúsculas
nas instruções e salto de mês a partir do dia 31. orthography-diagnostic-red
regista explicitamente a asserção e texto com «Sábado»; o verde conclui as
cinco perguntas. O único input alterado nesse par é o catálogo. A cópia
separada de catálogo antigo foi removida após terminar os dois processos;
o auditor usa o catálogo Git db2f86383 e não depende dessa pasta.

O ponto anterior deste documento descreve o checkpoint histórico; as campanhas
acima já terminaram com 0 no lançador e nos recibos. A auditoria e revisão final
continuam pendentes até à consolidação. Nenhum critério global foi aprovado.
