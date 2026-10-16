# Associar imagens, formas e nomes: tarefa 75

Os percursos finais terminaram em Linux Qt nativo, offline e com perfis novos.
As três atividades partilham Babymatch.qml; details e paintings não entram neste lote.
A conclusão é desta prova funcional delimitada, não da aceitação global do projeto.

| Atividade | Níveis | Tabuleiros/subníveis | Associações |
| --- | ---: | ---: | ---: |
| babymatch | 7 | 7 | 21 |
| babyshapes | 7 | 11 | 56 |
| imagename | 7 | 7 | 42 |
| Total único | 21 | 25 | 119 |

Em babyshapes, os níveis 1–4 usam formas, o 5 o cão com três partes,
o 6 o cão com seis partes e glow=false, e o 7 cinco pinturas com 3/4/5/5/6
peças. As 25 boards completas incluem uma troca errada de duas peças,
confirmação dos dois indicadores vermelhos e reparação por arrastos reais.
Os 21 Bonus e as transições de nível são naturais. Não se escreve progresso,
não se chama a solução interna e não se encurtam animações ou relógios.

## Oráculo visual

O inventário usa apenas imagens, textos e tipos dos recursos, removendo
coordenadas. A resolução usa as imagens e rótulos realmente apresentados,
mais os centros dos círculos desenhados. Não lê modelos, posX/posY, client
 data ou correspondências internas do motor.

As relações semânticas de babymatch foram anotadas após inspeção das imagens;
semantics.json guarda a razão para cada uma. A relação bola/raquete exprime
objetos de desporto, sem afirmar que a bola de futebol é de ténis. O professor
continua a poder rever estas escolhas pedagógicas. Imagename usa um dicionário
PT explícito baseado nas imagens inspecionadas, não nos nomes das respostas.
As folhas de contacto inspecionadas estão guardadas nesta pasta.

Para formas, renderização SVG e IoU das silhuetas produzem uma correspondência
única, com margem sobre a segunda opção. Nas fotografias, usam-se componentes
dos buracos claros/coloridos, dimensões, alfa e continuidade dos contornos;
a posição do buraco é calculada dos píxeis da imagem e projetada no quadro
realmente apresentado. As três partes do primeiro cão têm relações espaciais
anotadas pela inspeção. O auditor reconstrói o oráculo a partir dos recursos
originais e recalcula os destinos a partir da geometria visível dos recibos.
Confere os 119 centros por píxel nas perguntas e os 50 indicadores vermelhos.
Não se afirma OCR nem inspeção humana individual de cada captura.

## Correções com vermelho e verde reais

