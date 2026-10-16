# Apagar imagens no Qt nativo

Tarefa 58 em execução. Três pilotos passaram um nível completo, com seis
imagens por nível: movimento automático, clique manual e duplo clique manual.
Os pilotos não certificam os seis níveis. As seis campanhas finais continuam
ativas e só os recibos terminados poderão entrar no índice de aceitação.

O teste nativo `probe` mostrou publicLevels=0 e privateLevels=6. A contagem
literal interna não emitia uma alteração inicial capaz de publicar o total.
A correção declara os seis níveis no ActivityBase e liga a leitura interna a
esse valor. `probe-fixed` passou publicLevels=6, privateLevels=6 e Image.Ready.
Não foram alteradas máscara, temporizações, imagens ou lógica de revelação.

O snapshot independente contém 269 ficheiros físicos. Os RCC core e das três
atividades são recompilados numa preparação privada; o launcher recompila o
RCC comum com o caso instrumentado, mantendo o build principal sem alterações.

O ambiente não tem dispositivo de áudio. SoundEffect não chegou a Ready nem
playing. A extração/descodificação de WAV será distinguida de reprodução e
não constitui audição física. Windows, toque, hardware e revisão docente
continuam pendentes.
