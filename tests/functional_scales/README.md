# Concluir os puzzles das três balanças

O teste arrasta pesos reais na aplicação Qt, lê os rótulos apresentados e
observa a agulha. Para os presentes sem rótulo, pesquisa as somas atingíveis
até encontrar equilíbrio. Não lê a massa interna do presente, a resposta da
pergunta nem os alvos do dataset para resolver.

## Executar

Cria uma cópia independente de um build estável com recursos offline:

```bash
python3 tools/native_qml_resources.py \
  --binary /caminho/build/bin/gcompris-qt --output build/scales-snapshot
python3 tests/functional_scales/run.py --activity scalesboard \
  --resource-snapshot build/scales-snapshot \
  --output .scratch/pt-pt/functional-scales/nova-execucao/scalesboard
```

Repete para `scalesboard_weight` e `scalesboard_weight_avoirdupois`, com saídas
novas. Os três casos podem correr em paralelo, usando o mesmo snapshot selado.
Cada processo tem perfil, catálogo, RCC instrumentado e saída privados. O host
fica só para leitura e o Docker sem rede. O build de origem não é alterado.
Usa `--controls` para ajuda PT, navegação, reinício por Gravar após um arrasto
parcial e regresso ao menu. `--levels N` serve apenas para tracers parciais;
sem essa opção, o auditor exige as contagens completas abaixo.
`--physical-only` desliga a preferência do teclado visual e usa teclas físicas
simuladas em todas as respostas; pode ser combinado com `--levels 3` para
repetir uma amostra dos três modos iniciais.

| Atividade | Datasets | Níveis | Puzzles |
| --- | --- | --- | --- |
| scalesboard | 8 | 52 | 223 |
| scalesboard_weight | 6 | 45 | 222 |
| scalesboard_weight_avoirdupois | 6 | 45 | 221 |

Os datasets incluem presentes com rótulo, pesagem com massas nos dois pratos
e presentes ocultos seguidos de entrada numérica. Os casos completam todos os
puzzles de cada nível e esperam as animações de pontuação, o Bonus e a transição.
Uma disposição ou resposta errada é submetida no primeiro puzzle de cada nível.
Antes de equilibrar um presente oculto, o teste verifica que OK está desativado.
Nas perguntas, usa algarismos por eventos físicos simulados ou cliques no teclado
visual, alternando a rota por puzzle. Verifica Backspace e valida por OK ou Enter.

## Calcular pela informação visível

`oracle.js` interpreta os rótulos com as relações 1 kg = 1000 g e 1 lb = 16 oz.
Enumera as posições possíveis de cada massa conhecida. Quando o prato direito
aceita pesos, prefere uma solução que use ambos os pratos. A balança simples
usa os números apresentados, sem acrescentar unidades.

Para presentes ocultos, a busca ordena as somas atingíveis e compara a agulha
com cada tentativa. Se um arranjo intermédio já equilibra e abre a pergunta,
essa pesagem termina imediatamente. A resposta numérica vem da soma assinada
dos pesos conhecidos e da unidade pedida no texto visível da pergunta.

Cada arrasto usa mousePress, movimentos que ultrapassam o limiar e mouseRelease,
com coordenadas da cena estática. O teste espera o layout dos pesos e verifica
que o peso pretendido detém o arrasto e chega ao prato escolhido. Não chama
funções de transferência, altera modelos ou atribui posições dos pesos.

O auditor Python volta a calcular as somas com Decimal. Verifica rótulos,
posições, conservação das massas, inclinações observadas na busca e a unidade
da entrada numérica. Os exemplos independentes e controlos negativos são:

```bash
node tests/functional_scales/oracle.test.cjs
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover \
  -s tests -p test_scales_math_audit.py
```

O teste Node também recusa leituras de campos de peso/resposta ocultos no caso
de interação. `oracle.json` é escrito só depois de passar a auditoria matemática.
O launcher conserva hashes de recursos, binário, fonte, catálogo e caso, além
dos logs e capturas por combinação de unidades e modo de jogo.

## Limites

O ensaio cobre os datasets selecionados no perfil novo, sem enumerar todos os
subconjuntos de configuração. No percurso completo, a preferência global do
teclado visual mantém-se ativa e as duas rotas de digitação são usadas nesse
modo. A preferência desligada tem um tracer separado dos primeiros três
níveis de cada jogo. Não afirma duas execuções completas de cada puzzle com
essa preferência ligada e desligada.
As relações de unidades são verificadas no jogo abstrato, sem massas físicas.
Windows, instalação na escola, dispositivos físicos, audição e revisão docente
continuam critérios separados. Não há testes de indução de falhas.
