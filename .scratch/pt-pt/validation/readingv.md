# Leitura vertical em português de Portugal

Atividade `readingv`, GCompris 26.2.0, Ubuntu 26.04 / Qt 6.10.2,
15 de outubro de 2026. Prova funcional Linux com aplicação real e RCC/perfil
privados, rede Docker `none`; executável, catálogo, casos e recursos têm hashes
nos resultados. Não é aprovação final de Windows nem do professor.

## Âmbito

Três níveis PT com 27/39/81 entradas, dez respostas certas por nível; direção
vertical, velocidades 1–10 e idioma português do sistema/Portugal explícito.
Não há modo de maiúsculas ou entrada de palavras nesta atividade. A apresentação
horizontal/vertical é o modo pedagógico; ambas usam o mesmo JavaScript.

`../functional-reading/verified/readingv-complete/` contém a observação de
cada palavra exibida, cliques em respostas certas/erradas, bloqueio de cliques
durante feedback, conclusão com animações normais, avanço dos três níveis e volta
ao primeiro, reinício e pulsos de temporizador nas dez velocidades.
`../functional-reading/verified/readingv-controls/` contém setas de nível,
ajuda portuguesa e Escape para regressar ao menu. Os dados reais são verificados
pelo teste Node em `tests/functional_reading/data.test.mjs`.

O idioma e velocidade são fixtures aplicadas entre stop/start; não se certificam
gestos nos diálogos de configuração. A lista PT nova está no RCC privado de
wordsgame e a sessão verifica «música» no conjunto realmente carregado.

## Falhas e limites

Corrigidos lista que perdia uma palavra, remoção incompleta de um alvo repetido,
contagem de níveis não publicada ao sistema de sequências e acento de «música».
Reproduções RED/GREEN e comandos em `../functional-reading/README.md` e
`tests/functional_reading/README.md`.

As duas tentativas iniciais terminaram com SIGSEGV após o primeiro acerto.
Essas falhas ficam conservadas e não são convertidas em aprovação. A repetição
completa do caso original e o ensaio final têm resultados separados. Não foi
demonstrada a causa do sinal; persiste um limite de diagnóstico, mesmo quando as
sessões posteriores passam. Consultar a cronologia concreta em
`../functional-reading/README.md` antes de atribuir um estado global.

Não há locução ativa de palavras nesta atividade; efeitos sonoros físicos não
foram certificados com `--mute`. Windows 10, escola e aprovação pedagógica e
linguística do professor continuam pendentes. Os textos e palavras observados
em português não constituem revisão humana completa do vocabulário.
