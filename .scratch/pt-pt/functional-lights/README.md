# Apagar as luzes: execução nativa em PT-PT

`lightsoff` concluiu os 99 níveis dos nove conjuntos de dados, com 99 Bonus
naturais. O teste executou 1 736 cliques de resolução e 198 cliques adicionais
para observar um movimento sem vitória e a sua reparação em cada nível.
São 57 tabuleiros fixos e 42 tabuleiros aleatórios, nas dimensões 5×5 a 9×9.

## Falhas corrigidas

Selecionar apenas o conjunto 9×9 fazia o primeiro exercício começar já resolvido,
com todas as luzes apagadas e um Bonus sem jogadas. O caso `dynamic-start.qml`
reproduz esse resultado na fase `d83e5ab7e` e passa na fase `4e2f434cf`.

Os reinícios também podiam produzir um tabuleiro vazio quando as jogadas
aleatórias se anulavam. O caso `restarts.qml`, com apenas o conjunto 6×6 e o
terceiro nível, encontrou essa falha na amostra 88. Exatamente o mesmo caso
passou 150 reinícios depois da correção. O gerador faz pelo menos uma jogada e,
se o resultado ficar vazio, acende uma cruz adicional.

Os dois pares preservam o SHA idêntico de cada caso vermelho e verde. As 150
amostras adicionais não aumentam a contagem dos 99 níveis da execução completa.
A seleção individual dos conjuntos 6×6, 7×7 e 8×8 também confirmou exercícios
iniciais por resolver. Esses três casos de arranque não são conclusões extras.

## Observação e controlos

O caso lê as imagens `on.svg` e `off.svg` efetivamente desenhadas, ordenadas
pelos centros e dimensões da grelha. Calcula uma solução por eliminação em
GF(2), independente da solução e do histórico mantidos pelo jogo. Cada clique
real tem a transformação visível comparada com a regra da cruz. A auditoria
Python recalcula todos os movimentos e verifica os tabuleiros finais apagados.
Não se leem `lighton`, `soluce`, modelos nem listas de soluções da atividade.

Os controlos passaram com setas, Espaço e Enter, realce do teclado, dica
visivelmente desenhada, reinício parcial, navegação e passagem entre o primeiro
e o último nível. O seletor foi alterado, guardado, reaberto e restaurado no mesmo
processo. A ajuda apresentou o título "Apaga as luzes" e a descrição "Desliga
todas as luzes.". Escape devolveu o foco ao teclado sem clique ou foco forçado.
O regresso ao menu também passou.

O primeiro piloto falhou porque o efeito de ampliação sob o rato deslocava as
bordas da imagem para fora da célula nominal. Era uma hipótese incorreta do
ensaio. O teste passou a observar centros, que permanecem estáveis sob essa
ampliação. `pilot` e `pilot2` ficam preservados como históricos, fora da seleção
final e sem aumentar a cobertura declarada.

## Arquivos e retornos

`capture.json` fixa 182 ficheiros selecionados por SHA-256. `source-tree.zip`
preserva 232 ficheiros das duas fases, incluindo o catálogo PT, o motor,
componentes, recursos e executores. `resource-snapshot.json` identifica os 269
ficheiros do runtime privado. As execuções usam Docker sem rede, UID e GID 1000.

A seleção contém nove casos, sete positivos e dois vermelhos esperados. Todos
terminaram o processo Qt com código 0. O supervisor e a ferramenta externa
terminaram com 0 nos positivos e com 1 nos vermelhos. Cada `tool-status.json`
transcreve o retorno recebido da ferramenta, com sessão e identificador de saída.
Esses valores são distintos do retorno do processo Qt.

Os RCC efetivamente usados pelos dois casos vermelhos e pelo caso final
`effective-final` estão em `effective/`. O inspetor `qt-rcc-inventory.cpp`,
compilado com QtCore, registou cada RCC e extraiu os seus 18 ficheiros. A auditoria
liga os hashes aos recibos e compara o motor e o QML instrumentado com as fontes
e o caso correspondentes. O RCC da execução principal foi removido pelo
lançador após sucesso e não é apresentado como arquivo preservado. O caso extra
final fornece a verificação explícita dos recursos efetivos dessa fase.

Os casos de recursos confirmaram 22 ficheiros QRC e o carregamento dos SVG pelo
Qt. Três WAV originais passaram a descodificação completa por GStreamer para
`fakesink`. Isso certifica leitura por software, sem audição ou dispositivo.
As imagens guardadas documentam níveis e grelhas selecionados. Não há OCR nem
reconhecimento de píxeis de todos os tabuleiros.

## Verificação reproduzível

Na raiz do repositório, os comandos verificam as provas sem iniciar Qt ou Git:

```sh
python3 tests/functional_lights/audit.py
python3 -m unittest discover -s tests/functional_lights -p 'test_*.py'
```

Os 13 testes incluem exemplos independentes e os 57 tabuleiros fixos sem usar
as soluções fornecidas pelo autor. Os testes das provas aceitam uma cópia
isolada das ferramentas e dos arquivos. Rejeitam movimentos adulterados,
sequências vazias, fontes históricas alteradas, recursos efetivos modificados,
imagens guardadas alteradas, retornos externos falsos e casos que omitam níveis.
A execução com Python otimizado é recusada explicitamente. `index.json` é
apenas uma saída derivada da auditoria.

Windows 10, dispositivos físicos, audição, revisão docente e aceitação global
continuam pendentes. Uma amostra de cada nível aleatório não esgota todos os
sorteios possíveis.
