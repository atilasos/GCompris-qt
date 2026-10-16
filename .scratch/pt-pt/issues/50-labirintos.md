# Validar os três labirintos em PT-PT

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25

## Aceitação

Concluir os 25 níveis de maze, mazeinvisible e mazerelative com o modo rápido
ligado e desligado. Escolher caminhos pelas paredes efetivamente desenhadas,
observadas com o controlo de revelar no modo invisível, sem ler a matriz
escondida do motor ou chamar funções de movimento/vitória. Entrada real por
teclas e rato/gestos, com tracers para o método não usado em toda a campanha.
Confirmar colisões, rotação relativa, bloqueio enquanto se observa o mapa,
transições e Bonus. Ajuda PT, navegação, menu e recursos usados.

Corrigir defeitos só após reprodução nativa vermelho/verde. Conservar comandos,
hashes e limites; não substituir aceitação Windows, hardware ou docente.

## Answer

150 conclusões principais, 18 tracers por gestos de rato e três controlos,
27 recibos positivos. Três correções nativas já integradas na parcial.
Seis testes da auditoria passam. Todas as sessões terminaram com saída zero.
Provas, fontes fixadas, comandos e limites em `../functional-mazes/README.md`.
Os critérios globais mantêm-se pendentes.
