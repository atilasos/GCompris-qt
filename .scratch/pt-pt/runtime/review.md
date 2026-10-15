# Correções de arranque e verificação offline

A tarefa 06 permanece em curso. Estes resultados não aprovam os 203 jogos,
a conclusão dos níveis nem a reprodução sonora.

## Causa das duas exceções

O arranque direto de `multiple_choice_questions` e `ordering_chronology` num
perfil novo falhava em `subLevels` e `instruction`, respetivamente. Os registos
originais estão em `before/`. O comando que reproduziu ambas as falhas foi:

```bash
python3 tools/smoke-activity.py \
  --binary /home/proteu/Projetos/GCompris-qt/build/pt-pt/bin/gcompris-qt \
  --output .scratch/pt-pt/runtime/before --seconds 3 \
  multiple_choice_questions ordering_chronology
```

Eram modelos destinados a receber dados do professor: os metadados declaravam
`levels: []` e condicionavam a disponibilidade à existência de níveis. O arranque
pela linha de comandos contornava essa disponibilidade e entregava listas vazias
aos jogos. Não se acrescentou uma condição que escondesse a exceção.

Para cumprir o âmbito confirmado de todas as atividades offline:

- A ordenação cronológica passa a disponibilizar os três conjuntos de imagens
  já existentes: ciclo de uma flor, viagem à Lua e o Tux a apanhar uma maçã.
- A escolha múltipla passa a disponibilizar três níveis e cinco perguntas com
  texto traduzível e tradução PT-PT. Abrange uma resposta, várias respostas,
  retorno explicativo e uma pergunta sem painel explicativo. As perguntas tratam
  números, cores, animais e lados do triângulo. O professor pode continuar a
  fornecer conjuntos próprios.
- O rótulo `Pattern` do painel de desenho passa por `qsTr` e apresenta `Padrão`.

Os novos conteúdos de escolha múltipla e a adequação das sequências existentes
continuam sujeitos à revisão pedagógica do professor.

## Evidência automática

`node --test tests/offline_datasets.test.mjs` reproduziu as duas exceções antes
da correção, com os metadados e os scripts reais. Depois da correção verifica
os três níveis de cada jogo, a sequência inicial de imagens e a aceitação e
rejeição de respostas únicas e múltiplas. Os modelos Qt são substituídos apenas
na fronteira do teste. Não simula cliques nem arrastar imagens numa janela real.

`tests/test_offline_resource_build.py` compila os recursos com a função CMake
real e lê os RCC com Qt para confirmar os quatro `Data.qml` distribuídos.
`tests/test_translation_build.py` confirma a tradução PT compilada das novas
perguntas, de `cão` e do rótulo `Padrão`.

Uma implantação privada em `build/runtime-probe/` usa uma cópia do executável
existente e RCC recompilados destas fontes. O catálogo foi convertido com
`lconvert -target-language pt_PT` antes de gerar o QM. Os recursos externos são
ligados para leitura; a compilação original não foi alterada. O arranque offline
final usa `after-offline-final/`, com perfis novos e a rede desativada:

```bash
python3 tools/smoke-activity.py \
  --binary build/runtime-probe/bin/gcompris-qt \
  --output .scratch/pt-pt/runtime/after-offline-final --seconds 4 --offline \
  multiple_choice_questions ordering_chronology keyboard_training sketch
```

A flag `--offline` executa o binário nativo num contentor Docker com
`--network none`, o sistema de ficheiros do anfitrião apenas para leitura e `/tmp`
volátil para a configuração nova. Usa uma imagem já instalada com `chroot`, sem
a descarregar. Cada log confirma que a atividade iniciou; a ausência de erros
QML é apenas uma verificação de arranque. O programa é iniciado com `--mute`.
Não constitui prova de áudio ou de utilização de todos os recursos offline.

## Resultados incrementais e retomada

O verificador agora grava `results.json` atomicamente depois de cada atividade.
`run.json` regista hashes SHA-256 das fontes relevantes, do executável, dos
recursos distribuídos e do próprio verificador, além de locale, duração e imagem
Docker. Segue os diretórios externos ligados por symlink para incluir os pacotes
reais no hash. As bibliotecas do sistema operativo não fazem parte deste hash.

Para continuar um arranque interrompido, repete o comando com `--resume`.
O verificador conserva os resultados anteriores apenas quando os hashes e a
configuração coincidem. Se as fontes ou a compilação mudarem, usa outra pasta
de resultados. Isto impede juntar resultados de versões diferentes. Uma nova
execução numa pasta existente exige `--resume`; não sobrepõe a evidência anterior.

`tests/test_smoke_activity.py` exercita essa interface com um executável
controlável, incluindo a exceção observada de `subLevels`, a preservação dos
registos e a recusa de reutilização depois de alterar o RCC distribuído.

## Validação ainda necessária

Falta executar a implantação integrada das 203 atividades, jogar cada modo,
concluir os níveis, testar respostas e navegação com Qt e validar Windows 10 x64.
As lacunas sonoras e a revisão do professor permanecem nos respetivos tickets.
