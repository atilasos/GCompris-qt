# Instalador Windows publicado por HTTPS

Nota de operação, 18 de outubro de 2026: este registo descreve a publicação
histórica. O mesmo serviço passou para
https://downloads-gcompris.infantinho.xyz/; a raiz de `gcompris.infantinho.xyz`
passou a alojar a página estática do fork. Os caminhos de download nesse hostname
acompanham o pacote fixado na página. Não executar a remoção DNS descrita
abaixo: esse registo agora pertence ao site Pages. Operação atual em
[site/README.md](../../../site/README.md).

[Descarregar o instalador histórico](https://downloads-gcompris.infantinho.xyz/).
Run `38894977302`, fonte `3c98f5c6b4543e15dda66e2b0e275f5d9e6b49df`.
EXE: 825758994 bytes, SHA-256
`1955a4fbde1c91721921fe0ea40843c40f86fa42b0f86ba91a8fb54f19a65543`.
O download do artefacto verificou CRC do ZIP e SHA-256 do EXE.

A [auditoria do instalador efetivo](actual-installer-verification.json)
extraiu o NSIS com 7-Zip e leu os RCC com Qt no Linux.
As duas gramáticas contêm 8 e 7 níveis PT iguais à fonte.
As vozes têm 1610 recursos: 1576 originais e 32 adições intactos,
apenas cervato e carraça substituídos. O par físico Windows RCC `471e5822…`
e Contents `d0a78006…` passou a política estrita. Não foi execução do instalador.

A [verificação pública](public-verification.json) descarregou integralmente
825758994 bytes em 58.13 segundos, com SHA igual ao EXE verificado.
HEAD 200, dois Range 206 de 1 MiB, checksum, identidade da fonte e recusa
404 passaram. O [browser T3](browser-verification.json) confirmou HEAD e
os dois intervalos com bytes iguais ao EXE local.
A tentativa Python com User-Agent predefinido recebeu 403 Cloudflare 1010;
o [log original](public-verification-python-default-403.log) fica preservado.
O teste completo usou o User-Agent real observado no browser, sem cookies
ou tokens de autenticação. Não se alteraram proteções Cloudflare nem políticas
Access partilhadas. Os [retornos observados](observations.json) ficam separados
dos recibos CI e não são assinaturas da plataforma.

## Operação e repetição

Origem: `http://127.0.0.1:8878`. Diretório operacional:
`/home/proteu/Projetos/GCompris-qt/build/pt-pt/download-publication-short`.
Os scripts aqui são cópias literais dos executados nesse diretório.
`server.py` recebe o manifesto externo e a porta. Os serviços user
`gcompris-download-origin.service` e `gcompris-download-tunnel.service`
estão enabled e ativos. Esta publicação depende de o computador continuar ligado.
O token fica fora do Git, num ficheiro 0600 em diretório 0700.
Nenhum token, credencial, EXE ou RCC está neste arquivo documental.

A raiz, `/gcompris.exe` e `/GCompris-PT-PT-Windows-x64.exe` servem o instalador.
`/version.json` identifica run, fonte, bytes e SHA; `/SHA256SUMS.txt` expõe o hash.
Os restantes caminhos são recusados. Há suporte Range, If-Range, ETag,
Content-Disposition e Cache-Control no-store, sem listagem de diretórios.

Para repetir a verificação pública da versão atual, executar
`python3 build/pt-pt/download-publication-short/verify-public.py` na raiz do projeto.
Esse comando lê o manifesto atual e transmite o ficheiro completo para cálculo
de hash. Não publica nem altera Cloudflare. O `verify-installer.py` fixa o run
38894977302 e o caminho do EXE; requer QtCore, o inventariador
`build/pt-pt/bin/pt_audio_rcc_inventory` e o 7-Zip indicado no script.
Recusa reutilizar a saída `actual-installer`. Uma repetição exige destinos novos
para a extração e três exportações, preservando as provas anteriores.

Para atualizar a versão, obter e verificar outro EXE num caminho novo,
conservar o anterior e preparar um novo `current-installer.json` com identidade
verificada. Publicar o manifesto por escrita temporária no mesmo diretório e
`Path.replace` sobre o manifesto atual. O servidor relê-o por pedido,
sem reinício. Streams já abertos mantêm o ficheiro aberto; o ETag muda e
If-Range impede retomar outra versão como se fossem os mesmos bytes.
Uma alteração do código do servidor exige reinício e pode interromper downloads.
`activate-origin.py` e `publish-dns.py` são o histórico de ativação desta versão,
não comandos genéricos de atualização: o segundo recusa um DNS já existente.

Para retirar esta publicação, remover apenas o DNS identificado em
[cloudflare-state.json](cloudflare-state.json), parar e desativar os dois serviços
dedicados e remover apenas o túnel `gcompris-download` se deixar de ser necessário.
Não alterar outros registos, túneis ou políticas Access.
O quick-tunnel anterior permanece intacto.

## Limites

A CI usou Windows Server 2022, Qt 6.10.2 e o mesmo utilizador CI inicialmente
fresco. Foram oito arranques staged e 203 installed de seis segundos offline.
Não é Windows 10 da escola, jogabilidade completa, hardware ou audição humana.
As aprovações das 32 e dos dois WAV continuam delimitadas.
O CSV conserva 203 atividades, 152 ligações e todos os critérios globais pending.
