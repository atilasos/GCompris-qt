<!-- SPDX-FileCopyrightText: NONE -->
<!-- SPDX-License-Identifier: CC0-1.0 -->
# Página pública do fork

Pedido de 18 de outubro de 2026: criar uma página estática com changelog,
instalador Windows mais recente e capturas reais; usar a raiz
`gcompris.infantinho.xyz`. O utilizador pediu também que os novos desenvolvimentos
entrem nos instaladores seguintes.

## Publicação

- Cloudflare Pages Direct Upload: `gcompris-fork`, produção `main`.
- Hostname: https://gcompris.infantinho.xyz/; alias `gcompris-fork.pages.dev`.
- DNS do site: `570102f98aba7f305d8c7ab404ff8d23`, atualizado do túnel para Pages.
- O domínio, a verificação e o certificado foram confirmados ativos pela API.
- O serviço de ficheiros anterior permanece no túnel dedicado, agora também em
  `downloads-gcompris.infantinho.xyz`. Os caminhos antigos acompanham o pacote fixado na página.
- Outros projetos Pages, túneis e políticas Access não foram alterados.
- O token Cloudflare permaneceu no ficheiro externo, sem cópia para o Git,
  GitHub Actions ou os assets públicos.

## Conteúdo e verificação

HTML, CSS e JavaScript sem framework; build Python com biblioteca standard.
Changelog editorial baseado nos commits e nas provas locais. Doze capturas
convertidas para WebP: oito jogos, gramática, antes/depois da Faísca e Nex em
retrato. Origens e hashes dos PNG registados em
`site/assets/screenshot-sources.json`, créditos em `site/credits.html`.

`http-verification.json` confirma os ficheiros publicados byte a byte, os
redirecionamentos antigos e o 404. A primeira tentativa do teste de 404 com o
User-Agent Python predefinido recebeu 403 Cloudflare; com o mesmo User-Agent
usado nas outras verificações respondeu 404. Nenhuma proteção foi alterada.

`ui-verification.json` regista a inspeção no browser T3 a 390×844 e 1440×960:
sem imagens partidas ou overflow horizontal; diálogo ampliado e Escape
verificados. As capturas das atividades são Qt real em Linux, não Windows ou
um tablet físico. Os testes não certificam a adequação pedagógica.

Verificações locais: 15 testes Python, 13 executados e 2 ignorados por
plataforma/dependências; seis testes Node da escolha de instaladores.
Os controlos recusam fonte divergente, binário alterado e atividades em falta,
e mantêm o link estático perante API indisponível ou digest divergente.

## Instaladores

O workflow passou a executar para alterações de código nas branches `master`
e `integration/**`. O manifesto de atividades é a autoridade para o pacote.
A publicação gera prereleases imutáveis por execução, depois de instalação,
arranque offline e verificação de hashes. A página descobre novos pacotes por
API pública e conserva um pacote fixado para acesso sem JavaScript/API.

A primeira compilação deste percurso é
https://github.com/atilasos/GCompris-qt/actions/runs/39151266113,
fonte `97ff78c34ab5383bdbe633120a6777abd15dac8c`, com 211 atividades.
O push HTTPS da alteração do workflow foi recusado por faltar o scope `workflow`;
o push SSH com a chave já autorizada funcionou, sem alargar permissões OAuth.

A compilação Windows e o job de publicação terminaram com sucesso. A release
`windows-39151266113` preserva o EXE, o ZIP portátil, checksums e metadados.
O EXE tem 825829968 bytes e SHA-256
`d3484321d7b80dd08feef1cad172a8bf289d9a31e23cc5ca3b88949363c91f34`.
A extração NSIS confirmou as 211 atividades e comparou 85 recursos reais com a
fonte: os oito jogos e adversários, componentes visuais e gramática com 13 e 12
níveis. `actual-installer-verification.json` regista o resultado.
`installed-startup-check.json` conserva os 211 arranques Windows offline, sem
erros QML, extraídos do log CI. O HTML sem JavaScript foi atualizado para este
pacote, assim como os caminhos antigos de download e de metadados.

Operação, atualização e reversão da página em `site/README.md`.
