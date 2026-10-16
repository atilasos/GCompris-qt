# Papador de Números, tarefa57

As cinco variantes completaram104 níveis no Qt original PT-PT offline, depois
da correção funcional. São40 de igualdade,40 de desigualdade e8 de cada uma
das variantes fatores, múltiplos e primos. O agregado confere1874 capturas
corretas do jogador,28 avisos e104 Bonus/progressões naturais. As disposições
e trajetórias são aleatórias; não se esgotam todos os tabuleiros possíveis.

| Jogo | Datasets | Níveis finais |
| --- | --- | --- |
| gnumch-equality | quatro operações |40 |
| gnumch-inequality | quatro operações |40 |
| gnumch-factors | sequência incorporada |8 |
| gnumch-multiples | sequência incorporada |8 |
| gnumch-primes | sequência incorporada |8 |

## Escolha e eventos

O caso lê o texto GCText efetivamente visível de cada célula e o pedido PT do
painel. Só então calcula aritmética, igualdade/desigualdade, divisibilidade ou
primalidade por divisão experimental. O auditor Python usa Fraction e volta
a calcular cada decisão. Confere também a progressão do objetivo e operação
por nível; as regressões CLI alteram estes dois campos e são rejeitadas. Não consulta validadores, listas de respostas ou
objetivos ocultos do JS. As coordenadas desenhadas do jogador planeiam setas
e cliques reais; uma entrada é comparada com um passo de grelha. Os canais
alternam por nível, sem alegar o produto cartesiano integral por canal.

Cada campanha rejeita um número errado no primeiro nível e recupera pela tecla
Enter. No percurso há17 capturas adicionais por monstros, sem perder duas vidas
no mesmo nível. Os cinco casos separados de monstros aproximam o jogador de
inimigos que nasceram e se moveram pelos temporizadores originais. Cada um
sofre duas capturas, perde o nível, recupera e completa o mesmo nível por
capturas matematicamente verificadas. São cinco perdas e cinco níveis extras,
que não aumentam o total principal104. Não se alteram posições, vidas,
progresso, inimigos, animações ou temporizadores do motor.

Os cinco controlos exercitam erro/vida, reinício por navegação, anterior/próximo,
ajuda PT, Escape, foco de teclado depois da ajuda e menu. Nas duas variantes
com datasets, o seletor real desativa/grava/restaura a quarta operação e
confirma40→30→40 níveis. As três restantes não expõem esse botão e a ausência
é verificada. As11 campanhas finais percorrem dez níveis contíguos por operação
ou oito por sequência; todas terminam naturalmente no nível seguinte.

## Quatro correções reproduzidas

Os pares title-red/green, return-red/green e monster-red/green conservam os
mesmos casos antes/depois de corrigir só três msgstr: o título de igualdade
dizia Desigualdade, o aviso pedia Retroceder em vez de Enter e a captura dizia
Fos-te em vez de Foste. O monstro nasceu naturalmente no vermelho e no verde.
Não há gravação nova nem alteração de áudio.

`no-monsters-red` reproduz o defeito de estado: abrir o nível2, voltar ao1,
errar e continuar fazia reaparecer monstros apesar de spawnMonsters=false.
O observador registou73 amostras de inimigos em13,6s. initLevel só colocava a
flag withMonsters em true e não a repunha em false. A atribuição agora segue o
valor do dataset em cada nível. O mesmo caso verde observa zero amostras em
13,5s; também passa na variante desigualdade. Não se inventa um bug no gerador
matemático, que passou as decisões independentes por expressão visível.

O primeiro lote104 em `full` e full-summary.json fica como baseline antes desta
correção de estado. O lote final completo repetiu104 com o JS corrigido e
fontes congeladas, em `final`. Só este último fornece os104 níveis do agregado.
Pilotos e tracers de dois níveis são calibração e não entram nessa contagem.

## Arquivo e execução

