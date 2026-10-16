# Regresso ao menu após sucesso, complemento da tarefa 85

A revisão Spec85 encontrou uma lacuna de cobertura no requisito de menu após
sucesso. Este suplemento acrescenta três execuções reais. Não altera nenhum
dos 1010 objetos nem o índice do arquivo `functional-cycles`.

Cada caso repete o percurso completo da respetiva simulação na fonte final
`58e67c399e4de26d84d02d3d43080a488ed6b9cd`, aguarda os sucessos naturais e
usa Ctrl+W. Confirma `pageView.depth=1`, `isMenu=true` e `busy=false`, além de
capturar a imagem do menu. As regras independentes originais voltam a validar
a viagem completa nos dois sentidos, o ciclo da água e os três níveis de energia.
São três repetições de cobertura, sem aumentar a quantidade de níveis distintos.

Todos os retornos Qt/supervisor/capturador terminaram com zero. A ferramenta
observou as saídas depois de esperar: eclusa sessão 7897/22aa2c, água
sessão 62243/7fc66b, energia sessão 30193/330cbc. Não ficaram processos ativos.
Cada execução mantém o RCC efetivo, QM real e extrações QtCore. As fontes e
runtime completo são ligados à cápsula final e ao inventário de 269 ficheiros do arquivo
primário. Só os recursos selecionados estão preservados fisicamente no arquivo;
não se afirma que todos os 269 ficheiros em bytes estejam aqui disponíveis.

O índice novo ancora 139 objetos e tem SHA-256
`7ce01a7f0cbafdb63647118feccf52a7e98b498dd0c3e7bc77e64dc2bc6f7e43`.
O auditor suplementar exige essa âncora literal e a âncora primária. Recalcula
as ligações entre fontes/caso/instrumentação/RCC/QM/recibos/status/imagens e
compara o resultado com o marcador Qt original. Verifica a conclusão antes
que o mesmo caso execute o regresso real ao menu. A ordem executada está no
caso físico e no RCC instrumentado; a água também exporta tempos sucessivos.

```sh
python3 tests/functional_cycles/audit_menu.py
python3 -m unittest discover -s tests/functional_cycles -p 'test_*.py'
python3 -O -m unittest discover -s tests/functional_cycles -p 'test_*.py'
python3 tests/functional_cycles/portable.py --menu
```

Os 17 testes passaram normal e `-O`. Os testes suplementares recusam menu falso, transição ainda ativa e recibo
falso coerentemente resselado. Os testes primários continuam incluídos.
A cópia portátil abrange ambos os arquivos físicos, sem rede, Git, Qt ou
checkout original, normal e `-O`. Windows, equipamento, audição, docente,
estabilidade da tarefa 83 e aceitação global continuam pendentes. Nenhum produto ou áudio
foi alterado por este complemento. A revisão independente do suplemento falta.
