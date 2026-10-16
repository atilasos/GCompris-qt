# Ordenação PT-PT no Qt nativo

Os seis recibos finais de `index.json` passaram no Linux, em perfis novos
PT-PT sem rede, usando um instantâneo independente de 269 ficheiros físicos.
São 36 níveis completos, 36 ordens erradas rejeitadas, 636 arrastos de jogo e
três arrastos parciais adicionais nos controlos. Não se alterou o motor JS.

| Atividade | Conjuntos | Níveis | Arrastos de jogo |
| --- | ---: | ---: | ---: |
| ordering_numbers | 8 | 8 | 139 |
| ordering_alphabets | 6 | 8 | 139 |
| ordering_sentences | 2 | 20 | 358 |

Cada nível começa pelos rótulos realmente desenhados. Números usam comparação
numérica; letras usam o alfabeto explícito a-z, invertido segundo a instrução
visível. As frases completas de referência foram escritas a partir dos sacos
visíveis do inventário, usando sujeito/verbo, maiúsculas e pontuação. O teste
combina esses textos com os cartões apresentados, incluindo grupos de palavras.
Não consulta `originalArrangement`, índices da solução ou dados canónicos do
motor para decidir uma resposta. Não chama validação nem escreve estado de jogo.

Cada percurso arrasta uma ordem errada, prime OK, verifica Bonus negativo e
bordos vermelhos, devolve os cartões à origem e conclui a ordem correta. Os
bordos verdes e a passagem natural ao nível seguinte são observados, incluindo
a volta ao primeiro nível. No primeiro nível de cada jogo há também uma
reordenação real de cartões já no destino. Mantêm-se os 500 ms originais das
animações e o tempo natural de Bonus.

Os controlos verificam guardar um conjunto excluído, o valor persistido em
ApplicationSettings, reabrir a configuração, restaurar todos os conjuntos e
reiniciar um arrasto parcial. Ajuda PT, foco, anterior/seguinte com retorno e
menu passam nas três atividades. O fundo atinge Image.Ready; a classe File
original lê o recurso QRC e o auditor compara os bytes UTF-8 com o SVG original.

## Dados e correção

`data-green.json` cobre as 16 pastas de dados, todos os 20 textos PT de frases,
os oito níveis de letras, os oito intervalos numéricos e hashes de todas as
fontes das três atividades. Os conjuntos aleatórios têm uma amostra nativa por
nível; o inventário verifica todos os 26 caracteres do respetivo alfabeto e a
capacidade de cada intervalo. Não se afirma testar todas as combinações aleatórias.

O catálogo original tinha quatro frases fora dos intervalos explícitos dos
comentários: futebol com 7 palavras, máximo 5; Sol com 5 e sair com 4, mínimo 6;
família com 12, máximo 10. `data-red.log` conserva a falha inicial e
`sentences-inventory` confirma os cartões originais no Qt. A correção mantém os
20 níveis e ajusta só essas quatro frases. Os objetivos PT passaram a "Até 5/10
palavras", inclusivos. A campanha final usa o QM PT_PT corrigido.

Reproduzir a auditoria vermelha e verde sem alterar o checkout:

```sh
git show 4713dc58e:poqm/pt/gcompris_qt.po > /tmp/ordering-original.po
python3 tests/functional_ordering/audit_data.py --catalogue /tmp/ordering-original.po
python3 tests/functional_ordering/audit_data.py
```

## Repetir

Criar uma cópia privada de recursos estáveis. O primeiro comando apenas lê o
build indicado. O segundo recompila quatro RCC nessa cópia de preparação,
antes de criar outro instantâneo físico selado; nunca indicar um build
partilhado em `--base` nem usar uma cópia que esteja mapeada num processo.

```sh
python3 tools/native_qml_resources.py --binary /BUILD/bin/gcompris-qt --output build/ordering-staging
python3 tests/functional_ordering/prepare.py --base build/ordering-staging --output build/ordering-snapshot
python3 tests/functional_ordering/run.py --snapshot build/ordering-snapshot --output /novo/resultado
python3 tests/functional_ordering/audit_evidence.py
```

`run.py` mantém subprocessos próprios e publica PID, início, fim e duração.
Aceita `--activity` e `--case` para replays limitados. Os casos nativos emitem
um heartbeat por nível. O auditor verifica as seis pastas finais nomeadas,
resultados, contagens e hashes; para um novo resultado, usar os mesmos caminhos
num checkout sem essas pastas ou adaptar a tabela explícita de recibos.
`preparation.json` guarda os hashes dos quatro RCC recompilados. Uma segunda
preparação com o helper final produziu o mesmo manifesto de 269 ficheiros.

Todos os processos finais terminaram antes da recolha. Pilotos de instrumentação
não entram no índice. As letras expostas são minúsculas a-z; não existe um modo
de maiúsculas ou acentos nesse jogo. As frases mantêm e exercitam os seus
acentos, cedilha e maiúsculas. Não se certifica correção de todas as permutações
linguisticamente possíveis. A revisão pedagógica docente continua pendente,
incluindo clareza das quatro frases ajustadas.

Esta prova cobre rato sintético entregue ao Qt original. Não certifica toque
físico, Windows, som ou pronúncia. O programa inicia mudo e estes jogos não
pedem vozes. A aceitação global continua pendente na matriz principal.
