# Ligar pontos e desenhar — tarefa 48

Verificação nativa delimitada concluída: 18 casos positivos, 126 percursos,
3408 pontos aceites, 252 entradas erradas/fora dos alvos rejeitadas, 46 pausas
entre traços e 126 Bonus. Todos os processos terminaram e têm recibos; não
se contam sessões em segundo plano ou percursos interrompidos.

| Jogo | Níveis | Configurações | Percursos |
|---|---:|---|---:|
| number_sequence | 9 | automática/manual × realce ligado/desligado | 36 |
| clickanddraw | 9 | automática/manual | 18 |
| drawletters | 26 | automática/manual | 52 |
| drawnumbers | 10 | automática/manual | 20 |

## Comportamento e oráculo

A escolha usa o menor número efetivamente visível, ou a imagem azul de
realce quando não há rótulos. Não lê o índice esperado para escolher, não
chama drawSegment/won nem atribui progresso. O contador interno é observado
apenas para verificar o efeito de cada evento. Os fixtures verificam imagens,
quantidades e pausas; não escolhem os alvos. As coordenadas de clique vêm dos
itens renderizados, no canvas estável, sem preparar respostas.

Todos os níveis verificam ponto errado e clique fora dos alvos, uma aceitação
por clique, linhas entre os dois pontos efetivamente escolhidos, rotações
finitas, ausência de conector nas pausas, imagem final Qt Ready e Bonus. Em
cada configuração, os primeiros dois pontos do primeiro nível são traçados
por pressão/movimento/libertação reais de rato na MultiPointTouchArea. Não
se certifica um ecrã tátil físico.

Automática/manual e o realce foram escolhidos pela interface e confirmados na
configuração persistida. O modo manual conserva o desenho concluído até ao
botão de nível seguinte; o automático avança pelo Bonus. As duas formas
regressam ao primeiro nível depois do último. O realce altera o tamanho do
ponto conforme a opção. Os oito casos de controls verificam ajuda PT, total
público de níveis, reinício de um desenho parcial por Gravar, anterior/próximo,
foco e regresso ao menu por Home e Escape.

## Correções reproduzidas

1. Uma pressão podia aceitar dois pontos. O loop ampliava o próximo alvo durante
   a própria verificação; onPressed e onTouchUpdated também verificavam a mesma
   pressão estacionária. Agora o loop para depois de uma aceitação, e as
   atualizações só processam pontos pressionados que realmente se moveram.
   Rejeições de pontos antigos/coincidentes continuam a permitir procurar o
   alvo atual; uma paragem incondicional no primeiro retângulo seria incorreta.
2. O N fazia a pausa um ponto depois do reinício geométrico: desenhava um
   conector adicional e omitiria o começo da diagonal. O segundo traço começa
   agora no ponto 13, depois dos primeiros 12 pontos do traço vertical.
3. O K repetia consecutivamente [160,402] no mesmo traço, criando um segmento
   de comprimento zero/rotação inválida. Removeu-se só essa repetição e o seu
   grupo: 28→27 pontos, preservando todos os outros vértices e a imagem final.
4. A tabela do M passa a explicitar os grupos que antes eram implicitamente
   undefined (mesmo traçado); a do G remove três valores não utilizados,
   preservando os grupos dos seus 29 pontos. Não se inventou outro traçado.

O mesmo caso N, com SHA idêntico, está em `N-fixed-fixture-red` (3 pontos
aceites quando se esperavam 2), `N-strokes-red` (12 linhas em vez de 11 na
pausa) e `N-exact-green`. `K-red` preserva a falha geométrica; `K-green` e os
52 percursos completos das letras passam com o vértice redundante removido.
`data-red.log`, `data-K-red.log` e `data-green.json` registam os controlos dos
dados. As calibrações de fixture anteriores não contam como aprovação.

## Recursos, áudio e limites

`audit.json` exige os 126 pares nível/configuração e confere 100 recursos Qt
copiados contra os originais: 56 imagens, 36 vozes de letras/algarismos e oito
vozes PT de feedback. Os 297 ficheiros expostos nos cinco RCC privados foram
comparados com a fonte. Os dados completos têm geometria finita, coordenadas
válidas, grupos completos e ausência de pontos consecutivos redundantes.

As 36 vozes de A–Z e 0–9 foram efetivamente solicitadas e observadas no
MediaPlayer original: PlayingState, hasAudio, duração e posição positiva.
Isso demonstra reprodução/descodificação de software, sem audição física ou
aprovação docente da pronúncia. Não se estende a estas vozes a aprovação das
32 gravações novas de outra tarefa.

O SoundEffect de audioclick não atingiu reprodução neste ambiente sem saída
de áudio; os estados estão nos recibos. O WAV original descodificou para
fakesink, mas não se chama isso reprodução SoundEffect ou audição. Esse
critério continua nas aceitações áudio/hardware05/08.

Todos os casos usam perfil novo PT-PT, Docker sem rede e snapshot físico
independente de 269 entradas, sem referências operacionais a builds/worktrees
partilhados. O catálogo PT é recompilado privadamente. Nada escreveu no build
principal. `index.json` aponta os 18 resultados; cada caso longo tem PID,
início/fim e saída em `.process.json`. `artifacts-sha256.json` sela os artefactos.

Globalmente continuam pendentes Windows 10/escola, teclado/rato físicos,
touch/mobile, outras orientações/DPI, audição/pronúncia, revisão pedagógica dos
traçados e revisão docente. Não foram acrescentados níveis ou caracteres.
