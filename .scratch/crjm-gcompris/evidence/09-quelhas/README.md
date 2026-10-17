# Ticket 09: Quelhas contra Tux e aprendizagem

Base confirmada antes de editar: 2cc696b97, ancestral da worktree work/crjm-09.
Seam aprovado: aplicação Qt real, desde o menu, regras CRJM como referência.
Implementação independente GPL-3.0-or-later, sem copiar código ou recursos CRJM.
Origem das regras continua atribuída no manual nativo.

## Reprodução

```sh
python3 tools/run-native-qml-case.py \
  --resource-snapshot /tmp/crjm-native-base \
  --activity menu --from-menu \
  --extra-activity dominorio --extra-activity gatos_caes \
  --extra-activity faisca --extra-activity quelhas \
  --qml-file src/activities/menu/Menu.qml \
  --case tests/crjm/quelhas-tux.qml \
  --output /tmp/quelhas09-recheck --offline
```

Para regressão usar tests/crjm/quelhas.qml e outra pasta de saída.
O runner compila recursos privados da fonte, não modifica a instalação.

## Resultados

- red-menu: teste escrito antes da implementação. Falha ao encontrar o controlo
  Contra Tux inexistente. Zero erros QML.
- native: 2 passes, zero falhas e zero erros QML. Abre pelo menu real; ativa modo,
  dificuldades, Aprender, experimentar e pistas por Tab e Espaço. O exercício
  preparado ensina ganhar sem jogada depois da última ação horizontal.
- Difícil troca na abertura. O teste observa as novas orientações, continua a
  jogar segmentos horizontais humanos enquanto Tux joga verticalmente e chega
  a resultado misère real. Nenhum mock, atribuição de vencedor ou acesso ao motor
  para preparar/desenhar jogadas. O teste lê casas e textos visíveis.
- Revisão restaura a primeira decisão real antes da troca e permite outro
  segmento. Feedback compara 88 pares horizontais originais com 86 alternativos,
  explica a condição misère e não apresenta um vencedor fictício.
- Fácil e Médio dão respostas legais. Reinício descarta gerações anteriores,
  saída regressa ao menu sem reaparecer uma ação. Ajuda conserva a posição.
- regression08: percurso completo de duas pessoas, 2 passes, zero falhas/erros QML.
  Preserva Tab direto para troca, referências CRJM e entradas inválidas, teclado,
  toque sintético, ajuda, final misère e reinício.
- Capturas 1100×700 e 600×900 inspecionadas: tabuleiro e controlos separados,
  células acima dos limites 36 px desktop e 40 px retrato. Captura da revisão
  inspecionada com feedback e alternativa no tabuleiro.

## Resposta e limites

Host Linux x86_64 Intel Core i5-12600K, 16 CPUs lógicas, Qt 6.10.2, pt_PT,
renderer software/offscreen, Docker sem rede e snapshot de recursos imutável.
`result.json` regista versões, hashes e isolamento. Não se recompilou C++ porque
as alterações são QML e módulos ES compilados para RCC pelo percurso real.

WorkerScript usa o mesmo módulo de regras da UI. Fácil escolhe aleatoriamente;
Médio compara espaço em até 30 candidatos; Difícil troca na abertura e avalia
até 20 respostas por candidato. Terminais usam o objetivo misère, não o de
Dominório. Toda a busca corre fora da thread de interface. Reinício, saída e
resultado invalidam a geração. É uma IA didática limitada, sem promessa de força.

Heartbeat de 25 ms observado durante toda a aceitação: intervalo máximo 247 ms,
abaixo do orçamento 250 ms. Resposta máxima medida desde confirmar até turno
humano ou resultado, incluindo abrir e fechar ajuda na primeira ação: 1230 ms.
Esta medida conservadora fica abaixo de 2 s para resposta e 1,5 s para ajuda.
A sequência inclui esperas de teste para animações da ajuda.

O host não é um dispositivo modesto. Não se afirma aprovação de desempenho em
hardware físico modesto, toque físico, áudio ou adequação pedagógica com crianças.
