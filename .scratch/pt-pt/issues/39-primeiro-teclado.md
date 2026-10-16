# Validar O meu primeiro teclado

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25, 35

## Âmbito

baby_keyboard é exploração livre, sem níveis/pontuação. Verificar por eventos
Qt os caracteres portugueses em ambos os casos, letras/dígitos nos teclados
físico simulado e visual, e os controlos especiais expostos. Confirmar glifo
renderizado, locale PT, recurso de voz efetivamente solicitado e descodificação,
sem confundir isso com audição física. Testar foco após ajuda, clique de fundo
e regresso ao menu. O layout visual existente expõe A–Z/dígitos; não acrescentar
funcionalidades ou linhas novas apenas para espelhar o teclado do computador.

Perfil novo offline, snapshots privados, nomes acentuados já aprovados.
Windows, hardware e revisão docente global permanecem separados.

## Answer

Passaram 208 entradas e duas rotas de ajuda/foco/menu em Qt real offline.
Verificados os caracteres portugueses e as vozes pedidas; o MediaPlayer original
reproduziu ç com posição/duração/hasAudio reais. Sem alterações de produção.
[Provas, comandos e limites](../baby-keyboard/README.md).
Não há níveis nesta atividade. O teclado visual tem apenas o layout original
A–Z/dígitos; os acentos foram exercitados pela entrada física/IME.
Windows, hardware e aceitação global continuam pendentes.
