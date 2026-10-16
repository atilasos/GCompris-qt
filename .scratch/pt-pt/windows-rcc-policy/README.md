# Tarefa 91: pares físicos RCC/Contents explicitamente fixados

A CI 38885128522 verificou os 1610 recursos mas produziu um contentor RCC
Windows diferente do Linux, com a mesma dimensão. Contents já tinha LF e 3484
bytes. A falha preservada em `ci-failure-excerpt.log` é distinta da correção
CRLF anterior. `source-and-ci.json` regista a origem e os hashes desta evidência.

A fonte oficial Qt 6.10.2 em [rcc.cpp](https://code.qt.io/cgit/qt/qtbase.git/tree/src/tools/rcc/rcc.cpp?h=v6.10.2),
linhas 1148–1258, emite blocos e nomes pela iteração de `QMultiHash`. A ordenação
pelo hash de pesquisa aplica-se depois à árvore. [main.cpp](https://code.qt.io/cgit/qt/qtbase.git/tree/src/tools/rcc/main.cpp?h=v6.10.2),
linha 430, já fixa a seed. Os ficheiros fornecidos pelo coordenador foram lidos
localmente e identificados por SHA no relatório; o acesso web a code.qt.io
falhou. Não foi isolada a diferença exata de ABI/hash entre os dois hosts.
A iteração não ordenada impede tratar a ordem QRC e a seed fixa como garantia
contratual de um único hash entre plataformas.

A correção não cria outro serializador nem confia nos hashes declarados pela
conclusão. `pt_voice_completion` permanece intacto como identidade histórica
Linux. O novo `pt_voice_container_variants` fixa dois pares completos:

| Origem observada | SHA-256 RCC | SHA-256 Contents |
| --- | --- | --- |
| Linux Qt 6.10.2 |`766a4650c93cf0d012c768daca8f54a931e061e77e7e7b7ef35585bf05c2869b`|`0a52da4564eb3d9c3d6492d93f211686f614519cf3551365d92972438d737ddc`|
| Windows CI 38885128522 |`471e582267642fbe0019eadb887ffb9e8ff537afe2a89feb4b40cfc52a75d2dd`|`d0a780069923bc88aeee9ef9b900fed77f4e1a1de560d497728d697440f56bf7`|

O helper `approved_completion_files` aceita exatamente um par. Todas as outras
identidades, contagens, decisões e proveniência têm de coincidir com a política
comum anterior. O verificador continua a ler cada ficheiro físico e comparar
dimensão/hash com os valores fixos escolhidos. Misturar componentes dos dois
pares, adulterar bytes ou refazer os hashes declarados não permite aprovação.
Não existe fallback para um terceiro contentor, mesmo com recursos iguais.

## Prova local

O teste novo compila dois RCC v1 reais com Qt 6.10.2 a partir das mesmas 64
fixtures binárias pequenas, invertendo apenas a entrada QRC. Têm 5504 bytes,
hashes diferentes e inventários Qt idênticos. Os recursos das fixtures são
marcadores sintéticos de teste, sem geração de gravações de voz.
Os dois pares só são aceites quando ambos estão explicitamente fixados na
política da fixture. As misturas, contentor não listado, corrupção física,
reseal coerente e alteração de invariantes são recusados.

- `policy-red.log` e `policy-green.log`: regressão da interface de pares fixos.
- `tests-final.log`: 40 testes passaram, sem skips, incluindo os quatro novos
  e as 36 regressões anteriores. PowerShell 7.4.6 isolado no Linux.
- `tests-optimized.log`: 14 testes de pares/aprovação passaram também com `-O`.
- `linux-layout.json`: leitura física do layout privado anterior, 203 atividades,
  aprovada com a política nova. Não houve escrita nesse layout.
- `linux-physical-compatibility.json`: o auditor físico histórico Linux continua
  válido sem alteração do código ou das provas anteriores.

A suite e os testes `-O` terminaram 0, observado no tool chunk `cad79b`.
A produção mudou apenas o lock e o verificador de pacote. Não mudaram o
empacotador, os áudios, a política comum, os textos aprovados nem provas antigas.

## Limite e próxima etapa

O par Windows vem do retorno real da conclusão na CI anterior, onde os 1610
hashes de recursos já tinham passado. Os bytes do contentor Windows não foram
obtidos nem inspecionados independentemente nesta árvore. A próxima CI deverá
verificar fisicamente este par no stage e na instalação; um novo hash continuará
a falhar até investigação e aprovação explícitas. Não há aceitação global de
Windows 10 da escola, hardware, reprodução sonora ou publicação. O coordenador
trata a CI e o endereço HTTPS; não houve push, main build ou publicação aqui.

## Complemento da fronteira UTF-8

O CLI lê agora lock e completion explicitamente como UTF-8. Um teste executa
esse CLI com o default de leitura cp1252 simulado e dois JSON semanticamente
iguais: um usa `carraça` literal UTF-8, o outro usa escapes Unicode ASCII.
Repete também a orientação inversa. Ambos falhavam antes das duas leituras
explícitas e agora passam com retorno 0, layout completo de fixture e sem
corrupções. Ver `utf8-cli-red.log` e `utf8-cli-green.log`.
Os 15 testes de pares/aprovação passam com `-O`, em `utf8-cli-optimized.log`,
com retorno externo 0 observado em `9c6c78`.

Esta regressão comprova o contrato de codificação JSON. Não se afirma que
explica a falha anterior de dois ficheiros atuais igualmente escritos em UTF-8,
pois uma leitura cp1252 poderia transformar ambos da mesma maneira.
As fixtures de layout são ficheiros de teste, sem executar binários Windows.
