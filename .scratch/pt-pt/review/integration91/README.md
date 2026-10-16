# Revisões da política Windows e UTF-8

[Standards](standards-review.md) e [Spec](spec-review.md) reveram a correção
`4626a8d860dfd584341f569d3bdb1130b2c2fae1`, baseada em `e4444354e`.
Não encontraram achados acionáveis na seleção dos dois pares físicos fixados.
Spec executou nove regressões e 40 verificações da seleção com o lock real.
A observação sobre encoding CLI foi corrigida em `397ca3e74545c44c8efa3c5988b468020ccbfc3a`.
O [recheck UTF-8](utf8-recheck.md) passou um teste real da CLI com duas orientações.
Os três relatórios são cópias literais. Nenhuma destas revisões certificou
Windows, instalador ou publicação, verificados posteriormente pelo coordenador.

A fonte CI final é `3c98f5c6b4543e15dda66e2b0e275f5d9e6b49df`.
As [provas CI](../../windows/38894977302/README.md) e a
[publicação HTTPS](../../publication91/README.md) delimitam os resultados finais.
