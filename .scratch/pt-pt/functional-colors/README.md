# Cores e misturas, tarefa 53

A prova principal completa 254 puzzles em 35 níveis de execução. Os casos
operam o Qt original, PT-PT, perfis novos e Docker sem rede. Não chamam
validadores internos nem escrevem respostas/progresso. O índice explicita a
composição de provas; diagnósticos e vermelhos ficam fora da aprovação.

| Atividade | Níveis | Puzzles | Representação |
|---|---:|---:|---|
| colors | 3 | 22 | 11 cores de patos |
| advanced_colors | 20 | 160 | 70 cores de borboletas |
| color_mix | 6 | 36 | pigmentos CMY |
| color_mix_light | 6 | 36 | luz RGB |

Cada nível de mistura tem seis alvos aleatórios. Não se afirma esgotar todas
as cores, disposições ou combinações quantizadas possíveis. Os quatro jogos
não expõem seleção de datasets/configuração local; os quatro controlos
confirmam a ausência de botão, os totais, reinício de tentativa parcial por
navegação, ajuda PT, entrada depois da ajuda e menu Home/Escape.

## Escolha e entrada

Nos nomes, o pedido é lido do painel efetivamente visível. Um vocabulário PT
explícito e separado escolhe a identidade do SVG entre os itens renderizados,
que têm Image.Ready. Não lê question do delegado nem a pergunta atual do JS
para escolher. Cada pedido recebe uma imagem errada, cruz visível, pontuação
inalterada e a imagem certa. Há alternância de cliques e seleção por setas/
Enter, além de Espaço no negativo e num controlo positivo separado. Os pedidos
de cada nível são esgotados uma vez, com Bonus e passagem natural.

Nas misturas, só o retângulo target desenhado fornece os canais normalizados.
Não são lidos os campos privados targetColor1/2/3. A inversão independente
RGB/CMY calcula os passos; a cor resultante desenhada é comparada com o alvo.
Cada puzzle recebe erro rejeitado com orientação PT, depois botões ou arrastos
reais. A pontuação, bloqueio durante feedback, seis Bonus e progressão natural
são verificados. Dois tracers adicionais verificam gestos no slider durante
feedback, sem substituir as campanhas completas. O modelo matemático é o do
exercício digital, sem afirmar equivalência a mistura física de pigmentos.

## Correções com vermelho e verde

1. O botão menos tinha altura igual à imagem inteira do tubo/lanterna. No
   controlo rodado, a sua MouseArea invisível sobrepunha o início do slider.
   `sliders-red` conserva a falha ao arrastar o verde; o mesmo caso passa em
   `sliders-green` com botões de altura igual à largura. O círculo mantém
   tamanho e centro; a área interativa passa a ser quadrada.
2. O snapping reposicionava o handle durante cada evento e usava a posição
   anterior desse handle para o passo seguinte. Um gesto gradual podia parar
   em 2/3 no nível 3. `slider-ranges-red` reproduz esse limite. O mesmo caso
   passa em `slider-ranges-green` e `slider-ranges-paint-green`, nos três
   controlos e seis níveis. O cálculo usa agora a posição real do ponteiro,
   limitada ao intervalo, sem acumular o arredondamento do movimento anterior.
3. Garnet pedia rubi, apesar de ruby ser outra identidade/cor no corpus. No
   nível 7, o vocabulário estrito pedia ruby e não encontrava essa imagem.
   `garnet-red` e `garnet-green` usam o mesmo caso; o verde pede grená. Não se
   alega que duas respostas rubi estivessem simultaneamente nesse nível.
4. Fawn era traduzido por cor de fauno. O vocabulário estrito fulva falha em
   `fulva-red`; o mesmo caso passa no nível 5 corrigido. A auditoria identifica
   todos os níveis afetados, 5/12/15/16, e os quatro têm oito pedidos verdes
   em `fulva-levelN-green`.

Grená está documentado no [Priberam](https://dicionario.priberam.org/gren%C3%A1).
A [Infopédia inglês/PT](https://www.infopedia.pt/dicionarios/ingles-portugues/fawn)
regista fawn como fulvo/castanho-amarelado no sentido de cor. São duas correções
lexicais de texto; as borboletas não fornecem campo audio de pedido no dataset.
Nenhum OGG/WAV mudou e nenhuma aprovação de gravações de outra tarefa é
estendida a estas palavras.

## Composição e execução

`advanced-complete` preserva os vinte níveis e 160 perguntas completos com
20 Bonus. Usou o catálogo já com grená, ainda com fauno. O índice final retém
os seus dezasseis níveis inalterados e substitui integralmente os quatro níveis
com fawn pelos 32 pedidos corrigidos. Não conta duas vezes as perguntas nem
aprova linguisticamente o texto fauno antigo. As restantes atividades usam os
recibos integrais `basic-complete`, `paint-final` e `light-final`.

O recibo nativo das borboletas terminou com exit_code 0, passed=true, sem timeout,
com dono/limpeza verificados e JSON final impresso. Ao recolher a sessão exec,
o supervisor devolveu 143. `execution-status.json` conserva a discrepância;
não se conhece a causa e não se atribui um sinal ao Qt. Não se afirma que todos
os wrappers terminaram com zero. Não havia launcher nativo vivo na recolha.
Os restantes casos finais terminaram normalmente. Nenhuma aprovação depende
de uma sessão em segundo plano sobreviver a FINAL.

As tentativas iniciais de mistura que pararam antes do terceiro nível completo
permanecem como reprodução/diagnóstico, sem aprovação. Os cinco testes Python
incluem matemática conhecida, adulteração de passos/nomes e rejeição CLI antes
de criar saída. `audit-red.log` precede a implementação do auditor;
`python-green.log` guarda o resultado final.

## Recursos, áudio e limites

Os snapshots privados têm 269 entradas físicas sem symlinks para builds
mutáveis. Os 330 ficheiros expostos nos cinco RCC atuais coincidiram com a
fonte. Manifestos preservam os estágios anteriores e final; cada recibo fixa a
cópia efetivamente usada, caso, catálogo e RCC privado. As cópias de áudio Qt
são comparadas aos RCC PT originais. UID/GID 1000, host só leitura e somente
perfil/saída privados RW; os casos aprovados confirmam dono e limpeza.

As onze instruções PT dos patos têm MediaPlayer original PlayingState,
hasAudio, duração e posição positiva, além de repetição pelo botão. Um tracer
separado confirma Tab. Há também feedback PT solicitado nos percursos.
Isso prova reprodução/descodificação por software, sem audição física ou
aprovação de pronúncia. Os SoundEffect reportam ausência de dispositivo neste
ambiente; não se declara reprodução desses efeitos por analogia ao MediaPlayer.

`inventory.json` preserva os fills reais dos 81 SVG de cores e os comentários
hex históricos. Muitos comentários não coincidem com os SVG atuais; não foram
usados como verdade cromática, nem se recoloriu a paleta. A prova associa nomes
PT e identidades efetivamente desenhadas. Fidelidade perceptiva dos 70 tons,
terminologia rara restante, contraste, diferenças de ecrã/DPI/orientação e
revisão pedagógica continuam pendentes com o professor. Também ficam pendentes
Windows, teclado/rato físicos, touch/mobile, som físico e aceitação global.
Nenhum build principal, mapa, CSV ou recurso áudio foi alterado.
