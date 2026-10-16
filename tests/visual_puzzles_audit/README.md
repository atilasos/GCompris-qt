# Auditoria física dos puzzles visuais (tarefa88)

O auditor verifica uma cápsula imutável de19 execuções Linux, incluindo as
observações históricas negativas. Recalcula106 colocações de pormenores a partir
dos recortes e fundos,35 diferenças entre fotografias e261 colocações de pinturas
a partir das máscaras, cores e círculos visíveis. Nunca lê coordenadas de resposta
dos ficheiros `board*.qml`. Os nomes das imagens identificam bytes, não posições.

```sh
python3 tests/visual_puzzles_audit/audit.py --evidence .scratch/pt-pt/functional-visual-puzzles/capsule
python3 -O tests/visual_puzzles_audit/adversarial.py --evidence .scratch/pt-pt/functional-visual-puzzles/capsule
python3 -m unittest discover -s tests/visual_puzzles_audit -p 'test_*.py'
```

`audit.audit(path)` devolve as contagens validadas ou lança uma exceção.
`collect.collect(root_evidence, snapshot_manifest, selection, effective_indexes,
external_observations, output)` lê observações terminadas para uma saída nova.
A CLI de recolha apresenta os mesmos argumentos; os índices de exportação e os
recibos externos aceitam argumentos repetidos. A recolha produz um candidato:
a sua própria declaração de sucesso não lhe dá confiança.

`anchor.py`, fora da cápsula, contém literalmente os SHA256 do índice e do ZIP
original. `capture.json` liga caminhos lógicos a objetos por SHA256, conserva as
fases de fonte e classifica separadamente os casos finais, pilotos, negativos,
inventários, calibração e legendas. Os quatro blocos `objects.zip.partNNN`
concatenam exatamente o ZIP original. `archive.json` regista tamanho e SHA256
do conjunto e de cada bloco. `partition.py` cria esta representação numa saída
nova sem alterar o índice, a âncora ou qualquer objeto original.

A cápsula contém o executável real, o manifesto269, sete RCC canónicos e as suas
836 entradas extraídas,19 RCC/QM efetivos e as suas extrações, todos os ficheiros
das fontes congeladas, casos, recibos, retornos, logs e imagens. O inspetor QtCore
que efetuou as extrações também é conservado; a auditoria pura verifica os bytes
e a correspondência com fontes/instrumentação, sem executar novamente o inspetor.
O manifesto269 identifica ainda bytes do ambiente nativo que não são todos
copiados. As observações externas são declarações do agente raiz com referências
às sessões/chunks reais; não constituem assinaturas independentes da plataforma.

Os contratos finais exigem53 tabuleiros,367 peças,35 diferenças,53 tentativas
erradas reparadas,53 Bonus naturais e três casos de controlos. O percurso antigo
das pinturas conserva apenas19 conclusões: o modelo anterior falhou no nível20.
O modelo final usa o solucionador alfa/RGB nos outros21 tabuleiros e o módulo
retangular no nível20, com faixas RGB2/4/8 concordantes e recusa de ambiguidades.
A calibração neutra mede escala, sem usar o seu destino como resposta.

Os dois pares lexicais verificam exatamente os mesmos casos e expectativas,
43 legendas por cor e seis traduções corrigidas. Além do PO, as fontes congeladas
destes pares diferem em `build_oracle.py`, que passou a aceitar uma pasta base;
esse auxiliar não é executado pelos casos lexicais. Os ficheiros de produto,
casos e expectativas são comparados estritamente. A composição distingue a
validação lexical atual dos percursos de jogo anteriores.

A auditoria descodifica novamente os398 rasters, verifica164 renders SVG
conservados e os recibos de descodificação integral de quatro WAV para fakesink.
Não volta a executar librsvg/GStreamer, nem prova audição humana ou dispositivo.
O primeiro diagnóstico sem `rsvg-convert` é conservado como falta de pré-requisito.

`adversarial.py` ataca cópias físicas: exige rejeição por âncora externa e,
mesmo quando o teste confia deliberadamente numa nova âncora adulterada, exige
que um alvo alterado com recibos/log/hashes coerentes passe as verificações
físicas e falhe o recálculo de píxeis. Um conjunto vazio também tem de falhar.
O original permanece intacto. Todas as guardas usam exceções efetivas sob `-O`.

`portable.py` copia fisicamente cápsula e código para Docker Python3.12-slim,
instala exclusivamente o wheel Pillow12.1.1 local e executa auditoria e ataques
normalmente e com `-O`, sem rede, Qt, Git ou árvore original. Recusa relatórios
existentes antes de consultar dependências ou executar processos. O wheel fica
fora do Git; `dependency.json` fixa o SHA256 publicado pelo
[PyPI](https://pypi.org/pypi/pillow/12.1.1/json). Exemplo:

```sh
python3 tests/visual_puzzles_audit/portable.py --evidence .scratch/pt-pt/functional-visual-puzzles/capsule --wheel CAMINHO_DO_WHEEL --output NOVO_RELATORIO.json
```

O snapshot sela executável/RCC/QM/Box2D, mas o percurso nativo utilizou as
bibliotecas Qt/plugins/libc/QtTest do anfitrião através de chroot. A imagem Alpine
identifica o invólucro offline, não uma distribuição Qt completamente selada.
Esta cápsula permite auditoria pura portátil; não permite repetir autonomamente
toda a distribuição nativa. Windows, áudio humano e aceitação docente continuam
fora desta prova. A ferramenta não altera o mapa, CSV ou estado da tarefa.
