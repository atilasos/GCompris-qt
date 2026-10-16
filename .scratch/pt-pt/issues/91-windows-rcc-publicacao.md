# Corrigir RCC Windows e publicar instalador em endereço curto

Status: ready-for-agent
Progress: resolved
Type: task

## Âmbito

Pedido explícito do professor: corrigir a falha CI Windows 38885128522 e servir o novo instalador através da Cloudflare num endereço fácil de escrever. Manter as 32 adições e dois pares aprovados, os hashes dos áudios individuais e os recursos upstream. Não substituir a verificação física por confiança no manifesto gerado. Preservar o link anterior durante a preparação.

## Reprodução

No head 11f6ff1c4, a conclusão Windows verifica os 1610 recursos mas gera RCC SHA256 471e582267642fbe0019eadb887ffb9e8ff537afe2a89feb4b40cfc52a75d2dd, em vez do contentor Linux 766a4650c93cf0d012c768daca8f54a931e061e77e7e7b7ef35585bf05c2869b. Contents LF tem 3484 bytes mas hash d0a780069923bc88aeee9ef9b900fed77f4e1a1de560d497728d697440f56bf7. verify-package rejeita voice-completion-manifest e Contents. Os OGG individuais e a proveniência passam a comparação, sem alteração autorizada das gravações.

## Aceitação

Reproduzir e corrigir a diferença do contentor entre plataformas, com teste de regressão. Pipeline Windows completo verde, EXE efetivo verificado por hash, publicação HTTPS em endereço curto testada com conteúdo real. Registar limites de testes CI versus Windows 10 da escola.

## Correção do verificador preparada

Política de dois pares físicos RCC+Contents fixados, sem misturas nem confiança nos hashes declarados. Invariantes, áudios e proveniência preservados. Fonte, red/green Qt real e limites em ../windows-rcc-policy/README.md. 40 testes verdes, 14 também -O; auditor Linux histórico compatível. A prova Windows física completa e a publicação continuam a cargo do coordenador na próxima CI. A tarefa permanece claimed.


## Answer

Resolvida a correção e a publicação pedidas. A política fixa dois pares físicos
RCC/Contents, mantém invariantes e verifica bytes reais. A CLI lê UTF-8
explicitamente. [Revisões e recheck](../review/integration91/README.md)
sem achados. A [CI 38894977302](../windows/38894977302/README.md) passou na fonte
3c98f5c6b, com oito arranques staged e 203 installed offline.

O EXE efetivo foi transferido, conferido por CRC/SHA e extraído para leitura
Qt dos recursos: duas gramáticas PT, 1610 vozes, 1576 originais e 32 adições
intactos, apenas os dois pares aprovados substituídos.
A [publicação HTTPS](../publication91/README.md) em https://gcompris.infantinho.xyz/
foi verificada por browser, intervalos e descarga pública completa com hash igual.
Os logs preservam também a recusa 403 do User-Agent Python predefinido.
O quick-tunnel anterior e as políticas partilhadas permanecem intactos.

Este fecho não aprova Windows 10 da escola, hardware, audição ou jogabilidade
global. A origem depende do computador ligado. CSV e cápsulas anteriores
permanecem intactos, com todos os critérios globais pending.