* O nome de eggcup passou de «copo de ovo» para «oveiro». O mesmo caso Qt no
  nível 2 de imagename falha com o catálogo antigo e passa com seis associações,
  uma tentativa errada e Bonus. [Infopédia](https://www.infopedia.pt/dicionarios/lingua-portuguesa/Oveiros)
  regista o sentido de recipiente que sustenta o ovo à mesa.
* O limiar de saída da lista comparava a posição local da borda da peça com
  dimensões de outro referencial. Uma peça de La Dame à la licorne era recusada
  no círculo realmente mostrado. A decisão usa agora o centro da imagem e a
  borda do painel, ambos no referencial da página. O mesmo caso Qt falha antes
  e passa depois, concluindo as cinco pinturas; há ainda regressão 800×801.
* A legenda «Vida Estática da Flor» passou a «Natureza-morta com flores».
  O mesmo caso Qt chega à quinta pintura e falha com a tradução antiga;
  passa após a correção e conclui o nível. O termo é atestado no
  [Priberam](https://dicionario.priberam.org/natureza-morta) e na descrição de
  [pintura do Paço dos Duques](https://pacodosduques.gov.pt/monumentos/paco-dos-duques/colecao/pintura/flores-frutos-pd0051dep/).

Os três pares conservam casos QML byte a byte iguais entre vermelho e verde,
recibos, capturas, status pós-espera e fontes anteriores em history/.
O vermelho esperado tem Qt 0 com uma asserção falhada, launcher 1 e ferramenta 1;
os verdes têm Qt/launcher/ferramenta 0. Não são somados novamente aos 25 tabuleiros.

## Controlos, recursos e áudio

Cada atividade passou reinício por navegação após colocação parcial, volta
anterior/seguinte, teclado real (Right/Space/Tab/Delete), ajuda PT/Escape,
restauro de foco após ajuda com Backspace e regresso ao menu. As três expõem
sete níveis e não expõem seletor de configuração nem datasets múltiplos.

As três provas QRC copiaram 268 ficheiros originais, conferidos byte a byte
com a fonte selada; SVG/WebP foram carregados por Image.Ready. Incluem os
três WAV scroll/completetask/crash, repetidos em três cópias. audio-decode.json
regista descodificação integral por libsndfile de nove cópias de três WAV.

O caso audio-observed usa os controlos originais com áudio ativado. Observou
as rotas scroll.wav e pt/misc/super.ogg e estados PlayingState/hasAudio do
MediaPlayer real. Isto é prova de software, não de som ouvido. Os efeitos
GCSoundEffect completetask/crash ficaram status 0 e playing=false: não são
contados como reprodução. As boards de imagename, incluindo oveiro, não têm
soundFile nem toolTipText próprios; a seleção usa scroll.wav. Não há voz de
palavra alterada ou gerada. A aprovação dos 32 clips novos e os dois pares
legados da tarefa 44 conservam os seus âmbitos e limites próprios.

## Limite adicional da geometria estreita

A regressão extra 800×801 concluiu as cinco pinturas, com cinco tentativas
erradas e Bonus, sem reutilizar a contagem dos percursos landscape. Em Quarto
em Arles, a legenda cobre um dos 23 centros: o píxel é cinzento da legenda,
não a cor do círculo. O auditor fixa essa ocorrência como centro ocluído;
ela não entra nos 119 centros visíveis confirmados da campanha completa.
O arrasto real para essa região funcionou. Não se generaliza esta regressão
extra a todos os tamanhos de janela.

## Prova imutável e reprodução

A fonte final do replay é 7276bb59230a4947ba32b32715d5da2025d94eb3,
388 ficheiros físicos em archive/. Inclui fonte comum/dependências, recursos,
PO, casos, launcher/supervisor e manifesto de snapshot independente de 269
ficheiros, sem depender de outra worktree. Os recursos privados foram
compilados antes da concorrência; o build principal não foi alterado.
A identidade SHA-256 do manifesto de fontes é
`6f601572ca7782df2226e5f5d66f4dd7ad8a136a35e54e639779a7946550a8b3`.

O capture.json liga 2116 ficheiros de prova aos blobs do commit
`46cf2ec2d4a479f93a8ba103542ac46c7de9fb20`.
O auditor fixa o SHA-256 desse manifesto:
`eedee85f435c10b3829ab6c0528d846c4b2762751536d47ef474eff4304cb32e`.
A cápsula física e este selo são a âncora de confiança; a auditoria não confia
no catálogo corrente nem exige Git ou os binários grandes do snapshot.
Uma alteração local de manifesto não substitui essa âncora.

```sh
python3 -B auditor/audit.py --evidence .
```

A cópia portátil exige Python, Pillow, Node, librsvg, cairo e libsndfile.
Os 13 testes passaram: cópia fora de Git, rejeição de Python -O, fonte/PO/caso
alterados com manifestos recalculados, resposta/geometria/píxel adulterados,
percurso vazio, saída pós-espera e retorno externo 143, além de dois testes
de independência dos oráculos. O resultado fica em audit-tests.txt.

```sh
python3 -m unittest discover -s tests/functional_association -p 'test_*.py'
python3 tests/functional_association/run.py --archive .scratch/pt-pt/functional-association/archive --snapshot SNAPSHOT_PRIVADO --output NOVO_DIRETORIO
```

O runner espera todos os filhos. Os dez .process.json só são escritos após
wait e ligam status pós-espera a recibos nativos e supervisor. final-tool.json
regista o retorno 0 efetivamente observado da ferramenta externa, ligado aos
dez status. O áudio extra e os seis casos vermelho/verde têm retornos
externos observados em observed-tools.json. Ao todo: 14 positivos e três
vermelhos esperados; todos os processos terminaram antes da entrega.

first-campaign/ conserva os dez percursos anteriores completos com o catálogo
anterior à correção da legenda, sem reescrever esses factos nem os somar.
archive-before-caption/ e archive-caption/ preservam as respetivas fontes.
A campanha final foi repetida com os dois termos corrigidos e a geometria
visível registada. pilot1 é erro de sintaxe do caso; dog-pilot interrompeu-se
no arrasto que motivou a correção; os outros pilotos são diagnósticos parciais.
Nenhum piloto ou campanha histórica aumenta as contagens finais.

Windows 10, dispositivos físicos, audição e revisão docente/pedagógica global
continuam pendentes. Não se declara aqui uma aceitação global passada.
