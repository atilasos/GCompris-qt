# Correções da revisão da tarefa 44

Base da correção: `45662f54da4b54b54dec1027decaf6d5d7eee02e`.
Este suplemento trata o P1 Spec da escrita Windows e o P2 de preparação da
proveniência, mais o risco de conversão CRLF no checkout identificado pelo
coordenador. A entrega e os relatórios em `legacy-word-application/` permanecem
históricos e intactos.

## Correções

`complete_voices.py` escreve Contents e completion.json como bytes UTF-8 com LF,
independentemente da plataforma. O codificador também fixa LF explicitamente
na escrita futura do seu manifesto; não foi executado para produzir áudio.
A política e todos os hashes anteriores mantêm-se.

O empacotador compila e verifica o RCC no temporário, copia e verifica toda a
proveniência nesse temporário, exige NOTICE para as duas substituições e prepara
completion.json antes de publicar qualquer ficheiro. Só depois substitui RCC,
proveniência e metadata. Contents é o último ficheiro publicado. Falhas de
preparação preservam todos os bytes do pacote anterior.

Quatro regras exatas em `.gitattributes` fixam `text eol=lf` para os textos
identificados por hash bruto nesta aplicação: manifesto das 32, manifesto das
duas substituições, NOTICE e decisão humana. Não houve normalização de conteúdo,
regra global para JSON/Markdown nem alteração da regra SVG existente.

## TDD e resultados

As interfaces exercitadas são a conclusão real de RCC com a ferramenta Qt,
a escrita de ficheiros sob a tradução de terminações Windows e um checkout
Git real. Os testes injetam falhas na fronteira de cópia/escrita, sem síntese.

- `missing-notice-red.log` reproduz a aceitação indevida da falta de NOTICE
  quando existe uma NOTICE antiga no destino; `missing-notice-green.log` prova
  a recusa antes da publicação.
- `windows-newline-red.log` reproduz Contents CRLF com a tradução de texto
  Windows simulada no Linux; `windows-newline-green.log` prova LF em Contents
  e completion.json. O índice inicial da fixture usa CRLF.
- `checkout-red.log` mostra os quatro hashes errados sob
  `core.autocrlf=true` e `core.eol=crlf`; `checkout-green.log` mostra os quatro
  hashes exatos após `git checkout-index` num mini-repositório temporário,
  contendo apenas os quatro textos fixados e `.gitattributes`.
- `tests-final.log`: 36 testes distintos passaram, sem skips, incluindo os
  seis novos e as regressões anteriores de vozes, CMake, pacote de revisão e
  candidato Windows. PowerShell 7.4.6 foi usado isoladamente no Linux para as
  fixtures existentes, sem executar binários Windows.
- `tests-optimized.log`: os 16 testes de aprovação/publicação também passaram
  com `-O`. Os novos negativos cobrem falta de NOTICE, erro de cópia com escrita
  parcial, cópia silenciosamente corrompida e falha ao escrever metadata.
  Em cada falha a árvore de ficheiros do destino conserva todos os bytes.

## Recursos físicos e política

Uma nova cópia privada foi feita do build privado 44 preservado, sem ler ou
reconstruir o main build. Ver `origin-copy.json`. A conclusão real terminou com
retorno 0 e a auditoria física anterior foi executada sobre estes novos outputs;
ver `completion.json` e `physical-audit.json`.

`windows-full-completion.json` regista uma segunda conclusão completa de 1610
recursos, também em destino novo privado, com as regras de escrita Windows
simuladas e Contents inicial CRLF. A saída coincide integralmente com a política
fixa existente:

| Ficheiro | Bytes | SHA-256 |
| --- | ---: | --- |
| RCC de 16 de outubro |37210875|`766a4650c93cf0d012c768daca8f54a931e061e77e7e7b7ef35585bf05c2869b`|
| Contents LF |3484|`0a52da4564eb3d9c3d6492d93f211686f614519cf3551365d92972438d737ddc`|
| completion.json LF |2272|`8111a1103b2aaff3273a4aee8fb57834b898bb0bd528acc1317cbb1a2e3fcc28`|

A auditoria confirma 1576 originais e 32 adições intactos, apenas as duas
substituições aprovadas e 1610 recursos totais. Nenhum WAV ou OGG foi criado,
recodificado ou alterado nesta correção. O RCC upstream, o ZIP aprovado e os
textos aprovados mantêm os bytes.

Uma cópia nova do layout Windows previamente extraído recebeu estes outputs
novos. `verify-package.py` passou com a mesma política e 203 atividades, sem
faltas ou corrupção; ver `windows-layout.json` e `windows-stage-origin.json`.
Nenhum EXE ou instalador foi gerado ou executado.

## Retornos e limites

Os processos terminaram antes do handoff. A conclusão e auditoria físicas
terminaram 0 no tool chunk `8d92e8`; a suite normal e a otimizada terminaram 0,
com os resultados explícitos dos logs e retorno externo observado em `8a9bf8`.
O layout terminou 0 em `cf30be`; a conclusão completa com simulação Windows
terminou 0 em `a58716`. Os retornos 1 dos casos red são intencionais e não contam
como validação positiva.

A simulação de terminações e o checkout real no Linux verificam determinismo
de bytes, não execução, reprodução sonora ou instalação no Windows. Não houve
nova audição docente nem transferência de aprovação para outras vozes.
Nenhum main build, mapa, CSV global, instalador publicado ou release mudou.
