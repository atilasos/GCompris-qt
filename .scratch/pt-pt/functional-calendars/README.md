# Calendários em português de Portugal

As campanhas finais concluíram 70 perguntas dos 12 níveis: 44 perguntas em
sete níveis de calendar e 26 perguntas em cinco níveis de find_the_day.
Houve 12 escolhas erradas rejeitadas, 12 Bonus e transições naturais.

O oráculo interpreta o enunciado original com calendário gregoriano Python,
calcula datas, meses e dias da semana e verifica separadamente os dados
publicados. No Qt, a pergunta PT desenhada identifica esse resultado próprio.
Os testes escolhem pela data e destaque visíveis, cabeçalho do mês/ano e
nomes portugueses dos dias. Não leem correctAnswer, dataset, modelos ou
funções do motor para obter respostas e não alteram progresso ou relógios.

Três defeitos de interface e uma correção de ortografia têm casos nativos
idênticos antes e depois:

- O mês/ano ficava oculto quando a navegação estava bloqueada. Agora o título
  permanece visível e os botões continuam bloqueados.
- Avançar a partir de 31 de janeiro saltava fevereiro. A mudança de mês passa
  pelo dia 1 e ajusta a seleção ao último dia válido. O caso cobre ambos os
  sentidos e o destaque do dia 28.
- End em 30 de janeiro selecionava fevereiro. Agora seleciona 31 de janeiro.
- Foram corrigidas maiúsculas a meio de 47 instruções. A lista before/after
  está em orthography-changes.json para revisão docente. O vermelho registou
  explicitamente «Descobre um mês que começa num Sábado»; o verde concluiu
  as cinco perguntas do nível 5. Nesse par só mudou o catálogo.

Dois casos de controlos verificam setas, Home/End, PageUp/PageDown, limites,
navegação anterior/seguinte, reinício após progresso, respostas de dias da
semana por Return, Espaço e Enter, ajuda PT/Escape, nova tecla após ajuda e
menu. Não existe seletor de datasets nestas duas atividades.

Dois inventários copiaram 26 recursos QRC e carregaram os SVG com Image.Ready.
As quatro cópias WAV descodificaram para GStreamer fakesink, sem reprodução
física ou audição. Não foram alteradas gravações.

São 14 recibos selecionados: seis casos principais e quatro pares de regressão.
Os dez positivos terminaram com 0 no Qt e no lançador. Os quatro negativos
esperados têm uma asserção falhada, processo Qt normal com 0 e lançador com 1.
As fontes finais de jogo e controlos estão fixadas em 64d35aaef; os inventários
foram recolhidos em 02c4675f6, antes da correção de End, que só altera o QML
instrumentado, excluído das cópias QRC. Os restantes recursos são byte a byte
iguais. As fases históricas do título e catálogo estão em bde22db2e e db2f86383.
O snapshot privado tem 269 ficheiros; Docker está sem rede e usa perfis novos.

As campanhas antes da correção de End, com 70 perguntas e os seus controlos,
foram preservadas em before-month-end-*. Os 24 ficheiros originais foram
conferidos byte a byte contra Git e não se somam à campanha final. Os primeiros
ensaios fixture-weekdays-* pararam porque esperavam «segunda-feira», enquanto
a etiqueta exposta é «Segunda». O fixture passou a aceitar a abreviatura
correta, sem alterar produção. As provas orthography-green anteriores também
ficam fora das contagens principais.

O auditor confere listas exatas e SHA de fontes, catálogo por fase, lançador,
casos, snapshot efetivo, capturas, bytes QRC e todas as perguntas gregorianas.
Usa revisões Git imutáveis e não depende do catálogo corrente ou de caminhos
de worktrees antigas. Onze testes puros incluem cópia independente e rejeição
de adulteração de pergunta, fonte/catálogo, caso, recurso e inventário.

```sh
python3 tests/functional_calendars/audit.py
python3 -m unittest discover -s tests/functional_calendars -p 'test_*.py'
```

A revisão independente final é registada separadamente. Continuam pendentes
aceitação global Linux, Windows 10 da escola, dispositivos físicos, touch,
audição e revisão docente. As provas Linux não aprovam esses critérios.
