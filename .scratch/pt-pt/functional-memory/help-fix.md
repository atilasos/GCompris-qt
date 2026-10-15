# Ajuda de numerais e números por extenso

A ajuda nativa de memory-wordnumber dizia associar o número à «imagem desenhada»
e definia numeral como número «representado por imagens». O jogo apresenta
algarismos e palavras; a fonte inglesa descreve explicitamente figures/words.

O caso wordnumber_help.qml falhou na aplicação com a descrição anterior
([red](help-red/result.json)). Foram corrigidas apenas as duas entradas da ajuda
no catálogo PT, preservando o HTML acrescentado pelos controlos e sem alterar
os nomes zero–vinte. A nova aplicação compilou um QM privado e o mesmo caso
passou, abriu a ajuda e verificou algarismos/número por extenso
([green](help-green/result.json), [captura](help-green/number-name-help.png)).

msgfmt --check --check-format passou. A revisão pedagógica pelo professor mantém-se
pendente e o diagnóstico de saídas nativas 139 do lote completo é independente.
