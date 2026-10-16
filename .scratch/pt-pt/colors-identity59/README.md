# Identidades históricas das cores, tarefa 59

O auditor passa a fixar os inputs da tarefa 53 no commit
`53c2fe61ea46e950e58752a9e6ef0a71b5e80c31`. A prova original continua válida:
19 casos, 254 puzzles, 330 ficheiros Qt. Não houve nova campanha Qt, compilação
de RCC ou alteração de produção. Os 201 artefactos originais e o índice da
pasta functional-colors conservam os mesmos bytes; `preserved.json` regista
essa comparação.

## Ligações verificadas

- Cada caminho do mapa dos cinco RCC canónicos corresponde exatamente ao
  conjunto de ficheiros da revisão Git fixada. SHA-256, tamanho e indicador
  Ogg de cada entrada são comparados aos respetivos blobs. O SHA de cada RCC
  coincide com a captura histórica e o manifesto da etapa final.
- Os 19 recibos e casos conservam os hashes do índice imutável da tarefa 53.
  source_sha256 e runner_sha256 são também comparados aos blobs históricos,
  enquanto o catálogo é conferido contra os bytes da sua etapa específica.
- Os três manifestos de snapshot são ligados aos SHA originais dos recibos.
  O mapa efetivo de 269 ficheiros inclui as duas substituições reais do launcher:
  RCC instrumentado e QM privado. Os SHA privados ficam ligados aos recibos
  capturados, sem reconstruir binários ou inventar uma identidade nova.
- Inventário, vocabulário e identidades de áudio são inputs históricos fixos,
  sem permitir aprovar uma alteração só por recalcular o índice atual.

A primeira etapa colors-current ainda não tinha o manifesto completo na prova.
Foi copiado do snapshot independente conservado no worktree anterior e o SHA
coincidiu com os recibos originais antes de o guardar. As etapas colors-fixed
e colors-final já estavam arquivadas. Nenhum caminho absoluto histórico é
aberto durante a auditoria; o requisito é ter os objetos Git da revisão fixada.

O catálogo inicial já continha grená e ainda tinha fauno. O final contém fulva.
Os bytes iniciais são recuperados da revisão fixada revertendo apenas essa
entrada exata, e o resultado coincide com o SHA capturado antes. Só os quatro
replays fulva e três tracers posteriores usam o catálogo final. O recibo de
160 perguntas conserva o catálogo anterior e a composição continua a substituir
os níveis 5/12/15/16 pelas rotas corrigidas. A discrepância já documentada entre
supervisor 143 e recibo nativo 0 não foi alterada.

## Vermelho e verde

`red.log` reproduz o problema original: alterar um SHA de fonte ainda permitia
saída zero. `identities-green.log` tem nove testes CLI, incluindo a prova válida
movida, 19 controlos negativos de hash/caminho/identidade, e um checkout
alternativo com fonte, launcher e catálogo atuais deliberadamente diferentes.
`all-green.log` inclui também os cinco testes anteriores.

```sh
python3 -m unittest discover -s tests/functional_colors -v
python3 tests/functional_colors/audit.py --evidence .scratch/pt-pt/functional-colors --output /tmp/colors-identity59-index.json
```

`index.json` nesta pasta é a nova saída de verificação; o índice original não
foi reescrito. Os limites da tarefa 53 permanecem: paleta perceptiva, termos
raros restantes, pronúncia/audição física, Windows, dispositivos e professor.
Não houve escrita no build principal, mapa ou CSV, nem push.