`final-receipts.json` seleciona21 casos nativos finais:11 campanhas, cinco
controlos e cinco perdas/recuperações. Todos têm Qt/launcher0, sem timeout ou
erros QML, dono verificado e cópia temporária limpa. As sessões supervisoras
foram recolhidas com saída0; não há dependência de processos sobreviverem ao
FINAL. A fonte congelada e o launcher histórico estão arquivados na evidência;
o auditor resolve casos e ficheiros por caminhos relativos, sem reabrir as
ordens absolutas históricas. Os pares vermelho/verde anteriores são separados
dos21 casos finais, sem modificar os seus recibos.

Os50 ficheiros expostos nos cinco RCC foram lidos pelo Qt e comparados byte a
byte com a fonte. O snapshot privado contém269 entradas físicas independentes.
Manifesto e catálogos são preservados; o PO é recompilado privadamente pelo
launcher. Os dois WAV de efeito foram descodificados com GStreamer/fakesink,
sem prova de audição física. O Qt reporta ausência de dispositivo de áudio;
não se declara que os efeitos foram ouvidos.

```bash
python3 -m unittest discover -s tests/functional_gnumch -p 'test_*.py' -v
python3 tests/functional_gnumch/audit.py .scratch/pt-pt/functional-gnumch
python3 tests/functional_gnumch/prepare.py --origin-snapshot SNAPSHOT_BASE --output SNAPSHOT_NOVO
python3 tests/functional_gnumch/campaigns.py --snapshot SNAPSHOT_NOVO --source-root FONTE_CONGELADA --output RESULTADOS_NOVOS --jobs 11
```

O executor recusa saídas já existentes e
seleções de níveis inválidas antes de preparar dados. Nove testes Python/CLI
passam; o oráculo matemático teve vermelho antes de ser implementado.
Windows, toque, rato/teclado físicos, audição/pronúncia e revisão docente
permanecem pendentes. Não certifica a matriz global203 nem altera mapa/CSV ou
build principal.


## Revisão da identidade dos recibos

`receipt-inputs.json` liga os44 recibos históricos, incluindo pilotos, baseline
anterior ao JS corrigido, negativos e resultados finais, ao QML e ao PO exatos
em `frozen-source/manifest.json`. O auditor exige correspondência dos campos
`source_sha256` e `portuguese_catalogue_sha256` de cada recibo com esses arquivos.
Não procura o catálogo atual do projeto, nem escolhe a fase pelo campo mutável
do próprio recibo. A relação por pasta conserva a fase histórica.

Os21 casos finais e o baseline completo usaram o PO `c8d794b5…`; não houve
alterações no QML comum entre as fases. Para conservar os três PO anteriores,
partiu-se do PO final arquivado e inverteram-se, por esta ordem, apenas estas
substituições msgstr, uma ocorrência cada:

1. `Foste comido por um Ogre.` → `Fos-te comido por um Ogre.` (SHA85f1efbb…,
   usado por return-green, pointer-pilot e monster-red).
2. `Carrega em "Enter" ou clica aqui para continuares.` →
   `Carrega em "Retroceder" ou sobre mim para prosseguires.` (com as aspas
   escapadas do PO; SHAffcbabed…, usado por title-green, return-red e pilot).
3. `Igualdade do Gnumch` → `Desigualdade do Gnumch` (SHA51359920…,
   usado por title-red).

Cada reconstrução coincide com o SHA256 completo já registado pelo launcher
na execução histórica. Os bytes reconstruídos estão em `catalogue-phases/`
dentro de `frozen-source`, com hashes completos no manifesto. Não se alterou
nenhum recibo, caso, screenshot ou saída nativa. `identity-review/` preserva o
vermelho CLI (12 adulterações antes aceites), o verde e a comparação byte a
byte dos44 recibos com o checkpoint anterior à correção.

O teste portátil copia a evidência e os dois módulos do auditor para um
contentor sem rede, sem a worktree original e sem fontes atuais montadas.
Confere104 níveis e rejeita alterações no QML, PO histórico e manifesto;
a troca por outro PO histórico válido também é rejeitada. Nove testes passam.
Não houve nova execução Qt, mudança de produção ou ampliação da cobertura.
