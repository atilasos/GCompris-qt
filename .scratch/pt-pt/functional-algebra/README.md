# Quatro operações com balão

Os quatro jogos concluíram todos os 48 níveis na interface Qt real, offline,
com perfil PT novo. Foram480 respostas corretas e48 erradas. A referência
é calculada fora do motor com Fraction, a partir dos operandos apresentados.
Não se chama getAnswer/validateAnswer, não se atribui pontuação nem se move
o balão para completar uma questão. Alternam-se teclado físico simulado,
teclado visual e submissão por Enter/OK.

Uma tecla5 produzia55 e Backspace apagava duas posições devido à propagação
do evento de ActivityBase. `keyboard-baseline` reproduz a falha; `keyboard-green`
passa depois de aceitar apenas os eventos numéricos/Backspace tratados em Algebra.
A primeira tentativa da fixture usava a assinatura errada de keyClick; não é
contada nem arquivada como reprodução do produto.

Nos quatro jogos passaram ajuda PT, anterior/próximo, retorno ao menu, dez
velocidades e reinício com resposta pendente. A expiração real de10 segundos
na velocidade10 não dá pontos e permite continuar a escrever após Bonus.
As velocidades são configuradas pelo ciclo stop/start real, não por gestos
no slider. O resultado de cada caso está em index.json, com hashes.

Os12 casos funcionais finais e a regressão curta verde usam o mesmo snapshot
selado de269 ficheiros e executável3a226ee745c25aa8cf5e77d7cfb438c83dc6956091e6230053598cca659314bb.
O RCC da atividade e o catálogo PT são reconstruídos em privado a partir deste
checkout. O binário principal não é reescrito.

Limites: QtTest injeta eventos reais no Qt, mas não representa teclado/rato
físicos ou som audível. Não foram testados gestos no diálogo de configuração,
nem aceitação Windows10, escola ou revisão pedagógica final. A matriz global
continua pendente.

Reprodução: tests/functional_algebra/README.md.
