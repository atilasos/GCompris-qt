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
