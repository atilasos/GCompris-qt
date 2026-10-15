# Validar o primeiro processador de texto em PT-PT

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25

## Aceitação

Exploração livre, sem níveis: entrada física/IME de caracteres portugueses,
teclado visual com maiúsculas/minúsculas e edição, títulos/subtítulos/parágrafos,
guardar/carregar uma criação, reiniciar, ajuda, foco e menu. Cobrir o modo áudio
ligado/desligado, observando os recursos realmente pedidos e o player original.
Não substituir teclado, armazenamento ou áudio por chamadas ao motor.

Usar Qt real, perfil novo offline e recursos privados. Conservar comandos,
hashes e resultados. Distinguir áudio descodificado de audição física, e não
aprovar Windows nem aceitação docente global por estes testes.

## Checkpoint parcial

Espaço do teclado visual descartado pelo parser HTML: correção e vermelho/verde
em [space-fix.md](../first-wordprocessor/space-fix.md). A tarefa continua claimed.

## Answer

Quatro casos finais offline passaram. Texto português, teclado visual completo,
três formatos, guardar/carregar, reinício, áudio configurado, ajuda/foco/menu.
Corrigidos o Espaço visual e a grafia de Subtítulo. [Provas e limites](../first-wordprocessor/README.md).
Os critérios globais mantêm-se pendentes.
