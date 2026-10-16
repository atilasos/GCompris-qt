# Preparar a audição local das 32 gravações novas

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 05

## Âmbito

Gerar um ZIP offline a partir de `resources/pt-pt-voices/manifest.json`, dos
32 OGG aí identificados e de `NOTICE.md`. Incluir página PT-PT com transcrições,
players, grupos e números estáveis, manifesto original e CSV de revisão pendente.
A audição final é do professor; a geração aprovada não equivale a aprovar os clips.

## Aceitação

- Copiar só os 32 OGG novos, sem alterar bytes, e verificar hashes.
- Identificar instruções, caracteres e topónimos, e explicar como comunicar correções.
- Abrir localmente no Windows depois de extrair o ZIP, sem servidor ou dependências.
- Testar a CLI, manifesto, entradas e hashes ZIP, e escaping das transcrições.
- Verificar a página num browser disponível e registar os limites da verificação.
- Não alterar áudio, catálogos, main build, mapa ou CSV global.

## Answer

`tools/pt-pt-audio/package-review.py` gera o ZIP local. A página contém os
32 players com controlos, transcrições escapadas, grupos e referências estáveis.
Inclui os 32 OGG originais, manifesto e NOTICE sem alterações, e CSV com 32 linhas
em `pending`. A geração não inclui outros ficheiros da pasta de origem.

Três testes pela CLI passaram. Confirmam os 36 membros exatos, hashes dos OGG,
manifesto e NOTICE preservados, estados pendentes, transcrições escapadas no HTML
e intactas no CSV, e rejeição de contagem, hash, duplicação ou caminho inválidos.

O ZIP local está em `build/pt-pt-audio-review/revisao-32-gravacoes.zip` na worktree
`pt-audio-review`. SHA-256:
`cc48b858560d7f6496e2b2b76300940131ce558878554c53f52103e8b88e119e`.
O ZIP fica fora do Git. O procedimento está em `tools/pt-pt-audio/REVIEW.md`.

O preview T3 declarou `available:false`. O Agent Browser Hub abriu a cópia
extraída por HTTP local no perfil research. Foi verificado o título, a navegação
até às instruções, as transcrições, a apresentação dos players e a reprodução
de `intro/polygons.ogg`, com o contador a avançar até 0:02. O servidor entregou
o OGG com HTTP 200. Sessão e servidor local foram fechados.

Capturas locais conservadas fora do Git:

- `/home/proteu/agent-browser-hub/screenshots/pt-audio-review-26.png`
- `/home/proteu/agent-browser-hub/screenshots/pt-audio-review-26-instrucoes.png`
- `/home/proteu/agent-browser-hub/screenshots/pt-audio-review-26-player.png`

O Hub bloqueou `file://` pela sua política. A abertura offline por duplo clique,
a reprodução física no Windows e a revisão de pronúncia e pedagógica continuam
pendentes no computador do professor. Nenhuma aprovação foi registada.

## Seguimento da audição

O professor ouviu e aprovou as 32 gravações completas em 15 de outubro de 2026.
O ZIP original e o seu hash foram preservados. A tarefa35 liga a aprovação
aos textos e hashes individuais; estados pending acima descrevem o pacote
original antes dessa decisão, não uma audição ainda por fazer.
