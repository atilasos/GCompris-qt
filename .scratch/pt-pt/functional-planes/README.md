# Sequências com avião em PT-PT

A tarefa 67 cobre `planegame`, `numbers-odd-even` e `alphabet-sequence` em Qt Linux nativo, locale `pt_PT`, perfis novos, snapshots físicos privados de 269 ficheiros e rede Docker desativada. O build principal foi apenas origem de uma cópia selada. Os três RCC das atividades e o core foram reconstruídos privadamente com fontes Git congeladas.

## Percursos e oráculo

Cada atividade tem quatro níveis de dados internos ao seu componente, sem seletor de datasets nem configuração local exposta. Os dois primeiros mostram a indicação; os dois últimos ocultam-na. A sequência numérica percorre 0–10 e 10–20, 44 capturas nos quatro níveis. A paridade percorre pares 0–20 e ímpares 1–19, 42 capturas. O alfabeto percorre as 26 minúsculas e as 26 maiúsculas, 104 capturas. São 12 níveis e 190 capturas completas, uma sequência natural por nível. As posições, os distratores e a sua temporização continuam aleatórios; não há produto cartesiano dessas possibilidades.

O oráculo usa aritmética inteira, paridade e o alfabeto português moderno escrito independentemente dos datasets. O solver lê apenas textos desenhados nas nuvens, a posição e dimensão dos elementos visíveis, feedback de tempestade/desaparecimento e Bonus. Nunca consulta `score.message`, listas de respostas, estado privado do motor ou ficheiros de dados para descobrir um alvo oculto. Um auditor de dados separado pode ler as fontes, sem as fornecer ao solver.

Os cliques no campo são a interface pública de movimento: o avião percorre a distância com a animação normal. Os controlos demonstram também as quatro setas por eventos de tecla reais. Não há atribuições de posição, velocidade, relógio, progresso ou estado do jogo pelo teste, nem chamadas de soluções/validadores. Os percursos aguardam colisões, desaparecimentos, Bonus e mudança natural de nível, incluindo a volta ao primeiro.

A paridade percorre as oito páginas do tutorial pela interface. Inclui Anterior/Seguinte, três exercícios com resposta errada e correta calculadas a partir dos números apresentados, mensagens de resto e Iniciar. Um segundo percurso completo do tutorial verifica teclado logo após Iniciar e após ajuda/Escape, sem forçar foco. Os três casos de controlos usam Ignorar apenas nos seus perfis separados. Esses casos cobrem captura errada com tempestade, expiração natural, reinício por navegação, passagem circular, indicação oculta, ajuda PT/Escape, foco após ajuda e menu Home ou Escape.

## Correção e tentativas diagnósticas

[Alfabeto com 26 letras](alphabet-fix.md) descreve a única alteração de produção, uma entrada PO que repõe k, w e y. `alphabet-modern-red` e `alphabet-complete` usam exatamente o mesmo caso, com fontes anteriores e corrigidas. O vermelho observa a passagem de j para l quando o oráculo espera k. O verde tem de concluir todos os quatro níveis para aprovar a correção funcionalmente.

As tentativas `number-controller-miss`, `parity-controller-miss` e `alphabet-controller-miss` conservam limites do primeiro controlador de interceção. Não são bugs do produto nem provas de conclusão. O primeiro `alphabet-order-red` conserva a espera por k após a–j. Estes quatro diagnósticos ficam separados dos três percursos completos usados na contagem 190.

O observador revisto regista cada texto enquanto está desenhado e acompanha o seu desaparecimento, incluindo capturas naturais que aconteçam enquanto a nuvem anterior desaparece. A estratégia de movimento evita a margem direita para manter os textos das nuvens que chegam dentro do campo. Não altera a atividade. O percurso completo de paridade terminou com o controlador anterior de espera por nuvem fresca; o seu recibo completo continua válido e tem caso próprio.

## Conclusão externa e identidades

Cada lançamento usa `tools/run-native-qml-supervised.py` da fase congelada. O supervisor espera pelo lançador, que inclui a limpeza privada, e só depois escreve `launcher-status.json`, ligado aos SHA-256 do recibo, caso e lançador. O retorno externo é conferido separadamente de `result.json`. Os vermelhos/diagnósticos têm Qt 0 e lançador 1; as provas verdes exigem ambos 0. A existência de JSON nativo verde não basta.

O índice só pode ser criado quando todos os estados pós-espera existem. O auditor fixa um commit Git histórico com os bytes do índice, dos casos, recibos e estados externos. Os manifestos de fontes são confrontados com blobs Git exatos das fases `fb5e4eac9` e `7e1d611bd`, incluindo catálogo, launcher, supervisor e helper de snapshot. Os mapas de QResource conferem todos os ficheiros dos quatro RCC canónicos, os dois recursos externos e os hashes dos RCC de vozes. Não se abrem caminhos absolutos antigos dos recibos nem se compara com o PO atual.

Uma cópia da pasta de provas é auditável com um repositório que contenha os commits históricos. Os testes negativos alteram casos, recibos, estado externo, caminhos e hashes e recalculam selos coerentemente; a âncora Git deve rejeitar essa reaprovação local.

```sh
python3 tests/functional_planes/audit.py
python3 tests/functional_planes/audit.py --evidence '/copia/provas aviao' --repository /clone/GCompris-qt
python3 -m unittest discover -s tests/functional_planes -p 'test_*.py'
```

Para um novo ensaio, usar o caminho completo de fonte devolvido pelo primeiro comando e saídas novas. Não substituir os ficheiros históricos.

```sh
python3 tests/functional_planes/phase.py --revision COMMIT
python3 tests/functional_planes/prepare.py --origin-snapshot SNAPSHOT_ORIGEM --source-root FONTE_CONGELADA --output SNAPSHOT_PRIVADO
python3 tests/functional_planes/run.py --source-root FONTE_CONGELADA --snapshot SNAPSHOT_PRIVADO --activity planegame --output SAIDA_NOVA
python3 tests/functional_planes/run.py --source-root FONTE_CONGELADA --snapshot SNAPSHOT_PRIVADO --activity planegame --controls --output OUTRA_SAIDA
python3 tests/functional_planes/capture.py --source-root FONTE_CONGELADA --snapshot SNAPSHOT_PRIVADO --output NOVA_CAPTURA
```

O processo de preparação e execução tem de ficar ativo até todos os processos Qt terminarem. Linhas de progresso não são recibos finais.

## Áudio e limites

As 47 vozes solicitáveis são os dez algarismos, os números 10–20 e as 26 letras, reutilizadas também para maiúsculas. Os seus bytes são inventariados nos RCC existentes. Quando o mesmo alias aparece nos dois RCC PT, a captura exige bytes idênticos. Estas vozes e o efeito de erro passaram por GStreamer para `fakesink`, sem alterar ficheiros de áudio.

O Qt arrancou muted e offscreen, sem dispositivo de áudio. Não se certifica audição, pronúncia, reprodução física, acessibilidade, Windows 10 ou 11, dispositivos de toque nem revisão pedagógica. A aprovação de 32 adições de outro lote não é transferida para estas vozes. O professor continua a ter de rever a alteração do alfabeto e a pronúncia das letras. Todos os critérios globais permanecem pendentes.

Para revisão docente concreta: verificar a ordem das 26 letras nos quatro níveis e, em particular, k/w/y e K/W/Y. Ouvir os recursos preexistentes `alphabet/U006B.ogg`, `alphabet/U0077.ogg` e `alphabet/U0079.ogg`, além das restantes vozes inventariadas. Estes ficheiros não foram regenerados nem receberam aprovação por associação às 32 adições anteriores.
