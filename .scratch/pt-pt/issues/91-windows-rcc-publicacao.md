# Corrigir RCC Windows e publicar instalador em endereço curto

Status: ready-for-agent
Progress: claimed
Type: task

## Âmbito

Pedido explícito do professor: corrigir a falha CI Windows 38885128522 e servir o novo instalador através da Cloudflare num endereço fácil de escrever. Manter as 32 adições e dois pares aprovados, os hashes dos áudios individuais e os recursos upstream. Não substituir a verificação física por confiança no manifesto gerado. Preservar o link anterior durante a preparação.

## Reprodução

No head 11f6ff1c4, a conclusão Windows verifica os 1610 recursos mas gera RCC SHA256 471e582267642fbe0019eadb887ffb9e8ff537afe2a89feb4b40cfc52a75d2dd, em vez do contentor Linux 766a4650c93cf0d012c768daca8f54a931e061e77e7e7b7ef35585bf05c2869b. Contents LF tem 3484 bytes mas hash d0a780069923bc88aeee9ef9b900fed77f4e1a1de560d497728d697440f56bf7. verify-package rejeita voice-completion-manifest e Contents. Os OGG individuais e a proveniência passam a comparação, sem alteração autorizada das gravações.

## Aceitação

Reproduzir e corrigir a diferença do contentor entre plataformas, com teste de regressão. Pipeline Windows completo verde, EXE efetivo verificado por hash, publicação HTTPS em endereço curto testada com conteúdo real. Registar limites de testes CI versus Windows 10 da escola.
