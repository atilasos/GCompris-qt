<!-- SPDX-FileCopyrightText: NONE -->
<!-- SPDX-License-Identifier: CC0-1.0 -->
# Página do fork

Página pública: https://gcompris.infantinho.xyz/.
Projeto Cloudflare Pages Direct Upload: `gcompris-fork`, produção `main`.
Alias: https://gcompris-fork.pages.dev/.

## Atualizar o changelog

Editar `site/content.json`: uma entrada por alteração relevante, data, descrição
para o utilizador, estado de distribuição e commit de origem. Não apresentar um
teste de arranque como validação de jogabilidade. Distinguir o Windows já
publicado das alterações que ainda aguardam compilação.

As capturas públicas estão em `site/assets/screenshots/`. A proveniência, os
hashes PNG e as dimensões estão em `assets/screenshot-sources.json`. Usar capturas
reais, sem dados pessoais, e atualizar `credits.html` quando houver novos autores
ou recursos. Os WebP já estão preparados; Pillow não é necessário para o build.

```sh
python3 site/build.py
python3 -m http.server 8879 --bind 127.0.0.1 --directory build/fork-site
```

O build usa apenas a biblioteca standard Python, gera HTML completo e copia uma
lista explícita de ficheiros públicos para `build/fork-site`. Não copia o repo,
`.scratch`, credenciais ou instaladores. A página funciona sem JavaScript; a
ampliação em diálogo e a descoberta de novos instaladores são melhorias opcionais.

Verificações da publicação e da escolha de instaladores:

```sh
python3 -m unittest discover -s tests -p 'test_windows*.py'
node --test tests/site_latest.test.mjs
```

Depois da verificação local:

```sh
python3 site/deploy.py
```

Este comando atualiza apenas o projeto Pages existente; não muda DNS ou túneis.
Lê as variáveis Cloudflare do ambiente ou o ficheiro externo da skill
`cloudflare-publish`. Não guardar credenciais no Git nem em `site/assets`.
Verificar o HTML, imagens, galeria, telefone e download no hostname final.

## Instaladores atuais e futuros

O workflow `.github/workflows/windows-pt-pt-candidate.yml` compila os pushes que
alteram código/recursos em `master` ou `integration/**`, ou por execução manual.
O desenvolvimento atual está em `integration/crjm-games`; alterações apenas em
branches de trabalho precisam de ser integradas para entrar no pacote automático.

O manifesto `src/activities/activities.txt` define o conjunto completo: não há
uma lista de 203 atividades fixa no empacotamento. A árvore preparada e a
instalada são verificadas contra esse manifesto. Cada pacote regista o commit
que foi efetivamente compilado. Novas atividades precisam do registo normal
no manifesto e dos respetivos recursos CMake.

Depois de os testes Windows passarem, o job `publish` valida os relatórios e
recalcula os hashes antes de criar a prerelease `windows-<run>`, com EXE, ZIP,
SHA256SUMS e `release.json`. Não substitui nem apaga versões anteriores.
O Windows Server da CI não substitui a validação no Windows 10 da escola.

`latest.js` consulta as Releases públicas, valida a identidade do EXE contra os
metadados e o digest GitHub, e atualiza o botão se houver um pacote mais recente
com pelo menos o número de atividades do pacote fixado. Se a API não responder,
a página mantém o download estático. O changelog é editorial e deve continuar a
ser atualizado com as descrições e capturas das alterações.

Para fixar o novo pacote também no HTML sem JavaScript, copiar os dados verificados
de `release.json` para `installer` em `content.json`, atualizar os estados do
changelog e publicar de novo. Preservar o `run`, `source`, `sha256`, `bytes`,
`activities`, data e URL. O comando PowerShell deve usar o nome real do EXE.

## Endereços antigos

O antigo serviço de ficheiros foi mantido em
`downloads-gcompris.infantinho.xyz`, no túnel dedicado `gcompris-download`
(`badc97e1-0134-445a-96d3-9522b68dc251`), origem `127.0.0.1:8878`.
Essa origem depende de o computador estar ligado. Os instaladores novos em
GitHub Releases e o site Pages continuam disponíveis com o computador desligado.

Os caminhos `/gcompris.exe`, `/GCompris-PT-PT-Windows-x64.exe`, `/version.json` e
`/SHA256SUMS.txt` na página redirecionam para esse serviço histórico. A raiz agora
serve a página, conforme pedido. O manifesto do serviço antigo continua a
identificar o candidato de 16 de outubro; não deve ser confundido com o JSON
`/release.json` do site e os candidatos novos do GitHub.

Não executar os antigos scripts de remoção da publicação91: o registo DNS
`570102f98aba7f305d8c7ab404ff8d23` agora pertence ao site Pages.

## Reverter apenas esta página

Para conteúdo, restaurar uma revisão de `site/`, construir e publicar no mesmo
projeto. A Cloudflare também permite rollback de deployments de produção no
projeto Pages; identificar primeiro o deployment pretendido. A primeira
publicação desta página foi `083c3719-93fd-4123-90b6-f6e09ceb2a59`.
Não apagar projetos, túneis ou políticas Access partilhados.

Para desfazer a mudança de hostname, o DNS anterior era um CNAME proxied para
`badc97e1-0134-445a-96d3-9522b68dc251.cfargotunnel.com`. A regra de origem desse
hostname permanece no túnel; restaurar esse DNS faz a raiz voltar a descarregar
o candidato histórico. Desassociar o domínio do Pages apenas se a intenção for
retirar o site desse hostname. Manter o hostname de downloads enquanto existirem
links públicos a usá-lo.
