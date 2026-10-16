# Spec review — tarefa 44

Base: `34ebad9be17ffa1b9e73024b28b40b7b801fb348`
Head: `daf3ae13f2c23597945a37c99407a3b914305e1a`
Diff: `git diff 34ebad9be17ffa1b9e73024b28b40b7b801fb348...daf3ae13f2c23597945a37c99407a3b914305e1a`
Commits: `5221548ee`, `26341a140`, `daf3ae13f`.

## Finding

**P1 — A política nova rejeita a conclusão produzida pelo próprio Windows.**
`tools/pt-pt-audio/complete_voices.py:144` escreve `Contents` em modo de texto com `encoding='utf-8'`, mas sem `newline='\n'`. No Windows, a escrita traduz as 51 terminações LF para CRLF. A nova política em `tools/windows/assets-lock.json:95–97` exige os bytes produzidos no Linux: 3484 bytes e SHA-256 `0a52da4564eb3d9c3d6492d93f211686f614519cf3551365d92972438d737ddc`. A saída Windows terá 3535 bytes e SHA-256 `117ab475f70e32b766058270c71fe71c9f86f576141c9f7f61315291dd02c0db`. Como `complete()` inclui esses valores reais em `completion.json`, `verify-package.py:29–32` rejeita o manifesto antes de certificar o layout. `build-candidate.ps1:36` executa precisamente esta conclusão no Windows. A extração privada no Linux não cobre esta diferença.

Requisito afetado: spec, «A versão Windows é testada» e «o instalador offline passa em Windows 10»; aplicação autorizada exige preservar a integração de distribuição Windows. Fixar a escrita de `Contents` em bytes LF, ou `newline='\n'`, e acrescentar uma regressão que reproduza a tradução Windows mantendo a política fixa. Não enfraquecer a política para aceitar hashes declarados pela própria conclusão.

Prova de inspeção: os bytes físicos de `build/legacy-assets/voices-ogg/Contents` coincidem com a política. Uma transformação isolada via `io.TextIOWrapper(..., encoding='utf-8', newline='\r\n')` produz os valores Windows acima. Nenhum Qt, build, instalador ou jogo foi executado nesta revisão.

Não identifiquei outro desvio de âmbito ou requisito implementado incorretamente: a aprovação exata permite os dois pares, os OGG são derivados dos WAV aprovados, as 32 adições e os demais originais têm limites explícitos e os relatórios distinguem a prova física de uma audição/execução Windows.
