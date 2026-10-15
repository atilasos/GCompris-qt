# Torres de Hanói no Qt nativo

Os seis casos finais de `index.json` passam num perfil novo PT-PT, sem rede,
com cópias privadas dos 269 recursos de execução. Não foi necessário alterar
código ou traduções de produção.

| Atividade | Níveis completos | Arrastos válidos | Tentativas proibidas |
| --- | --- | --- | --- |
| hanoi_real | 3, com 3/4/5 discos | 53 da solução e 6 de preparação/reposição | 3 |
| hanoi | 6, com alturas 5/5/6/7/8/9 | 213, incluindo 12 de preparação/reposição | 12 |

O caso clássico ordena os discos pela largura realmente desenhada e calcula
uma solução independente pelas regras matemáticas. As soluções usam 7, 15 e
31 movimentos. Tenta colocar um disco maior sobre outro menor em cada nível.
Confirma a ordem vertical final, Bonus e a passagem natural ao nível seguinte.

O simplificado lê os símbolos, cores e posições verticais da referência
vermelha visível. Mantém pilhas próprias para planear arrastos reais para a
torre verde. Confirma a ordem desenhada completa, a referência intacta, Bonus
e transições. Em cada nível tenta exceder a capacidade de uma torre auxiliar
e colocar um disco na referência imutável. As disposições são aleatórias;
estes resultados cobrem uma disposição por nível, não todas as permutações.

Os dois casos de controlos verificam avançar/recuar, reiniciar depois de um
arrasto, ajuda PT, Escape, novo arrasto após fechar a ajuda e regresso ao menu.
Os sete SVG copiados do QRC correspondem byte a byte aos quatro ficheiros
originais usados pelas duas atividades. O auditor confirma os hashes dos
casos, launcher, fontes, catálogo PT, capturas, SVG e resultados.

```sh
python3 .scratch/pt-pt/functional-hanoi/audit.py
python3 tools/run-native-qml-case.py --source-root . \
 --binary /home/proteu/Projetos/GCompris-qt/build/pt-pt/bin/gcompris-qt \
 --activity hanoi_real --qml-file src/activities/hanoi_real/HanoiReal.qml \
 --case tests/hanoi_real.qml --output /novo/resultado --timeout 180 \
 --result-marker NATIVE_HANOI_RESULT --offline
```

Para `hanoi`, usar o mesmo ficheiro QML partilhado e o caso
`tests/hanoi_simplified.qml`, com timeout 300. O caso
`tests/hanoi_controls.qml` serve ambas as atividades com marcador
`NATIVE_HANOI_RESULT` e timeout 120. Cada execução exige uma saída nova.

`classic-visual-order`, `simplified-visual-order`, `controls-real-settled`,
`controls-simplified-settled`, `covered-classic` e `covered-simplified` entram
no índice final. As primeiras campanhas
de jogo positivas ficam como diagnóstico anterior à asserção adicional da
ordem visual. Os primeiros controlos falharam por um helper `top` colidir com
a propriedade final do Qt. Depois de o renomear, outro ensaio começou o
arrasto antes de o novo nível acabar o layout. Esperar pela estabilização
resolveu o fixture nas duas atividades. Os recibos negativos mantêm-se fora
do índice e não demonstram defeitos de produção.

Esta evidência cobre jogo e controlos no Linux nativo offline. Não certifica
Windows, toque, som físico, pronúncia ou revisão pedagógica docente. Os
critérios globais das 203 atividades continuam pendentes na matriz.


## Discos inferiores, tarefa51

Os dois casos curtos novos escolhem o disco inferior pela posição vertical
realmente desenhada e confirmam que o disco e a sua MouseArea estão disabled
quando cobertos. Um arrasto iniciado no centro dessa imagem é redirecionado
para o topo habilitado. Cada MouseArea tem a altura da janela e a largura do
maior disco. Assim, não se exige que a pilha inteira fique imóvel, pois isso
contrariaria a região de entrada existente.

Os snapshots de todos os discos antes/depois distinguem o superior movido dos
restantes, que conservam pai, posição e dimensões. São duas redireções no
clássico e três no simplificado. O inferior mantém a posição enquanto coberto,
passa a enabled só quando exposto e então move pelo mesmo gesto real. Não
foram enviados eventos diretamente ao item disabled nem alterado estado de
produção. O revisor Spec49 confirmou que este contrato responde ao P2.

`covered-classic-red` conserva a primeira hipótese demasiado restritiva de
pilha inteira imóvel. Falhou porque o topo se moveu e o inferior ficou parado,
como mostram os snapshots. É diagnóstico da asserção, não defeito do produto,
e fica fora do índice final. Não foi necessária alteração de produção.

`covered-previous-receipts.json` confirma que os28 hashes de artefactos das
quatro provas anteriores estão intactos. Não foram repetidos os nove níveis
completos. O auditor passa agora seis casos/34 artefactos.

```sh
python3 tools/run-native-qml-case.py --resource-snapshot /SNAPSHOT_SELADO \
 --activity hanoi_real --qml-file src/activities/hanoi_real/HanoiReal.qml \
 --case tests/hanoi_covered.qml --output /novo/resultado \
 --timeout 60 --result-marker NATIVE_HANOI_RESULT --offline
```

Repetir com `--activity hanoi` usa o mesmo motor e caso. As provas novas mantêm
os limites Linux offline e os critérios Windows/hardware/docente separados.
